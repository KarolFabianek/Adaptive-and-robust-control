function [Pp, d] = perturb_params(P, rs)
%PERTURB_PARAMS  Losowanie parametrów „rzeczywistego” pakietu (Monte Carlo).
%
%   Regulator zna tylko wartości nominalne P; obiekt ma parametry Pp.
%   Rozrzuty (1 sigma lub zakres) odpowiadają typowej niepewności
%   modeli starzenia i rozrzutowi produkcyjnemu:
%     k_cal, k_cyc  x lognormal(0, 0.30)   – największa niepewność
%     Ea_cal        x N(1, 0.05)
%     R0, R1, R_an  x U(0.85, 1.15)
%     Gcs, Gcool    x U(0.80, 1.20)
%     k_pl          x U(0.5, 2.0)
%     dT_amb        U(-2, +2) K            – inny rok / mikroklimat
%     z_cyc         {0.5, 1.0} z p. 50%    – niepewność STRUKTURY modelu:
%                   pierwiastkowa vs liniowa degradacja cykliczna (dane NASA
%                   B0005 wskazują raczej na przebieg liniowy, E08); k_cyc
%                   przeskalowane tak, by 1000 FEC dawało tę samą utratę
d.k_cal = exp(0.30*randn(rs));
d.k_cyc = exp(0.30*randn(rs));
d.Ea_cal = 1 + 0.05*randn(rs);
d.R = 0.85 + 0.30*rand(rs);
d.G = 0.80 + 0.40*rand(rs);
d.k_pl = 0.5 + 1.5*rand(rs);
d.dT_amb = -2 + 4*rand(rs);
d.z_cyc = 0.5 + 0.5*(rand(rs) < 0.5);
Pp = P;
Pp.k_cal = P.k_cal*d.k_cal;
Pp.z_cyc = d.z_cyc;
Pp.k_cyc = P.k_cyc*1000^(P.z_cyc - d.z_cyc)*d.k_cyc;
Pp.Ea_cal = P.Ea_cal*d.Ea_cal;
Pp.R0_ref = P.R0_ref*d.R; Pp.R1_ref = P.R1_ref*d.R; Pp.R_an_ref = P.R_an_ref*d.R;
Pp.Gcs = P.Gcs*d.G; Pp.Gcool = P.Gcool*d.G;
Pp.k_pl = P.k_pl*d.k_pl;
Pp = bms_derive(Pp);
end
