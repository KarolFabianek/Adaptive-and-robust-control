%% BTMS - szybkie ladowanie pakietu 96s50p z chlodzeniem cieczowym
% 8 strategii sterowania chlodzeniem x 3 temperatury otoczenia = 24 sesje
% oraz prognoza SOH po 10 latach dla kazdej sesji.
% Wyniki: folder results (CSV) i figures (PNG).
clear; clc; close all;

p = params();
strategies = {'CC', 'PI', 'GS', 'PI_FF', 'GS_FF', 'PI_SAFE', 'GS_SAFE', 'GS_LIFE'};
ambients = [15 25 35];

if ~isfolder('results'), mkdir('results'); end
if ~isfolder('figures'), mkdir('figures'); end

%% Symulacja 24 sesji
summary = [];
life = table();
for Ta = ambients
    for i = 1:numel(strategies)
        st = strategies{i};
        [res, data] = simulate_charging(p, st, Ta);
        summary = [summary; res]; %#ok<AGROW>

        % SOH po 10 latach - postoj przy 78% SOC (taki sam dla wszystkich strategii)
        soh78 = aging_model(p, res.mean_Tc_C, res.Ipeak_A, Ta, p.soc_park);
        % ta sama strategia, ale postoj przy 50% SOC
        soh50 = aging_model(p, res.mean_Tc_C, res.Ipeak_A, Ta, p.soc_park_life);

        row = table(string(st), Ta, soh78.SOH_pct(end), soh78.Dcal_pp(end), soh78.Dcyc_pp(end), ...
            soh50.SOH_pct(end), 'VariableNames', {'strategy', 'ambient_C', 'SOH_10y_pct', ...
            'Dcal_pp', 'Dcyc_pp', 'SOH_10y_park050_pct'});
        life = [life; row]; %#ok<AGROW>

        if Ta == 35
            writetable(data, ['results/session_35C_' st '.csv']);
            sessions35.(st) = data;
        end
    end
end
summary = struct2table(summary);
writetable(summary, 'results/sessions_summary.csv');
writetable(life, 'results/life_summary.csv');

%% Wyniki
fprintf('Wszystkie sesje zakonczone: %d/%d\n', sum(summary.status == "DONE"), height(summary));
fprintf('\nWyniki przy Ta = 35 C:\n');
disp(summary(summary.ambient_C == 35, {'strategy', 'time_min', 'Tmax_C', 'energy_aux_kWh', 'sat_fraction'}));

fprintf('Tmax [C] dla PI i GS w roznych temperaturach otoczenia:\n');
for Ta = ambients
    Tpi = summary.Tmax_C(summary.strategy == "PI" & summary.ambient_C == Ta);
    Tgs = summary.Tmax_C(summary.strategy == "GS" & summary.ambient_C == Ta);
    fprintf('  Ta = %2d C:  PI %.2f   GS %.2f\n', Ta, Tpi, Tgs);
end

fprintf('\nSOH po 10 latach przy Ta = 35 C:\n');
disp(life(life.ambient_C == 35, :));

%% Wykresy - sesja przy 35 C
show = {'CC', 'PI', 'GS', 'GS_FF', 'GS_LIFE'};

figure('Color', 'w', 'Position', [100 100 900 450]);
hold on;
for i = 1:numel(show)
    d = sessions35.(show{i});
    plot(d.time_min, d.Tc_C, 'LineWidth', 1.8);
end
yline(p.Tlim, 'r--', 'limit 40 C');
grid on;
xlabel('Czas [min]');
ylabel('Temperatura rdzenia T_c [C]');
title('Temperatura rdzenia podczas ladowania, T_a = 35 C');
legend(strrep(show, '_', '\_'), 'Location', 'northwest');
exportgraphics(gcf, 'figures/temperature_35C.png', 'Resolution', 150);

% prad: CC, PI, GS, FF i SAFE maja przy 35 C ten sam profil (nadzor sie nie wlacza)
figure('Color', 'w', 'Position', [120 120 900 450]);
plot(sessions35.PI.time_min, sessions35.PI.I_A, 'LineWidth', 1.8); hold on;
plot(sessions35.GS_LIFE.time_min, sessions35.GS_LIFE.I_A, 'LineWidth', 1.8);
grid on;
xlabel('Czas [min]');
ylabel('Prad ladowania [A]');
title('Prad ladowania, T_a = 35 C');
legend('CC, PI, GS, FF, SAFE', 'GS\_LIFE (limit 210 A)', 'Location', 'southwest');
exportgraphics(gcf, 'figures/current_35C.png', 'Resolution', 150);

figure('Color', 'w', 'Position', [140 140 900 450]);
hold on;
for i = 1:numel(show)
    d = sessions35.(show{i});
    plot(d.time_min, d.u, 'LineWidth', 1.8);
end
grid on;
xlabel('Czas [min]');
ylabel('Sterowanie chlodzeniem u [-]');
title('Sygnal sterujacy chlodzeniem, T_a = 35 C');
legend(strrep(show, '_', '\_'), 'Location', 'best');
exportgraphics(gcf, 'figures/cooling_u_35C.png', 'Resolution', 150);

%% Wykres - SOH po 10 latach (35 C)
L35 = life(life.ambient_C == 35, :);
figure('Color', 'w', 'Position', [160 160 900 450]);
bar(categorical(L35.strategy, L35.strategy), [L35.SOH_10y_pct, L35.SOH_10y_park050_pct]);
set(gca, 'TickLabelInterpreter', 'none');
yline(80, 'r--', 'cel 80%');
ylim([60 85]);
grid on;
ylabel('SOH po 10 latach [%]');
title('Prognoza SOH po 10 latach, T_a = 35 C');
legend('postoj 78% SOC', 'postoj 50% SOC', 'Location', 'northwest');
exportgraphics(gcf, 'figures/soh_10y_35C.png', 'Resolution', 150);
