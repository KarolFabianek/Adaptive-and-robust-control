%% Test odpornosci na niepewnosc parametrow (Ta = 35 C)
% Opor ogniw R +-15%, Gcs +-20%, Gcool +-20%, temperatura otoczenia +-3 C.
% 3*3*3*3 = 81 kombinacji x 2 strategie z nadzorem pradu = 162 symulacje.
clear; clc;

p0 = params();
R_mult = [0.85 1 1.15];
Gcs_mult = [0.8 1 1.2];
Gcool_mult = [0.8 1 1.2];
Ta_offset = [-3 0 3];

rows = {};
for r = R_mult
    for g1 = Gcs_mult
        for g2 = Gcool_mult
            for dTa = Ta_offset
                p = p0;
                p.Rn = p0.Rn*r;
                p.Gcs = p0.Gcs*g1;
                p.Gcool = p0.Gcool*g2;
                for st = {'PI_SAFE', 'GS_SAFE'}
                    res = simulate_charging(p, st{1}, 35 + dTa);
                    rows(end+1, :) = {string(st{1}), r, g1, g2, dTa, res.Tmax_C, res.time_min, res.status}; %#ok<SAGROW>
                end
            end
        end
    end
end

T = cell2table(rows, 'VariableNames', {'strategy', 'R_multiplier', 'Gcs_multiplier', ...
    'Gcool_multiplier', 'Ta_offset_C', 'Tmax_C', 'time_min', 'status'});
if ~isfolder('results'), mkdir('results'); end
writetable(T, 'results/robustness_35C.csv');

fprintf('Liczba symulacji: %d\n', height(T));
fprintf('Najwyzsza Tmax: %.2f C\n', max(T.Tmax_C));
fprintf('Przypadki z Tmax >= 40 C: %d\n', sum(T.Tmax_C >= 40));
fprintf('Najdluzsze ladowanie: %.1f min\n', max(T.time_min));

[~, iw] = max(T.Tmax_C);
fprintf('Najgorszy przypadek: %s, R x%.2f, Gcs x%.1f, Gcool x%.1f, Ta %+d C\n', ...
    T.strategy(iw), T.R_multiplier(iw), T.Gcs_multiplier(iw), T.Gcool_multiplier(iw), T.Ta_offset_C(iw));

figure('Color', 'w');
histogram(T.Tmax_C, 20);
xline(40, 'r--', 'limit 40 C');
grid on;
xlabel('T_{max} [C]');
ylabel('Liczba przypadkow');
title('Test odpornosci: rozklad T_{max} (162 symulacje)');
if ~isfolder('figures'), mkdir('figures'); end
exportgraphics(gcf, 'figures/robustness_Tmax.png', 'Resolution', 150);
