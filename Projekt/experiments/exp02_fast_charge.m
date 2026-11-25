function R = exp02_fast_charge()
%EXP02_FAST_CHARGE  E02 – szybkie ładowanie DC: 6 strategii x 6 temperatur.
%
%   Każda sesja: 15 min jazdy autostradą do ładowarki (w strategii LIFE
%   z podgrzewaniem / chłodzeniem wstępnym), potem ładowanie 20% -> 80% SOC.
%   Wskaźniki: czas ładowania, Tc_max, energia układu termicznego,
%   minimalny potencjał anody, litowanie i utrata pojemności na sesję.
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

%% Przebiegi: STD_90 vs LIFE przy 0°C i 35°C
for Ta = [0 35]
    tag = strrep(sprintf('%d', Ta), '-', 'm');
    a = logs.(['STD_90_' tag]); b = logs.(['LIFE_' tag]);
    fig = figure('Position', [80 80 1100 650]);
    tl = tiledlayout(2, 2, 'TileSpacing', 'compact');
    title(tl, sprintf('Szybkie ładowanie przy %d°C: typowy BMS (STD\\_90) vs proponowana strategia LIFE', Ta), 'FontWeight', 'bold');
    nexttile; plot(a.t/60, a.I, 'Color', S.orange); hold on; plot(b.t/60, b.I, 'Color', S.blue);
    xline(0, ':'); ylabel('Prąd pakietu [A]'); xlabel('Czas od podłączenia [min]');
    legend('STD\_90', 'LIFE', 'Location', 'best'); title('Prąd (t < 0: jazda do ładowarki)');
    nexttile; plot(a.t/60, a.Tc, 'Color', S.orange); hold on; plot(b.t/60, b.Tc, 'Color', S.blue);
    plot(b.t/60, b.Tc_hat, ':', 'Color', S.navy);
    yline(P.T_lim, '--r', '40°C'); xline(0, ':');
    ylabel('T_c [°C]'); xlabel('Czas od podłączenia [min]');
    legend('STD\_90', 'LIFE', 'LIFE – obserwator', 'Location', 'best'); title('Temperatura rdzenia');
    nexttile; plot(a.t/60, 1000*a.phi, 'Color', S.orange); hold on; plot(b.t/60, 1000*b.phi, 'Color', S.blue);
    yline(0, '--r', 'litowanie'); yline(1000*P.phi_margin, ':', 'zapas 15 mV'); xline(0, ':');
    ylabel('\phi_{an} [mV]'); xlabel('Czas od podłączenia [min]'); title('Potencjał anody');
    nexttile; plot(a.t/60, 100*a.soc, 'Color', S.orange); hold on; plot(b.t/60, 100*b.soc, 'Color', S.blue);
    yyaxis right; plot(a.t/60, a.u, '--', 'Color', S.orange); plot(b.t/60, b.u, '--', 'Color', S.blue);
    ylabel('sterowanie u (−grzanie / +chłodzenie)'); ylim([-1.1 1.1]);
    yyaxis left; ylabel('SOC [%]'); xlabel('Czas od podłączenia [min]'); xline(0, ':');
    title('SOC (linie ciągłe) i sterowanie termiczne (przerywane)');
    save_fig(fig, sprintf('e02_session_%sC', tag));
end

%% Zestawienie: czas ładowania i utrata pojemności vs temperatura
fig = figure('Position', [80 80 1100 420]);
tiledlayout(1, 2, 'TileSpacing', 'compact');
nexttile; hold on
for i = 1:numel(strategies)
    k = strcmp(R.strategy, strategies{i});
    plot(R.Ta_C(k), R.t_charge_min(k), '-o', 'Color', S.col(strategies{i}), 'MarkerFaceColor', S.col(strategies{i}));
end
xlabel('Temperatura otoczenia [°C]'); ylabel('Czas ładowania 20 \rightarrow 80% [min]');
legend(cellfun(@(s) S.label(s), strategies, 'UniformOutput', false), 'Location', 'northeast');
title('Czas ładowania');
nexttile; hold on
for i = 1:numel(strategies)
    k = strcmp(R.strategy, strategies{i});
    semilogy(R.Ta_C(k), R.dQ_session_ppm(k), '-o', 'Color', S.col(strategies{i}), 'MarkerFaceColor', S.col(strategies{i}));
end
set(gca, 'YScale', 'log');
xlabel('Temperatura otoczenia [°C]'); ylabel('Utrata pojemności na sesję [ppm]');
title('Zużycie baterii na jedno szybkie ładowanie');
save_fig(fig, 'e02_summary');
end
