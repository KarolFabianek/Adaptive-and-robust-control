function [st, rec, S] = bms_step(P, Pc, cfg, st, seg, Ta, dt)
%BMS_STEP  Jeden krok zamkniętego układu: regulatory + obserwator + pakiet + starzenie.
%
%   [st, rec, S] = bms_step(P, Pc, cfg, st, seg, Ta, dt)
%     P   – parametry OBIEKTU (rzeczywisty pakiet, np. zaburzony w Monte Carlo)
%     Pc  – parametry MODELU w regulatorze (nominalne)
%     cfg – strategia (strategy_config)
%     st  – stan: x=[Tc;Ts;SOC;V1], z (integrator PI), Tc_hat (obserwator),
%           guard_on (histereza chłodzenia na postoju), SOH (rzeczywiste),
%           SOH_hat (estymata dla regulatora), charging (flaga ładowania AC)
%     seg – tryb: seg.mode = 1 jazda, 2 ładowanie DC, 3 postój z wtyczką,
%           4 postój bez wtyczki; seg.P_drive [W]; seg.soc_target;
%           seg.charge_en (AC dozwolone); seg.precond (podgrzewanie przed DC)
%   rec = [I, u, Tc, Ts, SOC, V_cell, Q_gen, Q_act, P_aux, phi_an, f_pl, Tc_hat, bal]
%   S   = [dt_eq, dFEC_eq, dQ_pl]  (przyrosty stresu starzenia)

x = st.x;
soc = x(3);
I = 0; u = 0; P_extra = 0;
T_heat = -Inf;
Tref = 99;
run_thermal = false;

switch seg.mode
    case 1  % jazda
        I = -seg.P_drive/(P.ns*ocv_nmc(Pc, soc));
        if cfg.cool_mode >= 2
            run_thermal = true;
            Tref = cfg.Tref_drive;
            if seg.precond && cfg.precond
                Tref = min(Tref, P.Tref_charge - 2);
                T_heat = P.T_precond;
            end
        end
    case 2  % szybkie ładowanie DC
        I = charge_controller(Pc, cfg, true, soc, seg.soc_target, st.Tc_hat, x(4), st.SOH_hat, dt);
        run_thermal = true;
        Tref = P.Tref_charge;
        if cfg.precond
            T_heat = P.T_precond;
        end
    case 3  % postój z wtyczką (dom): ładowanie AC + ochrona termiczna
        if seg.charge_en
            I = charge_controller(Pc, cfg, false, soc, seg.soc_target, st.Tc_hat, x(4), st.SOH_hat, dt);
        end
        if cfg.park_guard
            if st.guard_on
                st.guard_on = st.Tc_hat > cfg.T_park_max - 1;
            else
                st.guard_on = st.Tc_hat > cfg.T_park_max + 1;
            end
            if st.guard_on
                u = 0.5;
                P_extra = P.P_standby;
            end
        end
    otherwise % postój bez wtyczki – układ uśpiony
end

% estymowane straty (model regulatora, stan ustalony R0+R1)
[R0c, R1c] = cell_resistance(Pc, st.Tc_hat, soc, st.SOH_hat);
Qgen_hat = P.ns*P.np*(I/P.np)^2*(R0c + R1c);

if run_thermal
    if cfg.cool_mode == 1 && seg.mode == 2
        u = cfg.cc_u;
    elseif cfg.cool_mode == 1
        u = 0;
    else
        [u, st.z] = thermal_controller(Pc, cfg, st.z, st.Tc_hat, x(2), Qgen_hat, Tref, T_heat, dt);
    end
end

[x_next, y] = pack_step(P, x, I, u, Ta, dt, st.SOH);
st.Tc_hat = core_observer(Pc, st.Tc_hat, x_next(2), Qgen_hat, dt);
S = aging_stress(P, 0.5*(x(1) + x_next(1)), soc, y(6), y(7), dt);
st.x = x_next;

rec = [I, u, x_next(1), x_next(2), x_next(3), y(1), y(2), y(3), y(4) + P_extra, ...
       y(5), y(7), st.Tc_hat, y(8)];
end
