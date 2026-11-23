%% Symulacja modelu Simulink (btms_model.slx) i porownanie z symulacja w MATLAB
% Model: blok Level-2 MATLAB S-Function (btms_sfun.m), strategia GS_LIFE, Ta = 35 C.
% Czas symulacji 1800 s - po dojsciu do 80% SOC pakiet stygnie.
clear; clc; close all;

model = 'btms_model';
load_system(model);
out = sim(model);

s = out.states;              % blok To Workspace (Structure With Time)
t = s.time;
x = squeeze(s.signals.values);
if size(x, 1) == 4 && size(x, 2) ~= 4
    x = x';
end

% ta sama sesja w MATLAB
p = params();
[~, d] = simulate_charging(p, 'GS_LIFE', 35);

% porownanie w tych samych chwilach czasu
[~, idx] = ismember(round(d.time_min*60), round(t));
err_Tc = max(abs(x(idx, 1) - d.Tc_C));
err_Ts = max(abs(x(idx, 2) - d.Ts_C));
err_SOC = max(abs(x(idx, 3) - d.SOC));
fprintf('Simulink vs MATLAB (GS_LIFE, 35 C):\n');
fprintf('  max blad Tc  = %.2e K\n', err_Tc);
fprintf('  max blad Ts  = %.2e K\n', err_Ts);
fprintf('  max blad SOC = %.2e\n', err_SOC);
if err_Tc < 1e-6 && err_Ts < 1e-6 && err_SOC < 1e-9
    fprintf('Wyniki zgodne.\n');
else
    fprintf('UWAGA: wyniki rozne!\n');
end

if ~isfolder('results'), mkdir('results'); end
writetable(table(err_Tc, err_Ts, err_SOC), 'results/simulink_check.csv');

figure('Color', 'w', 'Position', [100 100 900 420]);
plot(t/60, x(:, 1), 'LineWidth', 1.8); hold on;
plot(t/60, x(:, 2), 'LineWidth', 1.8);
plot(d.time_min, d.Tc_C, 'k--');
grid on;
xlabel('Czas [min]');
ylabel('Temperatura [C]');
title('Simulink: GS\_LIFE, T_a = 35 C');
legend('T_c (Simulink)', 'T_s (Simulink)', 'T_c (MATLAB)', 'Location', 'southeast');
if ~isfolder('figures'), mkdir('figures'); end
exportgraphics(gcf, 'figures/simulink_GS_LIFE.png', 'Resolution', 150);
