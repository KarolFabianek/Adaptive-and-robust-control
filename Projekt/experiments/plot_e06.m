function plot_e06(climate)
%PLOT_E06  Wykresy eksperymentu E06 z plików results/e06_monte_carlo_*.csv.
%   Lewy wykres: rozkład SOH po 10 latach dla trzech strategii.
%   Prawy wykres: SOH tego samego pakietu przy typowym BMS i przy LIFE-ADAPT.
if nargin < 1, climate = 'madryt'; end
S = plot_style();
root = fileparts(fileparts(mfilename('fullpath')));
R = readtable(fullfile(root, 'results', sprintf('e06_monte_carlo_%s.csv', climate)));
st = readtable(fullfile(root, 'results', sprintf('e06_monte_carlo_stats_%s.csv', climate)), 'TextType', 'char');
strategies = {'STD_90', 'LIFE', 'LIFE_ADAPT'};
num = @(x, n) strrep(sprintf(['%.' num2str(n) 'f'], x), '.', ',');
N = height(R);

fig = figure('Position', [60 60 1250 480]);
tl = tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
title(tl, sprintf('Odporność na niepewność modelu starzenia: %d losowych pakietów, klimat %s', ...
    N, climate_profile(climate).name), 'FontWeight', 'bold', 'FontSize', 14);

nexttile; hold on
edges = 66:1:94;
for s = 1:numel(strategies)
    x = R.(['SOH10_' strategies{s}]);
    histogram(x, edges, 'DisplayStyle', 'stairs', 'LineWidth', 2.2, 'EdgeColor', S.col(strategies{s}), ...
        'DisplayName', sprintf('%s: %s%% pakietów \\geq 80%%, \\sigma = %s p.p.', S.short(strategies{s}), ...
        num(st.P_meet_80_pct(s), 0), num(st.SOH_std_pp(s), 1)));
end
xline(80, '--', '80%', 'Color', S.red, 'LineWidth', 1.5, 'LabelVerticalAlignment', 'bottom', ...
    'HandleVisibility', 'off');
yl = ylim; ylim([0 1.45*yl(2)]);
xlabel('SOH po 10 latach [%]'); ylabel('Liczba pakietów');
legend('Location', 'northwest');
title('Rozkład SOH po 10 latach');

nexttile; hold on
x = R.SOH10_STD_90; y = R.SOH10_LIFE_ADAPT;
lim = [66 94];
fill([lim(1) 80 80 lim(1)], [80 80 lim(2) lim(2)], S.green, 'FaceAlpha', 0.08, 'EdgeColor', 'none', ...
    'HandleVisibility', 'off');
plot(lim, lim, ':', 'Color', S.grey, 'LineWidth', 1.5, 'DisplayName', 'ten sam wynik');
scatter(x, y, 45, S.green, 'filled', 'MarkerFaceAlpha', 0.8, 'DisplayName', 'pakiet');
xline(80, '--', 'Color', S.red, 'LineWidth', 1.5, 'HandleVisibility', 'off');
yline(80, '--', 'Color', S.red, 'LineWidth', 1.5, 'HandleVisibility', 'off');
text(70, 91, sprintf('%d pakietów: STD-90 < 80%%,\nLIFE-ADAPT \\geq 80%%', nnz(x < 80 & y >= 80)), ...
    'FontSize', 11, 'Color', S.green);
xlim(lim); ylim(lim); axis square
xlabel('SOH po 10 latach, STD-90 [%]'); ylabel('SOH po 10 latach, LIFE-ADAPT [%]');
legend('Location', 'southeast');
title('Ten sam pakiet przy dwóch strategiach');
save_fig(fig, sprintf('e06_monte_carlo_%s', climate));
end
