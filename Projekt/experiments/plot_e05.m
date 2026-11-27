function plot_e05()
%PLOT_E05  Wykresy eksperymentu E05 z zapisanych wyników (results/e05_lifetime.mat).
%   Można wywołać osobno, bez ponownej symulacji 10 lat.
P = bms_params();
S = plot_style();
root = fileparts(fileparts(mfilename('fullpath')));
d = load(fullfile(root, 'results', 'e05_lifetime.mat'), 'Tall', 'Sum');
Tall = d.Tall; Sum = d.Sum;
strategies = {'STD_100','STD_90','LIFE','LIFE_ADAPT'};
climates = {'opole','madryt','dubaj'};
cname = @(c) climate_profile(c).name;
num = @(x, n) strrep(sprintf(['%.' num2str(n) 'f'], x), '.', ',');

%% SOH w ciągu 10 lat
fig = figure('Position', [60 60 1300 500]);
tl = tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
title(tl, 'Stan zdrowia baterii (SOH) w ciągu 10 lat eksploatacji', 'FontWeight', 'bold', 'FontSize', 14);
for c = 1:numel(climates)
    nexttile; hold on
    for s = 1:numel(strategies)
        T = Tall.(climates{c}).(strategies{s});
        plot([0; T.t_years], 100*[1; T.SOH], 'Color', S.col(strategies{s}), 'DisplayName', S.label(strategies{s}));
    end
    tt = linspace(0, 10, 100);
    plot(tt, 100*soh_reference(P, tt), ':', 'Color', S.navy, 'LineWidth', 2.5, ...
        'DisplayName', 'trajektoria odniesienia pętli SOH');
    yline(80, '--', '80%', 'Color', S.red, 'LabelHorizontalAlignment', 'left', 'HandleVisibility', 'off');
    ylim([66 100]); xlabel('Czas eksploatacji [lata]'); ylabel('SOH [%]');
    C = climate_profile(climates{c});
    title(sprintf('%s, średnio %s°C', C.name, num(C.T_mean, 1)));
end
lg = legend('Orientation', 'horizontal', 'NumColumns', 3);
lg.Layout.Tile = 'south';
save_fig(fig, 'e05_soh_trajectories');

%% Składowe utraty pojemności
fig = figure('Position', [60 60 1250 470]);
k = 0; X = zeros(12, 3); lab = cell(1, 12);
for c = 1:numel(climates)
    for s = 1:numel(strategies)
        k = k + 1;
        r = Sum(strcmp(Sum.climate, climates{c}) & strcmp(Sum.strategy, strategies{s}), :);
        X(k,:) = [r.loss_calendar_pct, r.loss_cycle_pct, r.loss_plating_pct];
        lab{k} = S.short(strategies{s});
    end
end
pos = (1:k) + floor(((1:k) - 1)/numel(strategies));
b = bar(pos, X, 'stacked', 'BarWidth', 0.8);
b(1).FaceColor = S.orange; b(2).FaceColor = S.blue; b(3).FaceColor = S.red;
yline(20, '--', 'granica 80% SOH', 'Color', S.red, 'LabelHorizontalAlignment', 'left', 'HandleVisibility', 'off');
set(gca, 'XTick', pos, 'XTickLabel', lab, 'XTickLabelRotation', 0, 'FontSize', 11);
ylim([0 38]);
for c = 1:numel(climates)
    xc = mean(pos((c - 1)*numel(strategies) + (1:numel(strategies))));
    text(xc, 35.5, cname(climates{c}), 'HorizontalAlignment', 'center', ...
        'FontWeight', 'bold', 'FontSize', 13, 'Color', S.navy);
end
ylabel('Utrata pojemności po 10 latach [%]');
legend('starzenie kalendarzowe', 'starzenie cykliczne', 'litowanie anody', 'Location', 'eastoutside');
title('Składowe utraty pojemności po 10 latach');
save_fig(fig, 'e05_loss_breakdown');

%% Działanie pętli SOH (strategia LIFE-ADAPT)
fig = figure('Position', [60 60 1300 440]);
tl = tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
title(tl, 'Nadrzędna pętla SOH w strategii LIFE-ADAPT', 'FontWeight', 'bold', 'FontSize', 14);
cc = {S.blue, S.green, S.red};
nexttile; hold on
for c = 1:numel(climates)
    T = Tall.(climates{c}).LIFE_ADAPT;
    plot(T.t_years, T.lambda, 'Color', cc{c}, 'DisplayName', cname(climates{c}));
end
ylim([-0.05 1.05]); xlabel('Czas eksploatacji [lata]'); ylabel('\lambda [-]');
title('Poziom ochrony \lambda');
legend('Location', 'east');
nexttile; hold on
for c = 1:numel(climates)
    T = Tall.(climates{c}).LIFE_ADAPT;
    plot(T.t_years, 100*T.soc_ac, 'Color', cc{c});
end
ylim([60 90]); xlabel('Czas eksploatacji [lata]'); ylabel('SOC [%]');
title('Docelowy SOC ładowania AC');
nexttile; hold on
for c = 1:numel(climates)
    T = Tall.(climates{c}).LIFE_ADAPT;
    plot(T.t_years, 100*(T.SOH_hat - soh_reference(P, T.t_years)), 'Color', cc{c});
end
yline(0, 'k:');
xlabel('Czas eksploatacji [lata]'); ylabel('SOH_{est} - SOH_{ref} [p.p.]');
title('Odchyłka SOH od trajektorii odniesienia');
save_fig(fig, 'e05_adaptive_loop');

%% Koszty strategii
fig = figure('Position', [60 60 1300 470]);
tl = tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
metrics = {'E_thermal_kWh_per_year', 'soc_mean_pct', 't_dc_mean_min'};
ttl = {'Energia zarządzania termicznego', 'Średni SOC (zapas zasięgu)', 'Średni czas ładowania DC w trasie'};
ylab = {'Energia [kWh/rok]', 'SOC [%]', 'Czas [min]'};
for m = 1:3
    nexttile;
    Y = zeros(numel(climates), numel(strategies));
    for c = 1:numel(climates)
        for s = 1:numel(strategies)
            r = Sum(strcmp(Sum.climate, climates{c}) & strcmp(Sum.strategy, strategies{s}), :);
            Y(c, s) = r.(metrics{m});
        end
    end
    bb = bar(Y);
    for s = 1:numel(strategies)
        bb(s).FaceColor = S.col(strategies{s});
        bb(s).DisplayName = S.short(strategies{s});
    end
    set(gca, 'XTickLabel', cellfun(cname, climates, 'UniformOutput', false));
    ylabel(ylab{m}); title(ttl{m});
end
lg = legend('Orientation', 'horizontal');
lg.Layout.Tile = 'south';
title(tl, 'Koszt strategii w 10-letniej eksploatacji', 'FontWeight', 'bold', 'FontSize', 14);
save_fig(fig, 'e05_costs');
end
