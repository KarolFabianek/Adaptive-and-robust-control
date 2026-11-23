function soh = aging_model(p, Tc_mean, I_peak, T_storage, soc_storage)
% Prosty model starzenia na 10 lat (120 miesiecy).
% Starzenie kalendarzowe ~ sqrt(t), zalezy od temperatury i SOC postoju.
% Starzenie cykliczne liniowe, zalezy od temperatury podczas ladowania i pradu.
% Temperatura zmienia sie sezonowo +-7 C.
%   Tc_mean     - srednia temperatura rdzenia podczas ladowania [C]
%   I_peak      - maksymalny prad ladowania [A]
%   T_storage   - srednia roczna temperatura postoju [C]
%   soc_storage - SOC postoju (0..1)

D_cal = 0;
D_cyc = 0;
res = zeros(120, 4);
k_I = 1 + 0.2*max(0, I_peak/p.Qah - 1);   % wiekszy prad (C-rate > 1) = szybsze starzenie

for m = 1:120
    season = 7*sin(2*pi*(mod(m - 0.5, 12))/12);
    T_park = T_storage + season;
    T_cyc = Tc_mean + season;

    d_sqrt = sqrt(m/12) - sqrt((m - 1)/12);
    D_cal = D_cal + p.k_cal*d_sqrt*exp(0.04*(T_park - 25))*exp(1.1*(soc_storage - 0.5));
    D_cyc = D_cyc + (p.sessions_per_year/12)*p.EFC_per_session*p.k_cyc*exp(0.03*(T_cyc - 25))*k_I;

    res(m,:) = [m/12, 100*max(0, 1 - D_cal - D_cyc), 100*D_cal, 100*D_cyc];
end

soh = array2table(res, 'VariableNames', {'years','SOH_pct','Dcal_pp','Dcyc_pp'});
end
