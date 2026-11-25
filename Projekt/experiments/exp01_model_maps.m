function out = exp01_model_maps()
%EXP01_MODEL_MAPS  E01 – charakterystyki modelu i „mapy starzenia”.
%
%   Wykresy:
%     e01_ocv_anode        OCV ogniwa i potencjał anody w funkcji SOC
%     e01_resistance       R0(T), R_an(T) (Arrhenius) vs liniowy model z wykładu
%     e01_plating_map      maks. prąd ładowania bez litowania I(T, SOC) [C]
%     e01_calendar_map     utrata pojemności po 10 latach postoju (T, SOC)
%     e01_v_shape          zużycie na jedno ładowanie vs temperatura (kształt „V”)
P = bms_params();
S = plot_style();
fprintf('\n=== E01: charakterystyki modelu ===\n');

%% OCV i potencjał anody
soc = linspace(0, 1, 201);
ocv = arrayfun(@(s) ocv_nmc(P, s), soc);
uan = arrayfun(@(s) anode_ocp(P, s), soc);
fig = figure('Position', [100 100 900 360]);
tiledlayout(1, 2, 'TileSpacing', 'compact');
nexttile; plot(100*soc, ocv, 'Color', S.navy);
xlabel('SOC [%]'); ylabel('OCV ogniwa [V]'); title('Napięcie obwodu otwartego NMC/grafit');
nexttile; plot(100*soc, 1000*uan, 'Color', S.orange); hold on
yline(0, '--', 'Li/Li^+ (0 V) – próg litowania', 'Color', S.red, 'LabelHorizontalAlignment', 'left');
ylim([-20 300]); xlabel('SOC [%]'); ylabel('U_{an} [mV vs Li/Li^+]');
title('Potencjał równowagowy anody grafitowej');
save_fig(fig, 'e01_ocv_anode');

%% Rezystancja vs temperatura
T = -20:1:50;
R0 = zeros(size(T)); Ran = R0;
for i = 1:numel(T)
    [R0(i), R1, Ran(i)] = cell_resistance(P, T(i), 0.5, 1);
    R0(i) = R0(i) + R1;
end
R_lect = (P.R0_ref + P.R1_ref)*min(1.4, max(0.7, 1 + 0.002*(25 - T)));
fig = figure('Position', [100 100 620 380]);
semilogy(T, 1000*R0, 'Color', S.navy); hold on
semilogy(T, 1000*Ran, 'Color', S.orange);
semilogy(T, 1000*R_lect, '--', 'Color', S.grey);
xlabel('Temperatura rdzenia [°C]'); ylabel('Rezystancja ogniwa [m\Omega]');
legend('R_0 + R_1 (Arrhenius, E_a = 22 kJ/mol)', 'R_{an} – anoda (E_a = 50 kJ/mol)', ...
       'model liniowy z wykładu', 'Location', 'northeast');
title('Przy 0°C rezystancja rośnie ponad 2×, rezystancja anody ponad 5×');
save_fig(fig, 'e01_resistance');

%% Mapa prądu bez litowania
Tg = -20:1:45; sg = 0.05:0.01:0.95;
Imap = zeros(numel(sg), numel(Tg));
for i = 1:numel(sg)
    for j = 1:numel(Tg)
        [~, ~, Ran_ij] = cell_resistance(P, Tg(j), sg(i), 1);
        Imap(i,j) = max(0, (anode_ocp(P, sg(i)) - P.phi_margin)/Ran_ij)/P.Q_cell_Ah;
    end
end
fig = figure('Position', [100 100 700 430]);
contourf(Tg, 100*sg, min(Imap, 3), 0:0.1:3, 'LineStyle', 'none');
colormap(parula(30)); clim([0 3]);
cb = colorbar; cb.Label.String = 'maks. prąd bez litowania [C]  (obcięte do 3C)';
hold on
[cc, hh] = contour(Tg, 100*sg, Imap, [0.3 0.5 1], 'Color', [1 1 1], 'LineWidth', 1);
clabel(cc, hh, 'Color', 'w', 'FontSize', 9);
[cc, hh] = contour(Tg, 100*sg, Imap, [1.71 1.71], 'r', 'LineWidth', 2.5);
clabel(cc, hh, 'Color', 'r', 'FontWeight', 'bold');
xlabel('Temperatura rdzenia [°C]'); ylabel('SOC [%]');
title('Prąd ładowania bez litowania anody (czerwona linia: 1,71C = 300 A)');
save_fig(fig, 'e01_plating_map');
Tm = array2table([repmat(Tg', numel(sg), 1), kron(100*sg', ones(numel(Tg),1)), reshape(Imap', [], 1)], ...
    'VariableNames', {'T_C','SOC_pct','I_max_C'});
save_csv(Tm, 'e01_plating_map');

%% Mapa starzenia kalendarzowego (10 lat stałych warunków)
Tg2 = -10:1:50; sg2 = 0:0.02:1;
Cal = zeros(numel(sg2), numel(Tg2));
for i = 1:numel(sg2)
    for j = 1:numel(Tg2)
        s = aging_stress(P, Tg2(j), sg2(i), 0, 0, 86400);
        Cal(i,j) = 100*P.k_cal*(3650*s(1))^P.z_cal;
    end
end
fig = figure('Position', [100 100 700 430]);
contourf(Tg2, 100*sg2, Cal, 0:2:40, 'LineColor', [1 1 1]*0.5);
colormap(flipud(hot)); cb = colorbar; cb.Label.String = 'utrata pojemności po 10 latach [%]';
clim([0 40]); hold on
[cc, hh] = contour(Tg2, 100*sg2, Cal, [10 20], 'k', 'LineWidth', 2);
clabel(cc, hh, 'FontWeight', 'bold');
xlabel('Temperatura postoju [°C]'); ylabel('SOC postoju [%]');
title('Samo starzenie kalendarzowe: 10 lat postoju w stałych warunkach');
save_fig(fig, 'e01_calendar_map');

%% „V” – zużycie na jedno ładowanie 20->80% vs temperatura (izotermicznie)
Tv = -10:1:50; Cr = [0.5 1 1.71];
A_ref = aging_update(P, aging_init(), [3*365, 180, 0]);
dQ = zeros(numel(Cr), numel(Tv)); dQpl = dQ;
for c = 1:numel(Cr)
    for j = 1:numel(Tv)
        Ic = Cr(c)*P.Q_cell_Ah; dt = 5;
        n = round(0.6*3600/Cr(c)/dt);
        Ssum = [0 0 0]; s_ = 0.2;
        for k = 1:n
            [~, ~, Ran_k] = cell_resistance(P, Tv(j), s_, 1);
            phi = anode_ocp(P, s_) - Ic*Ran_k;
            fpl = min(P.f_pl_max, P.k_pl*max(0, -phi));
            Ssum = Ssum + aging_stress(P, Tv(j), s_, Ic, fpl, dt);
            s_ = s_ + Ic*dt/3600/P.Q_cell_Ah;
        end
        A1 = aging_update(P, A_ref, Ssum);
        A0 = aging_update(P, A_ref, [0 0 0]);
        dQ(c,j) = 1e6*(A0.SOH - A1.SOH);
        dQpl(c,j) = 1e6*Ssum(3);
    end
end
fig = figure('Position', [100 100 700 420]);
cols = {S.green, S.blue, S.red};
for c = 1:numel(Cr)
    semilogy(Tv, dQ(c,:), 'Color', cols{c}); hold on
end
[~, jmin] = min(dQ, [], 2);
for c = 1:numel(Cr)
    plot(Tv(jmin(c)), dQ(c, jmin(c)), 'o', 'Color', cols{c}, 'MarkerFaceColor', cols{c});
end
xlabel('Temperatura ogniwa podczas ładowania [°C]');
ylabel('utrata pojemności na 1 ładowanie [ppm]');
legend(arrayfun(@(c) sprintf('%.2gC (optimum %d°C)', Cr(c), Tv(jmin(c))), 1:numel(Cr), 'UniformOutput', false), ...
    'Location', 'north');
title('Kształt „V”: litowanie na zimno, SEI na gorąco');
save_fig(fig, 'e01_v_shape');
Tv_tab = array2table([Tv', dQ', dQpl'], 'VariableNames', ...
    {'T_C','dQ_05C_ppm','dQ_1C_ppm','dQ_171C_ppm','pl_05C_ppm','pl_1C_ppm','pl_171C_ppm'});
save_csv(Tv_tab, 'e01_v_shape');

out.T_opt = Tv(jmin);
out.I_plating_0C_80 = Imap(abs(sg - 0.8) < 1e-9, Tg == 0);
out.I_plating_25C_80 = Imap(abs(sg - 0.8) < 1e-9, Tg == 25);
fprintf('   optimum temperatury ładowania (0.5/1/1.71C): %d / %d / %d °C\n', out.T_opt);
fprintf('   prąd bez litowania przy SOC 80%%: 0°C -> %.2fC, 25°C -> %.2fC\n', ...
    Imap(abs(sg - 0.8) < 1e-9, Tg == 0), out.I_plating_25C_80);
end
