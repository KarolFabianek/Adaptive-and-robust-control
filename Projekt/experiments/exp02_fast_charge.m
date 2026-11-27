function R = exp02_fast_charge()
%EXP02_FAST_CHARGE  E02. Szybkie ładowanie DC: 6 strategii w 6 temperaturach.
%
%   Każda sesja zaczyna się od 15 minut jazdy autostradą do ładowarki.
%   Strategia LIFE podgrzewa albo chłodzi wtedy pakiet. Potem następuje
%   ładowanie od 20% do 80% SOC. Wskaźniki: czas ładowania, maksymalna
%   temperatura rdzenia, energia układu termicznego, minimalny potencjał
%   anody, litowanie i utrata pojemności na sesję.
P = bms_params();
S = plot_style();
fprintf('\n=== E02: szybkie ładowanie DC ===\n');
strategies = {'CC','PI','GS','GS_SAFE','STD_90','LIFE'};
Tas = [-10 0 10 25 35 40];
rows = {};
logs = struct();
for i = 1:numel(strategies)
    cfg = strategy_config(P, strategies{i});
    for j = 1:numel(Tas)
        o = struct('Ta', Tas(j), 'soc_plug', 0.20, 'drive_s', 900);
        [r, lg] = simulate_session(P, cfg, o);
        rows(end+1, :) = {strategies{i}, Tas(j), r.soc_plug*100, r.Tc_plug, r.t_charge_min, r.Tc_max, ...
            r.E_TM_kWh, r.E_TM_precond_kWh, r.phi_min_mV, r.Q_pl_ppm, r.dQ_ppm, r.done}; %#ok<AGROW>
        logs.(sprintf('%s_%s', strategies{i}, strrep(sprintf('%d', Tas(j)), '-', 'm'))) = lg;
    end
end
R = cell2table(rows, 'VariableNames', {'strategy','Ta_C','soc_plug_pct','Tc_plug_C','t_charge_min', ...
    'Tc_max_C','E_TM_kWh','E_precond_kWh','phi_min_mV','Q_plating_ppm','dQ_session_ppm','done'});
save_csv(R, 'e02_fast_charge');
disp(R(ismember(R.Ta_C, [0 25 35]), :));

%% Przebiegi sesji: typowy BMS (STD-90) i strategia LIFE przy 0°C i 35°C
for Ta = [0 35]
    tag = strrep(sprintf('%d', Ta), '-', 'm');
    a = logs.(['STD_90_' tag]); b = logs.(['LIFE_' tag]);
    tmin = min(a.t(1), b.t(1))/60; tmax = max(a.t(end), b.t(end))/60;
    fig = figure('Position', [80 80 1200 680]);
    tl = tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(tl, sprintf('Szybkie ładowanie od 20 do 80%% SOC, temperatura otoczenia %d°C', Ta), ...
        'FontWeight', 'bold', 'FontSize', 14);
    panels = {'I', 'Tc', 'phi', 'u'};
    for k = 1:4
        nexttile; hold on
        xregion(tmin, 0, 'FaceColor', [0.85 0.85 0.85], 'FaceAlpha', 0.35, 'HandleVisibility', 'off');
        switch panels{k}
            case 'I'
                plot(a.t/60, a.I, 'Color', S.orange); plot(b.t/60, b.I, 'Color', S.blue);
                ylabel('Prąd pakietu [A]'); title('Prąd ładowania (ujemny: jazda)');
                legend(S.label('STD_90'), S.label('LIFE'), 'Location', 'southeast');
                text(tmin + 0.5, 270, 'dojazd do ładowarki', 'Color', [0.35 0.35 0.35], 'FontSize', 10);
            case 'Tc'
                plot(a.t/60, a.Tc, 'Color', S.orange); plot(b.t/60, b.Tc, 'Color', S.blue);
                plot(b.t/60, b.Tc_hat, ':', 'Color', S.navy, 'LineWidth', 2.5);
                yline(P.T_lim, '--', 'limit 40°C', 'Color', S.red, 'HandleVisibility', 'off');
                ylabel('T_c [°C]'); title('Temperatura rdzenia');
                legend('STD-90', 'LIFE', 'LIFE, estymata obserwatora', 'Location', 'best');
            case 'phi'
                plot(a.t/60, 1000*a.phi, 'Color', S.orange); plot(b.t/60, 1000*b.phi, 'Color', S.blue);
                yline(0, '--', 'próg litowania', 'Color', S.red, 'LabelVerticalAlignment', 'bottom');
                ylabel('\phi_{an} [mV]'); title('Potencjał anody względem Li/Li^+');
            case 'u'
                plot(a.t/60, a.u, 'Color', S.orange); plot(b.t/60, b.u, 'Color', S.blue);
                yline(0, ':', 'HandleVisibility', 'off'); ylim([-1.1 1.1]);
                ylabel('u [-]'); title('Sterowanie termiczne (u < 0 grzanie, u > 0 chłodzenie)');
        end
        xlim([tmin tmax]); xlabel('Czas od podłączenia do ładowarki [min]');
    end
    save_fig(fig, sprintf('e02_session_%sC', tag));
end

%% Zestawienie: czas ładowania i utrata pojemności w funkcji temperatury
fig = figure('Position', [80 80 1200 470]);
tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile; hold on
for i = 1:numel(strategies)
    k = strcmp(R.strategy, strategies{i});
    plot(R.Ta_C(k), R.t_charge_min(k), '-o', 'Color', S.col(strategies{i}), ...
        'MarkerFaceColor', S.col(strategies{i}), 'DisplayName', S.short(strategies{i}));
end
k = strcmp(R.strategy, 'STD_90') & ~R.done;
if any(k)
    text(R.Ta_C(k) + 1, R.t_charge_min(k) - 3, 'przerwano po 120 min', 'FontSize', 10, 'Color', S.orange);
end
xlabel('Temperatura otoczenia [°C]'); ylabel('Czas ładowania [min]');
legend('Location', 'northeast'); title('Czas ładowania od 20 do 80% SOC');
nexttile; hold on
for i = 1:numel(strategies)
    k = strcmp(R.strategy, strategies{i});
    plot(R.Ta_C(k), R.dQ_session_ppm(k), '-o', 'Color', S.col(strategies{i}), ...
        'MarkerFaceColor', S.col(strategies{i}));
end
set(gca, 'YScale', 'log');
xlabel('Temperatura otoczenia [°C]'); ylabel('Utrata pojemności na sesję [ppm]');
title('Zużycie baterii na jedno szybkie ładowanie');
save_fig(fig, 'e02_summary');
end
