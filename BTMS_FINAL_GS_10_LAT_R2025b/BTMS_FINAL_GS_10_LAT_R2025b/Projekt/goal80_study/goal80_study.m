%% Jak osiagnac SOH >= 80% po 10 latach przy sredniej temperaturze 35 C?
% Punkt wyjscia (goal80_analysis.m): GS_LIFE, ladowanie przy 35 C, postoj 35 C / 50% SOC
% -> 77.1%. Sprawdzamy trzy grupy zmian:
%   1) samo ladowanie: nizsza temperatura zadana Tref i nizszy limit pradu GS_LIFE,
%   2) postoj: nizszy SOC postoju i chlodzenie pakietu na postoju (T_cap),
%   3) trzy warianty laczace obie grupy - z kosztem (czas ladowania, energia).
% Zalozenia: 300 szybkich ladowan/rok przy 35 C, postoj 20 h/dobe,
% ladowanie zawsze startuje od temperatury otoczenia (zachowawczo).
clear; clc; close all;
addpath(fullfile(pwd, '..'));    % funkcje modelu z folderu Projekt

p0 = params();
Ta = 35;             % temperatura otoczenia (ladowanie i postoj)
park_hours = 20;     % godziny postoju na dobe

if ~isfolder('results'), mkdir('results'); end
if ~isfolder('figures'), mkdir('figures'); end

%% 0. Punkt wyjscia
[res0, d0] = simulate_charging(p0, 'GS_LIFE', Ta);
soh0 = aging_model(p0, mean(d0.Tc_C), max(d0.I_A), Ta, 0.5);
E_charge0 = res0.energy_aux_kWh*p0.sessions_per_year;     % chlodzenie przy ladowaniu [kWh/rok]
fprintf('Punkt wyjscia GS_LIFE (Tref 30 C, 210 A, postoj 50%% SOC): SOH = %.2f%%\n', soh0.SOH_pct(end));

%% 1. Samo ladowanie: Tref i limit pradu
Tref_list = [30 28 26 24 22];
Icap_list = [210 175 150];
rows = [];
for Tref = Tref_list
    for Icap = Icap_list
        p = p0;
        p.Tref = Tref;
        p.I_life = Icap;
        [res, d] = simulate_charging(p, 'GS_LIFE', Ta);
        s50 = aging_model(p, mean(d.Tc_C), max(d.I_A), Ta, 0.5);
        s40 = aging_model(p, mean(d.Tc_C), max(d.I_A), Ta, 0.4);
        rows = [rows; Tref, Icap, res.Tmax_C, mean(d.Tc_C), res.time_min, ...
            res.energy_aux_kWh, res.sat_fraction, s50.SOH_pct(end), s40.SOH_pct(end)]; %#ok<AGROW>
    end
end
charging = array2table(rows, 'VariableNames', {'Tref_C', 'I_cap_A', 'Tmax_C', 'Tc_mean_C', ...
    'time_min', 'energy_aux_kWh', 'sat_fraction', 'SOH_park50_pct', 'SOH_park40_pct'});
writetable(charging, 'results/charging_sweep.csv');
fprintf('\n1) Samo ladowanie (postoj bez chlodzenia):\n');
disp(charging(:, {'Tref_C', 'I_cap_A', 'Tc_mean_C', 'time_min', 'sat_fraction', 'SOH_park50_pct', 'SOH_park40_pct'}));
fprintf('Najlepszy wynik przy postoju 50%% SOC: %.2f%% -> samo ladowanie nie wystarcza.\n', ...
    max(charging.SOH_park50_pct));

%% 2. Postoj: SOC i chlodzenie pakietu na postoju (ladowanie jak w punkcie wyjscia)
Tcap_list = [Inf 34 32 30 28 26];
soc_list = [0.5 0.4];
rows = [];
for soc = soc_list
    for Tcap = Tcap_list
        [s, E_park] = aging_model_cooled(p0, mean(d0.Tc_C), max(d0.I_A), Ta, soc, Tcap, park_hours);
        rows = [rows; soc, Tcap, s.SOH_pct(end), s.Dcal_pp(end), E_park]; %#ok<AGROW>
    end
end
parking = array2table(rows, 'VariableNames', {'park_SOC', 'T_cap_C', 'SOH_10y_pct', 'Dcal_pp', 'E_park_kWh_per_year'});
writetable(parking, 'results/parking_sweep.csv');
fprintf('\n2) Postoj (ladowanie GS_LIFE bez zmian, T_cap = Inf oznacza brak chlodzenia):\n');
disp(parking);

%% 3. Warianty
% W1 - bez chlodzenia na postoju: Tref 24 C, 175 A, postoj 40% SOC
% W2 - tylko chlodzenie na postoju do 28 C, ladowanie bez zmian, postoj 50% SOC
% W3 - kompromis: Tref 26 C, 175 A, chlodzenie na postoju do 32 C, postoj 50% SOC
names = {'W0 punkt wyjscia', 'W1 Tref 24 C, 175 A, SOC 40%', 'W2 postoj <= 28 C', 'W3 Tref 26 C, 175 A, postoj <= 32 C'};
Tref_v = [30 24 30 26];
Icap_v = [210 175 210 175];
soc_v  = [0.5 0.4 0.5 0.5];
Tcap_v = [Inf Inf 28 32];

nv = numel(names);
SOH = zeros(nv,1); t_ch = SOH; Tmax = SOH; Tmax_worst = SOH; E_ch = SOH; E_pk = SOH;
curves = cell(nv,1);
for i = 1:nv
    p = p0;
    p.Tref = Tref_v(i);
    p.I_life = Icap_v(i);
    [res, d] = simulate_charging(p, 'GS_LIFE', Ta);
    [s, E_park] = aging_model_cooled(p, mean(d.Tc_C), max(d.I_A), Ta, soc_v(i), Tcap_v(i), park_hours);
    SOH(i) = s.SOH_pct(end);
    t_ch(i) = res.time_min;
    Tmax(i) = res.Tmax_C;
    E_ch(i) = res.energy_aux_kWh*p.sessions_per_year;
    E_pk(i) = E_park;
    curves{i} = s;

    % ten sam test niepewnosci co w robustness_test.m (81 przypadkow)
    Tw = 0;
    for r = [0.85 1 1.15]
        for g1 = [0.8 1 1.2]
            for g2 = [0.8 1 1.2]
                for dTa = [-3 0 3]
                    pu = p;
                    pu.Rn = p.Rn*r; pu.Gcs = p.Gcs*g1; pu.Gcool = p.Gcool*g2;
                    ru = simulate_charging(pu, 'GS_LIFE', Ta + dTa);
                    Tw = max(Tw, ru.Tmax_C);
                end
            end
        end
    end
    Tmax_worst(i) = Tw;
end
E_extra = E_ch + E_pk - E_charge0;

variants = table(string(names'), Tref_v', Icap_v', soc_v', Tcap_v', t_ch, Tmax, Tmax_worst, ...
    E_ch, E_pk, E_extra, SOH, SOH >= 80, 'VariableNames', {'variant', 'Tref_C', 'I_cap_A', 'park_SOC', ...
    'T_cap_C', 'time_min', 'Tmax_C', 'Tmax_worst_C', 'E_charge_kWh_y', 'E_park_kWh_y', ...
    'E_extra_kWh_y', 'SOH_10y_pct', 'meets_80'});
writetable(variants, 'results/variants.csv');
fprintf('\n3) Warianty:\n');
disp(variants);

E_year = p0.sessions_per_year*(p0.soc_end - p0.soc0)*p0.E_kWh;   % energia ladowana w roku
fprintf('Dla porownania: w roku laduje sie ok. %.0f kWh.\n', E_year);

%% Wykresy
figure('Color', 'w', 'Position', [100 100 900 450]);
hold on;
for i = 1:nv
    plot(curves{i}.years, curves{i}.SOH_pct, 'LineWidth', 1.8);
end
yline(80, 'r--', 'cel 80%');
grid on;
ylim([75 100]);
xlabel('Czas eksploatacji [lata]');
ylabel('SOH [%]');
title('SOH przy sredniej temperaturze 35 C - warianty');
legend(names, 'Location', 'northeast');
exportgraphics(gcf, 'figures/variants_soh.png', 'Resolution', 150);

figure('Color', 'w', 'Position', [120 120 900 450]);
hold on;
for Icap = Icap_list
    k = charging.I_cap_A == Icap;
    plot(charging.Tref_C(k), charging.SOH_park50_pct(k), 'o-', 'LineWidth', 1.5);
end
yline(80, 'r--', 'cel 80%');
grid on;
set(gca, 'XDir', 'reverse');
ylim([76.5 80.5]);
xlabel('Temperatura zadana T_{ref} [C]');
ylabel('SOH po 10 latach [%]');
title('Samo ladowanie (postoj 35 C / 50% SOC, bez chlodzenia)');
legend(cellstr(compose('limit %d A', Icap_list)), 'Location', 'northwest');
exportgraphics(gcf, 'figures/charging_sweep.png', 'Resolution', 150);

figure('Color', 'w', 'Position', [140 140 900 450]);
k = parking.park_SOC == 0.5 & isfinite(parking.T_cap_C);
yyaxis left
plot(parking.T_cap_C(k), parking.SOH_10y_pct(k), 'o-', 'LineWidth', 1.5);
ylabel('SOH po 10 latach [%]');
yline(80, 'r--', 'cel 80%');
yyaxis right
plot(parking.T_cap_C(k), parking.E_park_kWh_per_year(k), 's-', 'LineWidth', 1.5);
ylabel('Energia chlodzenia na postoju [kWh/rok]');
set(gca, 'XDir', 'reverse');
grid on;
xlabel('Maksymalna temperatura pakietu na postoju T_{cap} [C]');
title('Chlodzenie na postoju (ladowanie GS\_LIFE bez zmian, postoj 50% SOC)');
exportgraphics(gcf, 'figures/parking_cooling.png', 'Resolution', 150);
