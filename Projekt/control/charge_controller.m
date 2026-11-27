function [I_pack, lim] = charge_controller(P, cfg, is_dc, soc, soc_target, Tc_hat, V1, SOH_hat, dt)
%CHARGE_CONTROLLER  Zadany prąd ładowania pakietu [A] jako minimum kilku limitów.
%
%   [I_pack, lim] = charge_controller(P, cfg, is_dc, soc, soc_target, Tc_hat, V1, SOH_hat, dt)
%
%   I = min(I_baza, I_profil, I_term, I_tablica, I_anoda, I_CV)
%
%   I_baza     limit ładowarki: prąd DC stacji albo moc wallboxa podzielona przez napięcie
%   I_profil   profil z wykładu: redukcja prądu od 70% SOC do 130 A przy 80% SOC
%   I_term     nadzór termiczny: od 300 A przy 36,5°C do 110 A przy 39,5°C
%   I_tablica  dopuszczalny prąd w funkcji temperatury z typowego BMS
%   I_anoda    największy prąd, przy którym potencjał anody
%              phi = U_an(SOC) - I R_an(T, SOH) pozostaje nad zapasem phi_margin.
%              Limit maleje w niskiej temperaturze, przy wysokim SOC
%              i wraz ze starzeniem baterii, bo wtedy rośnie R_an.
%   I_CV       faza stałego napięcia, napięcie ogniwa nie przekracza Vmax
%
%   lim zwraca wszystkie limity [A], co pozwala sprawdzić, który jest aktywny.

if soc >= soc_target
    I_pack = 0; lim = zeros(1, 6); return
end
ocv = ocv_nmc(P, soc);
Qp  = P.Q_pack_Ah*SOH_hat;

% Limit ładowarki
if is_dc
    I_base = cfg.I_cap;
else
    I_base = P.P_ac/(P.ns*ocv);
end
% Profil SOC z wykładu
I_prof = Inf;
if cfg.taper && is_dc
    f = min(1, max(0, (soc - P.soc_taper)/(P.soc_dc_end - P.soc_taper)));
    I_prof = P.I_dc_max*(1 - f) + P.I_taper*f;
end
% Nadzór termiczny
I_term = Inf;
if cfg.derate
    fT = min(1, max(0, (Tc_hat - P.T_derate_start)/(P.T_derate_full - P.T_derate_start)));
    I_term = P.I_dc_max - (P.I_dc_max - P.I_dc_derated)*fT;
end
% Tablica typowego BMS
I_tab = Inf;
if cfg.std_table
    I_tab = lin_interp(P.std_T, P.std_C, Tc_hat)*Qp;
end
% Limit z potencjału anody
[R0, R1, R_an] = cell_resistance(P, Tc_hat, soc, SOH_hat);
I_an = Inf;
if cfg.plating
    I_an = max(0, P.np*(anode_ocp(P, soc) - P.phi_margin)/R_an);
end
% Faza stałego napięcia
a = exp(-dt/P.tau1);
I_cv = max(0, P.np*(cfg.Vmax - ocv - V1*a)/(R0 + R1*(1 - a)));
% Ostatni krok nie może przekroczyć docelowego SOC
I_soc = (soc_target - soc)*Qp*3600/dt;

lim = [I_base, I_prof, I_term, I_tab, I_an, I_cv];
I_pack = max(0, min([lim, I_soc]));
% Koniec ładowania w fazie CV, gdy prąd spada poniżej C/20
if I_cv < I_base && I_pack < P.I_cutoff_C*Qp && I_pack == I_cv
    I_pack = 0;
end
end
