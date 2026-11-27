function [Pp, d] = perturb_params(P, rs)
%PERTURB_PARAMS  Losowanie parametrów pakietu w analizie Monte Carlo.
%
%   Regulator zna tylko wartości nominalne P, a obiekt ma parametry Pp.
%   Rozrzuty odpowiadają typowej niepewności modeli starzenia i rozrzutowi
%   produkcyjnemu:
%     k_cal, k_cyc   mnożnik o rozkładzie logarytmiczno-normalnym, sigma 0,3
%     Ea_cal         mnożnik o rozkładzie normalnym, 1 +/- 0,05
%     R0, R1, R_an   mnożnik równomierny od 0,85 do 1,15
%     Gcs, Gcool     mnożnik równomierny od 0,80 do 1,20
%     k_pl           mnożnik równomierny od 0,5 do 2
%     dT_amb         przesunięcie klimatu równomierne od -2 do +2 K
%     z_cyc          0,5 albo 1 z prawdopodobieństwem 50%, czyli niepewność
%                    kształtu degradacji cyklicznej (dane NASA B0005 wskazują
%                    na przebieg liniowy, E08). k_cyc jest przeskalowane tak,
%                    aby 1000 cykli dawało tę samą utratę pojemności.
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
