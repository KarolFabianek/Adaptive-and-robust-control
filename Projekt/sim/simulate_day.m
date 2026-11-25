function [st, D, log] = simulate_day(P, Pc, cfg, st, C, doy, trip, dT_amb, want_log)
%SIMULATE_DAY  Symulacja jednej doby użytkowania samochodu (00:00–24:00).
%
%   [st, D, log] = simulate_day(P, Pc, cfg, st, C, doy, trip, dT_amb, want_log)
%     C    – klimat (climate_profile), doy – dzień roku
%     trip – false: dzień roboczy (dojazdy 2 x 30 min, praca, dom)
%            true : dzień w trasie: 150 km autostradą -> szybkie ładowanie DC
%                   do 80% -> 150 km powrotu -> dom (ładowanie AC wg strategii)
%
%   Dzień roboczy:
%     00:00–07:00 dom, z wtyczką   | 07:00–07:30 jazda | 07:30–17:00 praca, bez wtyczki
%     17:00–17:30 jazda           | 17:30–24:00 dom, z wtyczką
%   Ładowanie AC:
%     strategie STD – od razu po podłączeniu do cfg.soc_ac,
%     strategie LIFE – „just in time”: start tak, by skończyć o 06:45
%     (bateria nie czeka godzinami na wysokim SOC).
%
%   D – podsumowanie doby: S (stres starzenia), E_TM_kWh, E_ch_kWh,
%       Tc_mean, Tc_max (także na postoju w słońcu), Tc_max_active (w jeździe
%       i podczas ładowania – to nadzoruje BTMS), soc_mean, t_dc_min.

if nargin < 8, dT_amb = 0; end
if nargin < 9, want_log = false; end
H = 3600;
E_day = P.km_per_day*P.kWh_per_100km/100*1000*H;   % [J]
P_commute = E_day/(1*H);                           % 2 x 30 min jazdy

S = [0 0 0]; E_TM = 0; E_ch = 0; Tsum = 0; SOCsum = 0; tsum = 0; Tmax = -Inf; Tmax_act = -Inf;
t_dc = 0; Lg = [];

if ~trip
    segs = { [0 7]*H,     3, 0, 'home'
             [7 7.5]*H,   1, P_commute, ''
             [7.5 17]*H,  4, 0, ''
             [17 17.5]*H, 1, P_commute, ''
             [17.5 24]*H, 3, 0, 'evening' };
    for s = 1:size(segs, 1)
        run_segment(segs{s,1}(1), segs{s,1}(2), segs{s,2}, segs{s,3}, segs{s,4});
    end
else
    run_segment(0, 7*H, 3, 0, 'home');
    % trasa: ten sam dystans dla każdej strategii (uczciwe porównanie)
    t_leg = P.trip_km*P.kWh_per_100km_hwy/100*1000*H/P.P_highway;   % [s]
    t = 7*H;
    t = run_until(t, 1, P.P_highway, @(x) x(3) <= 0.03, t_leg, true);
    t_dc0 = t;
    st.z = 0;
    t = run_until(t, 2, 0, @(x) false, 2*H, false);
    t_dc = (t - t_dc0)/60;
    st.z = 0;
    t = run_until(t, 1, P.P_highway, @(x) x(3) <= 0.03, t_leg, false);
    if t < 24*H
        run_segment(t, 24*H, 3, 0, 'evening');
    end
end

D.S = S;
D.E_TM_kWh = E_TM/3.6e6;
D.E_ch_kWh = E_ch/3.6e6;
D.Tc_mean = Tsum/tsum;
D.soc_mean = SOCsum/tsum;
D.Tc_max = Tmax;
D.Tc_max_active = Tmax_act;
D.t_dc_min = t_dc;
log = Lg;

    % ---------------------------------------------------------------
    function run_segment(t0, t1, mode, Pd, tag)
        dt = seg_dt(mode);
        seg = struct('mode', mode, 'P_drive', Pd, 'soc_target', cfg.soc_ac, ...
                     'charge_en', 0, 'precond', 0);
        st.z = 0;
        % plan ładowania AC
        t_start_ac = t0;
        if mode == 3 && cfg.jit
            if strcmp(tag, 'home')
                need = (cfg.soc_ac - st.x(3))*P.E_pack_kWh*3.6e6*st.SOH/P.P_ac*1.15 + 600;
                t_start_ac = max(t0, 6.75*H - need);
            else
                t_start_ac = Inf;   % wieczorem czekamy (chyba że SOC < 35%)
            end
        end
        n = round((t1 - t0)/dt);
        for i = 1:n
            tt = t0 + (i - 1)*dt;
            if mode == 3
                if tt >= t_start_ac
                    seg.charge_en = 1; seg.soc_target = cfg.soc_ac;
                elseif cfg.jit && st.x(3) < 0.35
                    seg.charge_en = 1; seg.soc_target = 0.35;
                else
                    seg.charge_en = 0;
                end
            end
            if mode == 1
                seg.P_drive = Pd*(1 + 0.8*sin(2*pi*tt/180));
            end
            do_step(seg, tt, dt);
        end
    end

    function t = run_until(t, mode, Pd, stopfun, t_lim, precond_check)
        dt = seg_dt(mode);
        seg = struct('mode', mode, 'P_drive', Pd, 'soc_target', P.soc_dc_end, ...
                     'charge_en', 0, 'precond', 0);
        t_end = min(t + t_lim, 24*H);
        t_begin = t;
        while t < t_end
            if precond_check
                seg.precond = (t_end - t) <= 20*60;   % nawigacja: 20 min do ładowarki
            end
            rec = do_step(seg, t, dt);
            t = t + dt;
            if stopfun(st.x) || (mode == 2 && (st.x(3) >= P.soc_dc_end - 1e-4 || (rec(1) <= 0 && t - t_begin > 600)))
                break
            end
        end
    end

    function rec = do_step(seg, tt, dt)
        Ta = ambient_temp(C, doy, mod(tt/H, 24), dT_amb);
        [st, rec, Si] = bms_step(P, Pc, cfg, st, seg, Ta, dt);
        S = S + Si;
        E_TM = E_TM + rec(9)*dt;
        if rec(1) > 0
            E_ch = E_ch + rec(1)*rec(6)*P.ns*dt;
        end
        Tsum = Tsum + rec(3)*dt; SOCsum = SOCsum + rec(5)*dt; tsum = tsum + dt;
        Tmax = max(Tmax, rec(3));
        if seg.mode <= 2 || rec(1) > 0          % jazda, ładowanie DC lub AC
            Tmax_act = max(Tmax_act, rec(3));
        end
        if want_log
            Lg(end+1, :) = [tt, Ta, seg.mode, rec];
        end
    end
end

function dt = seg_dt(mode)
switch mode
    case 1, dt = 10;   % jazda
    case 2, dt = 2;    % szybkie ładowanie
    otherwise, dt = 60; % postój
end
end
