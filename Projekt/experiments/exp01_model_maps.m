function out = exp01_model_maps()
%EXP01_MODEL_MAPS  E01. Charakterystyki modelu ogniwa i mapy starzenia.
%
%   Wykresy:
%     e01_ocv_anode      napięcie obwodu otwartego i potencjał anody w funkcji SOC
%     e01_resistance     rezystancja ogniwa i anody w funkcji temperatury
%     e01_plating_map    największy prąd ładowania bez litowania anody
%     e01_calendar_map   utrata pojemności po 10 latach postoju
%     e01_v_shape        zużycie baterii na jedno ładowanie w funkcji temperatury
P = bms_params();
S = plot_style();
fprintf('\n=== E01: charakterystyki modelu ===\n');

%% Napięcie obwodu otwartego i potencjał anody
soc = linspace(0, 1, 201);
ocv = arrayfun(@(s) ocv_nmc(P, s), soc);
uan = arrayfun(@(s) anode_ocp(P, s), soc);
fig = figure('Position', [100 100 1200 450]);
tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile; plot(100*soc, ocv, 'Color', S.navy);
xlabel('SOC [%]'); ylabel('U_{OCV} [V]');
title('Napięcie obwodu otwartego ogniwa NMC/grafit');
nexttile; plot(100*soc, 1000*uan, 'Color', S.orange); hold on
yline(0, '--', 'potencjał metalicznego litu', 'Color', S.red, ...
    'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'top');
ylim([-20 300]); xlabel('SOC [%]'); ylabel('U_{an} względem Li/Li^+ [mV]');
title('Potencjał równowagowy anody grafitowej');
save_fig(fig, 'e01_ocv_anode');

%% Rezystancja w funkcji temperatury
T = -20:1:50;
R = zeros(size(T)); Ran = R;
for i = 1:numel(T)
    [R0, R1, Ran(i)] = cell_resistance(P, T(i), 0.5, 1);
    R(i) = R0 + R1;
end
R_lin = (P.R0_ref + P.R1_ref)*min(1.4, max(0.7, 1 + 0.002*(25 - T)));
fig = figure('Position', [100 100 760 460]);
semilogy(T, 1000*R, 'Color', S.navy); hold on
semilogy(T, 1000*Ran, 'Color', S.orange);
semilogy(T, 1000*R_lin, '--', 'Color', S.grey);
xlabel('Temperatura rdzenia [°C]'); ylabel('Rezystancja ogniwa [m\Omega]');
legend('R_0 + R_1, model Arrheniusa (E_a = 22 kJ/mol)', ...
       'R_{an}, rezystancja anody (E_a = 50 kJ/mol)', ...
       'uproszczony model liniowy', 'Location', 'northeast');
title('Rezystancja ogniwa w funkcji temperatury (SOC 50%)');
save_fig(fig, 'e01_resistance');

%% Mapa prądu ładowania bez litowania
Tg = -20:1:45; sg = 0.05:0.01:0.95;
Imap = zeros(numel(sg), numel(Tg));
for i = 1:numel(sg)
    for j = 1:numel(Tg)
        [~, ~, Ran_ij] = cell_resistance(P, Tg(j), sg(i), 1);
        Imap(i,j) = max(0, (anode_ocp(P, sg(i)) - P.phi_margin)/Ran_ij)/P.Q_cell_Ah;
    end
end
fig = figure('Position', [100 100 760 460]);
contourf(Tg, 100*sg, min(Imap, 3), 0:0.1:3, 'LineStyle', 'none');
colormap(parula(30)); clim([0 3]);
cb = colorbar; cb.Label.String = 'I_{max} [C]';
hold on
[cc, hh] = contour(Tg, 100*sg, Imap, [0.3 0.5 1], 'Color', [1 1 1], 'LineWidth', 1);
clabel(cc, hh, 'Color', 'w', 'FontSize', 10);
[cc, hh] = contour(Tg, 100*sg, Imap, [1.71 1.71], 'r', 'LineWidth', 2.5);
clabel(cc, hh, 'Color', 'r', 'FontWeight', 'bold');
xlabel('Temperatura rdzenia [°C]'); ylabel('SOC [%]');
title('Największy prąd ładowania bez litowania anody');
subtitle('linia czerwona: 1,71C = 300 A na pakiet, skala obcięta do 3C');
save_fig(fig, 'e01_plating_map');
Tm = array2table([repmat(Tg', numel(sg), 1), kron(100*sg', ones(numel(Tg),1)), reshape(Imap', [], 1)], ...
    'VariableNames', {'T_C','SOC_pct','I_max_C'});
save_csv(Tm, 'e01_plating_map');

%% Starzenie kalendarzowe po 10 latach postoju w stałych warunkach
Tg2 = -10:1:50; sg2 = 0:0.02:1;
Cal = zeros(numel(sg2), numel(Tg2));
for i = 1:numel(sg2)
    for j = 1:numel(Tg2)
        s = aging_stress(P, Tg2(j), sg2(i), 0, 0, 86400);
        Cal(i,j) = 100*P.k_cal*(3650*s(1))^P.z_cal;
    end
end
fig = figure('Position', [100 100 760 460]);
contourf(Tg2, 100*sg2, Cal, 0:2:40, 'LineColor', [1 1 1]*0.5);
colormap(flipud(hot)); clim([0 40]);
cb = colorbar; cb.Label.String = 'utrata pojemności [%]';
hold on
[cc, hh] = contour(Tg2, 100*sg2, Cal, [10 20], 'k', 'LineWidth', 2);
clabel(cc, hh, 'FontWeight', 'bold');
xlabel('Temperatura postoju [°C]'); ylabel('SOC postoju [%]');
title('Utrata pojemności po 10 latach postoju');
subtitle('tylko starzenie kalendarzowe, stała temperatura i SOC');
save_fig(fig, 'e01_calendar_map');

%% Zużycie na jedno ładowanie od 20 do 80% SOC w stałej temperaturze
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
fig = figure('Position', [100 100 760 460]);
cols = {S.green, S.blue, S.red};
[~, jmin] = min(dQ, [], 2);
for c = 1:numel(Cr)
    semilogy(Tv, dQ(c,:), 'Color', cols{c}, 'DisplayName', ...
        sprintf('%sC, minimum przy %d°C', strrep(sprintf('%.2g', Cr(c)), '.', ','), Tv(jmin(c)))); hold on
end
for c = 1:numel(Cr)
    plot(Tv(jmin(c)), dQ(c, jmin(c)), 'o', 'Color', cols{c}, 'MarkerFaceColor', cols{c}, ...
        'HandleVisibility', 'off');
end
xlabel('Temperatura ogniwa podczas ładowania [°C]');
ylabel('Utrata pojemności na ładowanie [ppm]');
legend('Location', 'north');
title('Zużycie baterii na jedno ładowanie od 20 do 80% SOC');
subtitle('lewe ramię: litowanie anody, prawe ramię: wzrost warstwy SEI');
save_fig(fig, 'e01_v_shape');
Tv_tab = array2table([Tv', dQ', dQpl'], 'VariableNames', ...
    {'T_C','dQ_05C_ppm','dQ_1C_ppm','dQ_171C_ppm','pl_05C_ppm','pl_1C_ppm','pl_171C_ppm'});
save_csv(Tv_tab, 'e01_v_shape');

out.T_opt = Tv(jmin);
out.I_plating_0C_80 = Imap(abs(sg - 0.8) < 1e-9, Tg == 0);
out.I_plating_25C_80 = Imap(abs(sg - 0.8) < 1e-9, Tg == 25);
fprintf('   minimum zużycia przy 0,5C / 1C / 1,71C: %d / %d / %d °C\n', out.T_opt);
fprintf('   prąd bez litowania przy SOC 80%%: %.2fC w 0°C, %.2fC w 25°C\n', ...
    out.I_plating_0C_80, out.I_plating_25C_80);
end
