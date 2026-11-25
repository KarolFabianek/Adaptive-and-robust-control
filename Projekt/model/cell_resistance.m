function [R0, R1, R_an] = cell_resistance(P, T_c, soc, SOH)
%CELL_RESISTANCE  Rezystancje modelu ECM ogniwa [Ohm].
%   [R0, R1, R_an] = cell_resistance(P, T_c, soc, SOH)
%     T_c  – temperatura rdzenia [°C]
%     soc  – stan naładowania 0..1
%     SOH  – stan zdrowia (pojemność względna) 0..1
%
%   R(T)   : prawo Arrheniusa, R = R_ref exp(Ea/R_gas (1/T - 1/T_ref))
%   R(SOC) : jak na wykładzie, 1 + 0.2 (0.5 - SOC)
%   R(SOH) : wzrost rezystancji wraz ze starzeniem, 1 + gamma_R (1 - SOH)
%   R_an   : rezystancja „widziana” przez anodę (decyduje o litowaniu)
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
