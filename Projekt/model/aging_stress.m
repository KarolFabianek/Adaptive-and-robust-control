function s = aging_stress(P, Tc, soc, I_cell, f_pl, dt)
%AGING_STRESS  Przyrosty „zastępczego czasu” i „zastępczych cykli” w kroku dt.
%
%   s = aging_stress(P, Tc, soc, I_cell, f_pl, dt) zwraca wektor
%     s(1) dt_eq   – dni starzenia kalendarzowego przy warunkach odniesienia
%                    (25°C, SOC 50%), równoważne krokowi dt
%     s(2) dFEC_eq – pełne cykle zastępcze (FEC) przy 25°C i 1C
%     s(3) dQ_pl   – nieodwracalna utrata pojemności przez litowanie [-]
%
%   Model półempiryczny (struktura wg Schmalstieg i in. 2014, Waldmann
%   i in. 2014, Wang i in. 2011):
%     Q_cal = k_cal * (sum dt_eq)^0.75
%     Q_cyc = k_cyc * (sum dFEC_eq)^0.5
%     Q_pl  = sum dQ_pl
%   Czynniki stresu działają jak „przyspieszenie czasu” (metoda czasu
%   zastępczego), dzięki czemu model poprawnie sumuje okresy o różnej
%   temperaturze i SOC.
TK  = Tc + 273.15;
TrK = P.T_ref_aging + 273.15;

% --- kalendarzowe: Arrhenius x wpływ napięcia (SOC) ---
fT_cal = exp(-P.Ea_cal/P.Rgas*(1/TK - 1/TrK));
fV     = exp(P.alpha_V*(ocv_nmc(P, soc) - ocv_nmc(P, 0.5)));
dt_eq  = dt/86400*fT_cal*fV;

% --- cykliczne: Arrhenius wzrostu SEI (maleje w zimnie, rośnie w cieple) ---
% Wzrost zużycia w niskiej temperaturze (lewe ramię „V”, Waldmann 2014)
% NIE jest tu wpisany – wynika jawnie z modelu litowania (dQ_pl poniżej).
fT_cyc = exp(P.Ea_cyc/P.Rgas*(1/TrK - 1/TK));
Crate = abs(I_cell)/P.Q_cell_Ah;
fC    = exp(P.b_C*(Crate - 1));
fS    = 1 + P.b_socc*max(0, soc - 0.8)/0.2;
dFEC  = abs(I_cell)*dt/3600/(2*P.Q_cell_Ah);
dFEC_eq = dFEC*fT_cyc*fC*fS;

% --- litowanie: część prądu ładowania osadza lit, część traci się trwale ---
dQ_pl = P.eta_irr*f_pl*max(I_cell, 0)*dt/3600/P.Q_cell_Ah;

s = [dt_eq, dFEC_eq, dQ_pl];
end
