function T = exp04_charge_temperature()
%EXP04_CHARGE_TEMPERATURE  E04 – w jakiej temperaturze szybko ładować baterię?
%
%   Bateria i otoczenie mają temperaturę T_set (5…45°C), grzanie wstępne
%   wyłączone, chłodzenie utrzymuje rdzeń blisko T_set + 3 K.
%   Ładowanie 20 -> 80% SOC:
%     GS_SAFE – bez limitu z potencjału anody (szybko, ale z litowaniem na zimno)
%     LIFE    – z limitem „bez litowania” (bezpiecznie, ale wolno na zimno)
%   Wynik: kompromis czas ładowania – zużycie i optimum temperatury.
P0 = bms_params();
S = plot_style();
fprintf('\n=== E04: optymalna temperatura szybkiego ładowania ===\n');
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

fig = figure('Position', [80 80 1100 420]);
tiledlayout(1, 2, 'TileSpacing', 'compact');
nexttile;
semilogy(Ts, T.GS_SAFE_dQ_ppm, '-o', 'Color', S.orange, 'MarkerFaceColor', S.orange); hold on
semilogy(Ts, T.LIFE_dQ_ppm, '-o', 'Color', S.blue, 'MarkerFaceColor', S.blue);
xlabel('Temperatura baterii na starcie ładowania [°C]'); ylabel('utrata pojemności na sesję [ppm]');
legend('bez limitu anody (GS\_SAFE)', 'z limitem anody (LIFE)', 'Location', 'north');
title('Zużycie baterii na jedno szybkie ładowanie 20 \rightarrow 80%');
nexttile;
plot(Ts, T.GS_SAFE_t_min, '-o', 'Color', S.orange, 'MarkerFaceColor', S.orange); hold on
plot(Ts, T.LIFE_t_min, '-o', 'Color', S.blue, 'MarkerFaceColor', S.blue);
xlabel('Temperatura baterii na starcie ładowania [°C]'); ylabel('czas ładowania [min]');
xline(P0.T_derate_start - 3, ':', 'nadzór termiczny', 'LabelVerticalAlignment', 'middle', 'HandleVisibility', 'off');
legend('bez limitu anody (GS\_SAFE)', 'z limitem anody (LIFE)', 'Location', 'north');
title('Czas ładowania 20 \rightarrow 80%');
save_fig(fig, 'e04_charge_temperature');
end
