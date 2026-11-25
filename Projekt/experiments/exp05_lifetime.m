function [Sum, Tall] = exp05_lifetime()
%EXP05_LIFETIME  E05 – 10 lat eksploatacji: 4 strategie x 3 klimaty.
%
%   Główny wynik projektu: czy bateria zachowa >= 80% pojemności po 10
%   latach i jakim kosztem (energia zarządzania termicznego, czas
%   szybkiego ładowania, dostępny zasięg = średni SOC).
P = bms_params();
S = plot_style();
fprintf('\n=== E05: 10 lat eksploatacji ===\n');
strategies = {'STD_100','STD_90','LIFE','LIFE_ADAPT'};
climates = {'opole','madryt','dubaj'};
Tall = struct();
rows = {};
for c = 1:numel(climates)
    for s = 1:numel(strategies)
        tic;
        [T, info] = simulate_lifetime(P, strategies{s}, climates{c});
        Tall.(climates{c}).(strategies{s}) = T;
        rows(end+1, :) = {climates{c}, strategies{s}, 100*info.SOH_10y, 100*info.Q_cal, 100*info.Q_cyc, ...
            100*info.Q_pl, info.meets_80, info.E_TM_kWh_year, info.t_dc_mean_min, ...
            info.t_dc_max_min, info.Tc_max_active, info.Tc_max, 100*info.soc_mean, 100*info.soc_ac_mean, info.lambda_mean}; %#ok<AGROW>
        fprintf('   %-7s %-10s SOH(10 lat) = %5.1f%%  (%.1f s)\n', climates{c}, strategies{s}, 100*info.SOH_10y, toc);
    end
end
Sum = cell2table(rows, 'VariableNames', {'climate','strategy','SOH_10y_pct','loss_calendar_pct', ...
    'loss_cycle_pct','loss_plating_pct','meets_80pct','E_thermal_kWh_per_year', ...
    't_dc_mean_min','t_dc_max_min','Tc_max_operation_C','Tc_max_incl_parking_C','soc_mean_pct','soc_ac_target_mean_pct','lambda_mean'});
save_csv(Sum, 'e05_lifetime_summary');
root = fileparts(fileparts(mfilename('fullpath')));
save(fullfile(root, 'results', 'e05_lifetime.mat'), 'Tall', 'Sum');
for c = 1:numel(climates)
    for s = 1:numel(strategies)
        save_csv(Tall.(climates{c}).(strategies{s}), sprintf('e05_monthly_%s_%s', climates{c}, strategies{s}));
    end
end
disp(Sum);

%% SOH(t)
fig = figure('Position', [60 60 1250 420]);
tl = tiledlayout(1, 3, 'TileSpacing', 'compact');
title(tl, 'Stan zdrowia baterii (SOH) przez 10 lat', 'FontWeight', 'bold');
for c = 1:numel(climates)
    nexttile; hold on
    for s = 1:numel(strategies)
        T = Tall.(climates{c}).(strategies{s});
        plot([0; T.t_years], 100*[1; T.SOH], 'Color', S.col(strategies{s}));
    end
    tt = linspace(0, 10, 100);
    plot(tt, 100*soh_reference(P, tt), ':', 'Color', S.navy);
    yline(80, '--r', 'cel: 80%', 'LabelHorizontalAlignment', 'left');
    ylim([72 100]); xlabel('Lata'); ylabel('SOH [%]');
    C = climate_profile(climates{c});
    title(sprintf('%s (średnio %.1f°C)', C.name, C.T_mean));
    if c == 1
        legend([cellfun(@(x) S.label(x), strategies, 'UniformOutput', false), {'trajektoria odniesienia'}], ...
            'Location', 'southwest', 'FontSize', 9);
    end
end
save_fig(fig, 'e05_soh_trajectories');

%% Rozkład utraty pojemności
fig = figure('Position', [60 60 1100 420]);
k = 0; X = []; lab = {};
for c = 1:numel(climates)
    for s = 1:numel(strategies)
        k = k + 1;
        r = Sum(strcmp(Sum.climate, climates{c}) & strcmp(Sum.strategy, strategies{s}), :);
        X(k,:) = [r.loss_calendar_pct, r.loss_cycle_pct, r.loss_plating_pct]; %#ok<AGROW>
        lab{k} = strrep(strategies{s}, '_', '\_'); %#ok<AGROW>
    end
end
pos = (1:k) + floor(((1:k) - 1)/numel(strategies));
b = bar(pos, X, 'stacked', 'BarWidth', 0.8);
b(1).FaceColor = S.orange; b(2).FaceColor = S.blue; b(3).FaceColor = S.red;
yline(20, '--r', '20% = granica 80% SOH', 'LabelHorizontalAlignment', 'left', 'HandleVisibility', 'off');
set(gca, 'XTick', pos, 'XTickLabel', lab, 'XTickLabelRotation', 0, 'FontSize', 10);
ylim([0 38]);
for c = 1:numel(climates)
    xc = mean(pos((c - 1)*numel(strategies) + (1:numel(strategies))));
    text(xc, 36, climate_profile(climates{c}).name, 'HorizontalAlignment', 'center', ...
        'FontWeight', 'bold', 'FontSize', 13, 'Color', S.navy);
end
ylabel('utrata pojemności po 10 latach [%]');
legend('kalendarzowa', 'cykliczna', 'litowanie', 'Location', 'eastoutside');
title('Z czego wynika utrata pojemności?');
save_fig(fig, 'e05_loss_breakdown');

%% Działanie pętli adaptacyjnej
fig = figure('Position', [60 60 1250 380]);
tiledlayout(1, 3, 'TileSpacing', 'compact');
cc = {S.blue, S.green, S.red};
nexttile; hold on
for c = 1:numel(climates)
    T = Tall.(climates{c}).LIFE_ADAPT;
    plot(T.t_years, T.lambda, 'Color', cc{c});
end
ylabel('\lambda – poziom ochrony'); xlabel('Lata'); ylim([0 1]);
legend(cellfun(@(x) climate_profile(x).name, climates, 'UniformOutput', false), 'Location', 'best');
title('Sterowanie nadrzędne \lambda(t)');
nexttile; hold on
for c = 1:numel(climates)
    T = Tall.(climates{c}).LIFE_ADAPT;
    plot(T.t_years, 100*T.soc_ac, 'Color', cc{c});
end
ylabel('docelowy SOC ładowania AC [%]'); xlabel('Lata'); title('Okno SOC (zasięg dzienny)');
nexttile; hold on
for c = 1:numel(climates)
    T = Tall.(climates{c}).LIFE_ADAPT;
    plot(T.t_years, 100*(T.SOH_hat - soh_reference(P, T.t_years)), 'Color', cc{c});
end
yline(0, 'k:'); ylabel('SOH_{est} - SOH_{ref} [p.p.]'); xlabel('Lata');
title('Uchyb „budżetu zdrowia”');
save_fig(fig, 'e05_adaptive_loop');

%% Koszty
fig = figure('Position', [60 60 1250 380]);
tiledlayout(1, 3, 'TileSpacing', 'compact');
metrics = {'E_thermal_kWh_per_year', 'soc_mean_pct', 't_dc_mean_min'};
ttl = {'Energia zarządzania termicznego [kWh/rok]', 'Średni SOC [%] (zapas zasięgu)', 'Średni czas ładowania DC w trasie [min]'};
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
    for s = 1:numel(strategies), bb(s).FaceColor = S.col(strategies{s}); end
    set(gca, 'XTickLabel', cellfun(@(x) climate_profile(x).name, climates, 'UniformOutput', false));
    title(ttl{m});
    if m == 1, legend(cellfun(@(x) S.label(x), strategies, 'UniformOutput', false), 'Location', 'northwest', 'FontSize', 8); end
end
save_fig(fig, 'e05_costs');
end
