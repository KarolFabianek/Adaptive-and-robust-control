function [res, log] = simulate_session(P, cfg, opts, Pc)
%SIMULATE_SESSION  Sesja szybkiego ładowania DC, opcjonalnie z dojazdem do ładowarki.
%
%   [res, log] = simulate_session(P, cfg, opts)
%   [res, log] = simulate_session(P, cfg, opts, Pc)    Pc to model znany regulatorowi
%
%   Pola opts (wszystkie opcjonalne, w nawiasie wartość domyślna):
%     Ta          temperatura otoczenia [°C] (25)
%     T0          temperatura pakietu na początku [°C] (równa Ta)
%     soc_plug    SOC przy podłączeniu (0,25 jak na wykładzie)
%     soc_target  docelowy SOC (0,80)
%     drive_s     czas jazdy autostradą do ładowarki [s] (900, 0 bez dojazdu)
%     A           stan starzenia (nowa bateria)
%     A_ref       stan, dla którego liczona jest utrata pojemności na sesję
%     dt          krok [s] (1)
%     t_max       największy czas ładowania [s] (7200)
%
%   res zawiera wskaźniki sesji: czas ładowania, maksymalną temperaturę
%   rdzenia, energię układu termicznego, minimalny potencjał anody,
%   litowanie i utratę pojemności [ppm]. log zawiera przebiegi czasowe:
%   dla t < 0 dojazd do ładowarki, dla t >= 0 ładowanie.

if nargin < 4, Pc = P; end
d = struct('Ta', 25, 'soc_plug', 0.25, 'soc_target', 0.80, 'drive_s', 900, ...
    'A', aging_init(), 'dt', 1, 't_max', 7200);
f = fieldnames(d);
for k = 1:numel(f)
    if ~isfield(opts, f{k}), opts.(f{k}) = d.(f{k}); end
end
if ~isfield(opts, 'T0'), opts.T0 = opts.Ta; end
if ~isfield(opts, 'A_ref')
    opts.A_ref = aging_update(P, aging_init(), [3*365, 180, 0]); % około 3 lata eksploatacji
end
dt = opts.dt;
A = opts.A;

% SOC na początku dojazdu dobrany tak, aby przy ładowarce wynosił około soc_plug
soc0 = opts.soc_plug + P.P_highway*opts.drive_s/3600/1000/(P.E_pack_kWh*A.SOH);
st = init_state(opts.T0, soc0, A.SOH);

n_drive = round(opts.drive_s/dt);
n_max   = n_drive + round(opts.t_max/dt);
L = nan(n_max, 13);
Sdrive = [0 0 0];
Scharge = [0 0 0];
lim_log = nan(n_max, 6);

seg_drive = struct('mode', 1, 'P_drive', P.P_highway, 'soc_target', 1, 'charge_en', 0, 'precond', 1);
seg_dc    = struct('mode', 2, 'P_drive', 0, 'soc_target', opts.soc_target, 'charge_en', 0, 'precond', 0);

k = 0;
for i = 1:n_drive
    k = k + 1;
    [st, L(k,:), S] = bms_step(P, Pc, cfg, st, seg_drive, opts.Ta, dt);
    Sdrive = Sdrive + S;
end
soc_plug = st.x(3);
st.z = 0;                       % reset integratora przy zmianie trybu
k_plug = k;
done = false;
for i = 1:round(opts.t_max/dt)
    k = k + 1;
    [~, lim_log(k,:)] = charge_controller(Pc, cfg, true, st.x(3), opts.soc_target, st.Tc_hat, st.x(4), st.SOH_hat, dt);
    [st, L(k,:), S] = bms_step(P, Pc, cfg, st, seg_dc, opts.Ta, dt);
    Scharge = Scharge + S;
    if st.x(3) >= opts.soc_target - 1e-4 || (i > 10 && L(k,1) <= 0)
        done = true;
        break
    end
end
L = L(1:k,:);
lim_log = lim_log(1:k,:);
t = ((1:k)' - k_plug)*dt;

ch = (k_plug+1):k;
Stot = Sdrive + Scharge;
A1 = aging_update(P, opts.A_ref, Stot);
A0 = aging_update(P, opts.A_ref, [0 0 0]);

res.strategy   = cfg.name;
res.Ta         = opts.Ta;
res.soc_plug   = soc_plug;
res.soc_end    = st.x(3);
res.done       = done;
res.t_charge_min = numel(ch)*dt/60;
res.Tc_max     = max(L(ch,3));
res.Tc_max_all = max(L(:,3));
res.Tc_min_charge = min(L(ch,3));
if k_plug > 0, res.Tc_plug = L(k_plug,3); else, res.Tc_plug = opts.T0; end
res.I_mean     = mean(L(ch,1));
res.E_TM_kWh   = sum(L(:,9))*dt/3.6e6;
res.E_TM_precond_kWh = sum(L(1:k_plug,9))*dt/3.6e6;
res.E_in_kWh   = sum(L(ch,1).*L(ch,6))*P.ns*dt/3.6e6;
res.phi_min_mV = 1000*min(L(ch,10));
res.Q_pl_ppm   = 1e6*Stot(3);
res.t_eq_days  = Stot(1);
res.FEC_eq     = Stot(2);
res.dQ_ppm     = 1e6*(A0.SOH - A1.SOH);
res.S          = Stot;

log.t = t; log.k_plug = k_plug;
log.I = L(:,1); log.u = L(:,2); log.Tc = L(:,3); log.Ts = L(:,4);
log.soc = L(:,5); log.V = L(:,6); log.Qgen = L(:,7); log.Qact = L(:,8);
log.Paux = L(:,9); log.phi = L(:,10); log.fpl = L(:,11); log.Tc_hat = L(:,12);
log.bal = L(:,13); log.lim = lim_log;
end
