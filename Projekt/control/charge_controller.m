function [I_pack, lim] = charge_controller(P, cfg, is_dc, soc, soc_target, Tc_hat, V1, SOH_hat, dt)
%CHARGE_CONTROLLER  Zadany prąd ładowania pakietu [A] – warstwowy nadzór.
%
%   [I_pack, lim] = charge_controller(P, cfg, is_dc, soc, soc_target, Tc_hat, V1, SOH_hat, dt)
%
%   I = min( I_baza, I_profil(SOC), I_term(Tc), I_tablica(Tc), I_anoda, I_CV )
%
%   I_baza     – DC: limit stacji / pakietu (I_cap), AC: moc wallboxa / U
%   I_profil   – profil STD z wykładu: redukcja od 70% SOC do 130 A przy 80%
%   I_term     – nadzór termiczny (36.5 -> 39.5°C: 300 -> 110 A)
%   I_tablica  – typowa statyczna tablica BMS C_max(T) (ochrona na zimno)
%   I_anoda    – PROPONOWANY limit „bez litowania”: największy prąd, przy
%                którym potencjał anody phi = U_an(SOC) - I R_an(T, SOH)
%                pozostaje >= phi_margin. Limit sam maleje przy niskiej
%                temperaturze, wysokim SOC i starzeniu (R_an rośnie),
%                więc adaptuje się do stanu baterii.
%   I_CV       – faza stałego napięcia: U_ogniwa <= Vmax
%
%   lim – wektor wszystkich limitów [A] (do analizy, który z nich jest aktywny).

if soc >= soc_target
    I_pack = 0; lim = zeros(1, 6); return
end
ocv = ocv_nmc(P, soc);
Qp  = P.Q_pack_Ah*SOH_hat;

% baza
if is_dc
    I_base = cfg.I_cap;
else
    I_base = P.P_ac/(P.ns*ocv);
end
% profil SOC (STD / wykład)
I_prof = Inf;
if cfg.taper && is_dc
    f = min(1, max(0, (soc - P.soc_taper)/(P.soc_dc_end - P.soc_taper)));
    I_prof = P.I_dc_max*(1 - f) + P.I_taper*f;
end
% nadzór termiczny
I_term = Inf;
if cfg.derate
    fT = min(1, max(0, (Tc_hat - P.T_derate_start)/(P.T_derate_full - P.T_derate_start)));
    I_term = P.I_dc_max - (P.I_dc_max - P.I_dc_derated)*fT;
end
% tablica statyczna C_max(T)
I_tab = Inf;
if cfg.std_table
    I_tab = lin_interp(P.std_T, P.std_C, Tc_hat)*Qp;
end
% limit z potencjału anody (model-based, adaptacyjny)
[R0, R1, R_an] = cell_resistance(P, Tc_hat, soc, SOH_hat);
I_an = Inf;
if cfg.plating
    I_an = max(0, P.np*(anode_ocp(P, soc) - P.phi_margin)/R_an);
end
% faza CV
a = exp(-dt/P.tau1);
I_cv = max(0, P.np*(cfg.Vmax - ocv - V1*a)/(R0 + R1*(1 - a)));
% nie przekraczamy SOC docelowego w ostatnim kroku
I_soc = (soc_target - soc)*Qp*3600/dt;

lim = [I_base, I_prof, I_term, I_tab, I_an, I_cv];
I_pack = max(0, min([lim, I_soc]));
% koniec ładowania w fazie CV (I < C/20) – sygnalizowany zerem
if I_cv < I_base && I_pack < P.I_cutoff_C*Qp && I_pack == I_cv
    I_pack = 0;
end
end
