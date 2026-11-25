function U = anode_ocp(P, soc)
%ANODE_OCP  Potencjał równowagowy anody grafitowej względem Li/Li+ [V].
%   Aproksymacja dla grafitu MCMB (Doyle i in. 1996; stosowana m.in. przez
%   Ramadass i in. 2004). x – stopień zlitowania anody, liniowo zależny
%   od SOC ogniwa: x = x0 + SOC (x100 - x0).
%
%   Ciekawostka: przy wysokim SOC potencjał anody spada do ok. 80–90 mV,
%   więc niewielki spadek napięcia I*R_an wystarcza, by zejść poniżej 0 V
%   i rozpocząć osadzanie metalicznego litu (Li plating).
x = P.x0 + min(max(soc, 0), 1)*(P.x100 - P.x0);
x = max(x, 0.01);
U = 0.7222 + 0.1387*x + 0.029*sqrt(x) - 0.0172/x + 0.0019/x^1.5 ...
    + 0.2808*exp(0.90 - 15*x) - 0.7984*exp(0.4465*x - 0.4108);
end
