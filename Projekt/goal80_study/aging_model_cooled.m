function [soh, E_park] = aging_model_cooled(p, Tc_mean, I_peak, T_amb, soc_storage, T_cap, park_hours)
% Model starzenia jak aging_model.m, ale z chlodzeniem pakietu na postoju:
% gdy temperatura otoczenia przekracza T_cap, BTMS utrzymuje pakiet na T_cap.
% Dla T_cap = Inf wynik jest taki sam jak z aging_model.m.
%   T_amb      - srednia roczna temperatura otoczenia na postoju [C]
%   T_cap      - maksymalna temperatura pakietu na postoju [C]
%   park_hours - liczba godzin postoju na dobe
%   E_park     - energia chlodzenia na postoju [kWh/rok]

D_cal = 0;
D_cyc = 0;
E = 0;
res = zeros(120, 4);
k_I = 1 + 0.2*max(0, I_peak/p.Qah - 1);

for m = 1:120
    season = 7*sin(2*pi*(mod(m - 0.5, 12))/12);
    T_out = T_amb + season;
    T_park = min(T_out, T_cap);
    T_cyc = Tc_mean + season;

    d_sqrt = sqrt(m/12) - sqrt((m - 1)/12);
    D_cal = D_cal + p.k_cal*d_sqrt*exp(0.04*(T_park - 25))*exp(1.1*(soc_storage - 0.5));
    D_cyc = D_cyc + (p.sessions_per_year/12)*p.EFC_per_session*p.k_cyc*exp(0.03*(T_cyc - 25))*k_I;

    % energia chlodzenia na postoju: cieplo z otoczenia Gamb*(T_out - T_cap)
    if T_out > T_cap
        Q = p.Gamb*(T_out - T_cap);              % [W]
        u = Q/(p.Gcool*(T_cap - p.Tcool));       % potrzebne sterowanie chlodzeniem
        P = Q/p.COP + p.P_pump*u^3;              % chiller + pompa [W]
        E = E + P*park_hours*(365/12)/1000;      % [kWh] w miesiacu
    end

    res(m,:) = [m/12, 100*max(0, 1 - D_cal - D_cyc), 100*D_cal, 100*D_cyc];
end

soh = array2table(res, 'VariableNames', {'years','SOH_pct','Dcal_pp','Dcyc_pp'});
E_park = E/10;   % srednio na rok
end
