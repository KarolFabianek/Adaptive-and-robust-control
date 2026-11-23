%% Cel: SOH >= 80% po 10 latach - w jakich warunkach postoju jest spelniony?
% Szybkie ladowanie GS_LIFE przy Ta = 35 C (300 sesji/rok).
% Zmieniamy srednia roczna temperature postoju i SOC postoju.
% Uwaga: srednia roczna 35 C to rekord swiata (Dallol, ok. 34.6 C),
% typowy goracy klimat to 25-30 C.
clear; clc; close all;
p = params();

[res, data] = simulate_charging(p, 'GS_LIFE', 35);
Tc_mean = mean(data.Tc_C);
I_peak = max(data.I_A);
fprintf('Ladowanie GS_LIFE przy 35 C: Tmax = %.2f C, czas = %.1f min\n', res.Tmax_C, res.time_min);

park_T = [35 30 27 25 23 20];
park_SOC = [0.78 0.5 0.4];

rows = [];
for Tst = park_T
    for soc = park_SOC
        soh = aging_model(p, Tc_mean, I_peak, Tst, soc);
        rows = [rows; Tst, soc, soh.SOH_pct(end), soh.Dcal_pp(end), soh.Dcyc_pp(end)]; %#ok<AGROW>
    end
end
T = array2table(rows, 'VariableNames', {'storage_temperature_C', 'storage_SOC', ...
    'SOH_10y_pct', 'Dcal_pp', 'Dcyc_pp'});
T.meets_80 = T.SOH_10y_pct >= 80;
if ~isfolder('results'), mkdir('results'); end
writetable(T, 'results/goal80.csv');
disp(T);

% najwyzsza temperatura postoju, przy ktorej cel jest spelniony
for soc = park_SOC
    ok = T.storage_temperature_C(T.meets_80 & T.storage_SOC == soc);
    if isempty(ok)
        fprintf('SOC postoju %2.0f%%: cel niespelniony w calym zakresie 20-35 C\n', 100*soc);
    else
        fprintf('SOC postoju %2.0f%%: cel spelniony dla temperatury postoju <= %d C\n', 100*soc, max(ok));
    end
end

%% Wykres SOH w czasie dla dwoch klimatow (postoj 50% SOC)
hot = aging_model(p, Tc_mean, I_peak, 35, 0.5);
warm = aging_model(p, Tc_mean, I_peak, 25, 0.5);
fprintf('\nPostoj 35 C / 50%%: SOH po 10 latach = %.2f%%\n', hot.SOH_pct(end));
fprintf('Postoj 25 C / 50%%: SOH po 10 latach = %.2f%%\n', warm.SOH_pct(end));

figure('Color', 'w', 'Position', [100 100 900 420]);
plot(hot.years, hot.SOH_pct, 'LineWidth', 2); hold on;
plot(warm.years, warm.SOH_pct, 'LineWidth', 2);
yline(80, 'r--', 'cel 80%');
grid on;
ylim([70 100]);
xlabel('Czas eksploatacji [lata]');
ylabel('SOH [%]');
title('SOH po 10 latach - GS\_LIFE, ladowanie przy 35 C, postoj 50% SOC');
legend('postoj srednio 35 C (rekordowy klimat)', 'postoj srednio 25 C (goracy klimat)', ...
    'Location', 'southwest');
if ~isfolder('figures'), mkdir('figures'); end
exportgraphics(gcf, 'figures/goal80.png', 'Resolution', 150);
