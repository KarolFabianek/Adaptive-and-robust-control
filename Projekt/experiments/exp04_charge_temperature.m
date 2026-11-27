function T = exp04_charge_temperature()
%EXP04_CHARGE_TEMPERATURE  E04. Wpływ temperatury baterii na szybkie ładowanie.
%
%   Bateria i otoczenie mają tę samą temperaturę (5 do 45°C). Grzanie wstępne
%   jest wyłączone, a chłodzenie utrzymuje rdzeń blisko temperatury startowej
%   plus 3 K. Porównanie ładowania od 20 do 80% SOC:
%     GS_SAFE  bez limitu prądu z potencjału anody,
%     LIFE     z limitem prądu chroniącym anodę przed litowaniem.
P0 = bms_params();
S = plot_style();
fprintf('\n=== E04: temperatura szybkiego ładowania ===\n');
Ts = 5:2.5:45;
rows = zeros(numel(Ts), 9);
for i = 1:numel(Ts)
    P = P0;
    P.T_precond = -100;
    P.Tref_charge = Ts(i) + 3;
    o = struct('Ta', Ts(i), 'drive_s', 0, 'soc_plug', 0.20);
    a = simulate_session(P, strategy_config(P, 'GS_SAFE'), o);
    b = simulate_session(P, strategy_config(P, 'LIFE'), o);
    rows(i,:) = [Ts(i), a.t_charge_min, a.dQ_ppm, a.Q_pl_ppm, a.Tc_max, ...
                 b.t_charge_min, b.dQ_ppm, b.Q_pl_ppm, b.Tc_max];
end
T = array2table(rows, 'VariableNames', {'T_batt_C','GS_SAFE_t_min','GS_SAFE_dQ_ppm','GS_SAFE_plating_ppm', ...
    'GS_SAFE_Tc_max','LIFE_t_min','LIFE_dQ_ppm','LIFE_plating_ppm','LIFE_Tc_max'});
save_csv(T, 'e04_charge_temperature');
disp(T);

fig = figure('Position', [80 80 1200 450]);
tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile;
semilogy(Ts, T.GS_SAFE_dQ_ppm, '-o', 'Color', S.navy, 'MarkerFaceColor', S.navy); hold on
semilogy(Ts, T.LIFE_dQ_ppm, '-o', 'Color', S.blue, 'MarkerFaceColor', S.blue);
xlabel('Temperatura baterii na początku ładowania [°C]'); ylabel('Utrata pojemności na sesję [ppm]');
legend('GS-SAFE, bez limitu anody', 'LIFE, z limitem anody', 'Location', 'northeast');
title('Zużycie baterii na jedno ładowanie od 20 do 80% SOC');
nexttile;
plot(Ts, T.GS_SAFE_t_min, '-o', 'Color', S.navy, 'MarkerFaceColor', S.navy); hold on
plot(Ts, T.LIFE_t_min, '-o', 'Color', S.blue, 'MarkerFaceColor', S.blue);
xline(P0.T_derate_start - 3, ':', 'początek redukcji prądu', 'LabelVerticalAlignment', 'middle', ...
    'HandleVisibility', 'off');
xlabel('Temperatura baterii na początku ładowania [°C]'); ylabel('Czas ładowania [min]');
legend('GS-SAFE, bez limitu anody', 'LIFE, z limitem anody', 'Location', 'northwest');
title('Czas ładowania od 20 do 80% SOC');
save_fig(fig, 'e04_charge_temperature');
end
