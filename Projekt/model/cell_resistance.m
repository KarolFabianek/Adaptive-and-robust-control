function [R0, R1, R_an] = cell_resistance(P, T_c, soc, SOH)
%CELL_RESISTANCE  Rezystancje modelu zastępczego ogniwa [Ohm].
%   [R0, R1, R_an] = cell_resistance(P, T_c, soc, SOH)
%     T_c   temperatura rdzenia [°C]
%     soc   stan naładowania od 0 do 1
%     SOH   stan zdrowia (pojemność względna) od 0 do 1
%
%   Zależność od temperatury:  R = R_ref exp(Ea/R_gas (1/T - 1/T_ref))
%   Zależność od SOC:          1 + 0,2 (0,5 - SOC), jak na wykładzie
%   Zależność od SOH:          1 + gamma_R (1 - SOH)
%   R_an to rezystancja po stronie anody, która decyduje o litowaniu.
TK  = T_c + 273.15;
TrK = 25 + 273.15;
fT  = exp(P.Ea_R/P.Rgas*(1/TK - 1/TrK));
fT  = min(max(fT, 0.3), 12);
fS  = 1 + P.kR_soc*(0.5 - soc);
fA  = 1 + P.gamma_R*(1 - SOH);
R0  = P.R0_ref*fT*fS*fA;
R1  = P.R1_ref*fT*fS*fA;
fTa = exp(P.Ea_an/P.Rgas*(1/TK - 1/TrK));
fTa = min(max(fTa, 0.2), 60);
R_an = P.R_an_ref*fTa*fA;
end
