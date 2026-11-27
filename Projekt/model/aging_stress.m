function s = aging_stress(P, Tc, soc, I_cell, f_pl, dt)
%AGING_STRESS  Przyrosty stresu starzenia w jednym kroku symulacji.
%
%   s = aging_stress(P, Tc, soc, I_cell, f_pl, dt) zwraca wektor:
%     s(1)  dt_eq    dni starzenia kalendarzowego w warunkach odniesienia
%                    (25°C, SOC 50%), równoważne krokowi dt
%     s(2)  dFEC_eq  zastępcze pełne cykle w warunkach odniesienia (25°C, 1C)
%     s(3)  dQ_pl    trwała utrata pojemności przez litowanie [-]
%
%   Model półempiryczny według Schmalstiega i in. (2014), Waldmanna i in.
%   (2014) oraz Wanga i in. (2011):
%     Q_cal = k_cal (suma dt_eq)^0,75
%     Q_cyc = k_cyc (suma dFEC_eq)^0,5
%     Q_pl  = suma dQ_pl
%   Czynniki stresu przyspieszają upływ czasu zastępczego. Dzięki temu
%   model poprawnie sumuje okresy o różnej temperaturze i SOC.
TK  = Tc + 273.15;
TrK = P.T_ref_aging + 273.15;

% Starzenie kalendarzowe: prawo Arrheniusa i wpływ napięcia (SOC)
fT_cal = exp(-P.Ea_cal/P.Rgas*(1/TK - 1/TrK));
fV     = exp(P.alpha_V*(ocv_nmc(P, soc) - ocv_nmc(P, 0.5)));
dt_eq  = dt/86400*fT_cal*fV;

% Starzenie cykliczne: prawo Arrheniusa dla wzrostu warstwy SEI.
% Wzrost zużycia w niskiej temperaturze wynika z modelu litowania (dQ_pl).
fT_cyc = exp(P.Ea_cyc/P.Rgas*(1/TrK - 1/TK));
Crate = abs(I_cell)/P.Q_cell_Ah;
fC    = exp(P.b_C*(Crate - 1));
fS    = 1 + P.b_socc*max(0, soc - 0.8)/0.2;
dFEC  = abs(I_cell)*dt/3600/(2*P.Q_cell_Ah);
dFEC_eq = dFEC*fT_cyc*fC*fS;

% Litowanie: część prądu ładowania osadza lit, część tego litu traci się trwale
dQ_pl = P.eta_irr*f_pl*max(I_cell, 0)*dt/3600/P.Q_cell_Ah;

s = [dt_eq, dFEC_eq, dQ_pl];
end
