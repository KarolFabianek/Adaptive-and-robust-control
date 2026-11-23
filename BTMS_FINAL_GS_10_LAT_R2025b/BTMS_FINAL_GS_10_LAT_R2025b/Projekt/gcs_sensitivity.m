%% Wrazliwosc wynikow na przewodnosc cieplna rdzen-powierzchnia Gcs (Ta = 35 C)
% Gcs = 1650 W/K to wartosc bazowa (ok. 2.9 K/W na ogniwo 18650).
% Siatka obejmuje tez 165 W/K (ok. 29 K/W na ogniwo), ktore bylo w pierwszej wersji.
clear; clc; close all;
p0 = params();
n_cells = p0.ns*p0.np;

Gcs_values = [165 330 660 1650 2600];
strategies = {'CC', 'PI', 'GS', 'GS_SAFE', 'GS_LIFE'};

rows = {};
Tmax = zeros(numel(Gcs_values), numel(strategies));
for i = 1:numel(Gcs_values)
    p = p0;
    p.Gcs = Gcs_values(i);
    for j = 1:numel(strategies)
        res = simulate_charging(p, strategies{j}, 35);
        Tmax(i, j) = res.Tmax_C;
        rows(end+1, :) = {p.Gcs, n_cells/p.Gcs, string(strategies{j}), res.Tmax_C, ...
            res.time_min, res.energy_aux_kWh, res.Tmax_C < p.Tlim}; %#ok<SAGROW>
    end
end

T = cell2table(rows, 'VariableNames', {'Gcs_W_per_K', 'Rth_cell_K_per_W', 'strategy', ...
    'Tmax_C', 'time_min', 'energy_aux_kWh', 'below_40C'});
if ~isfolder('results'), mkdir('results'); end
writetable(T, 'results/gcs_sensitivity.csv');

disp(array2table(round(Tmax, 2), 'VariableNames', strategies, ...
    'RowNames', cellstr(compose('Gcs = %d W/K', Gcs_values))));

figure('Color', 'w');
semilogx(Gcs_values, Tmax, 'o-', 'LineWidth', 1.5);
yline(40, 'r--', 'limit 40 C');
grid on;
xlabel('G_{cs} [W/K]');
ylabel('T_{max} [C]');
title('Wplyw G_{cs} na maksymalna temperature rdzenia (T_a = 35 C)');
legend(strrep(strategies, '_', '\_'), 'Location', 'northeast');
if ~isfolder('figures'), mkdir('figures'); end
exportgraphics(gcf, 'figures/gcs_sensitivity.png', 'Resolution', 150);
