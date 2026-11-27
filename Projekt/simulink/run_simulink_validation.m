function T = run_simulink_validation(Ta)
%RUN_SIMULINK_VALIDATION  E09. Model Simulink i porównanie ze skryptem MATLAB.
%
%   T = run_simulink_validation(Ta)   domyślnie Ta = 0°C (z podgrzewaniem)
%
%   Funkcja buduje model btms_life_simulink.slx, jeśli go nie ma, uruchamia
%   sesję szybkiego ładowania od 20 do 80% SOC dla strategii LIFE, powtarza tę
%   samą sesję funkcją simulate_session i porównuje przebiegi.
if nargin < 1, Ta = 0; end
P = bms_params();
S = plot_style();
fprintf('\n=== E09: model Simulink i skrypt MATLAB, Ta = %d°C ===\n', Ta);
here = fileparts(mfilename('fullpath'));
model = 'btms_life_simulink';
if ~exist(fullfile(here, [model '.slx']), 'file')
    build_btms_simulink(model);
end

cfg = strategy_config(P, 'LIFE');
cfgS = rmfield(cfg, 'name');
simp.dt = 1;
simp.Ta = Ta;
simp.T0 = Ta;
simp.SOH0 = 1;
simp.soc_target = 0.80;
simp.x0 = [Ta; Ta; 0.20; 0];
simp.t_stop = 7200;
simp.T_heat = -1e9;
if cfg.precond, simp.T_heat = P.T_precond; end
% Harmonogram GS jako tablica na gęstej siatce (błąd interpolacji poniżej 1e-3)
simp.gs_rho_bp = -10:0.02:60;
simp.gs_k_tab = arrayfun(@(r) gs_k(P, r), simp.gs_rho_bp);

load_system(fullfile(here, [model '.slx']));
try
    % Zrzut schematu blokowego do raportu
    print(['-s' model], '-dpng', '-r220', fullfile(fileparts(here), 'figures', 'e09_simulink_diagram.png'));
    disp('   wykres: figures/e09_simulink_diagram.png');
catch
end
si = Simulink.SimulationInput(model);
si = si.setVariable('P', P).setVariable('cfg', cfgS).setVariable('simp', simp);
tic;
so = sim(si);
t_sl = toc;
close_system(model, 0);
xs = so.log_x; Is = so.log_I; us = so.log_u;
n_sl = size(xs, 1);

[r, lg] = simulate_session(P, cfg, struct('Ta', Ta, 'drive_s', 0, 'soc_plug', 0.20, 'dt', 1));
n_ml = numel(lg.t);
n = min(n_sl, n_ml);
d_Tc  = max(abs(xs(1:n,1) - lg.Tc(1:n)));
d_Ts  = max(abs(xs(1:n,2) - lg.Ts(1:n)));
d_soc = max(abs(xs(1:n,3) - lg.soc(1:n)));
d_I   = max(abs(Is(1:n) - lg.I(1:n)));
d_u   = max(abs(us(1:n) - lg.u(1:n)));
T = table(n_sl, n_ml, d_Tc, d_Ts, d_soc, d_I, d_u, n_sl*simp.dt/60, r.t_charge_min, max(xs(:,1)), r.Tc_max, t_sl, ...
    'VariableNames', {'steps_simulink','steps_matlab','max_dTc_K','max_dTs_K','max_dSOC','max_dI_A','max_du', ...
    't_charge_simulink_min','t_charge_matlab_min','Tc_max_simulink','Tc_max_matlab','t_sim_s'});
save_csv(T, sprintf('e09_simulink_validation_%dC', Ta));
disp(T);

fig = figure('Position', [60 60 1250 470]);
tl = tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
title(tl, sprintf('Model Simulink i skrypt MATLAB: sesja LIFE, otoczenie %d°C', Ta), ...
    'FontWeight', 'bold', 'FontSize', 14);
subtitle(tl, sprintf('największa różnica temperatury rdzenia: %.1e K', d_Tc), 'FontSize', 11);
tt = (1:n_sl)'*simp.dt/60;
nexttile; hold on
plot(tt, xs(:,1), 'Color', S.blue, 'LineWidth', 4);
plot(lg.t/60, lg.Tc, '--', 'Color', S.orange);
plot(tt, xs(:,2), 'Color', S.green, 'LineWidth', 4);
plot(lg.t/60, lg.Ts, '--', 'Color', S.red);
xlabel('Czas [min]'); ylabel('Temperatura [°C]');
legend('T_c, Simulink', 'T_c, MATLAB', 'T_s, Simulink', 'T_s, MATLAB', 'Location', 'southeast');
title('Temperatura rdzenia i powierzchni');
nexttile; hold on
plot(tt, Is, 'Color', S.blue, 'LineWidth', 4);
plot(lg.t/60, lg.I, '--', 'Color', S.orange);
xlabel('Czas [min]'); ylabel('Prąd pakietu [A]'); ylim([0 320]);
legend('Simulink', 'MATLAB', 'Location', 'southeast');
title('Prąd ładowania');
save_fig(fig, sprintf('e09_simulink_vs_matlab_%dC', Ta));
end

function k = gs_k(P, rho)
[~, ~, k] = gs_gains(P, P.T_chill + rho, true);
end
