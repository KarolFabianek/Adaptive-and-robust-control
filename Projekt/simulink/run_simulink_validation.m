function T = run_simulink_validation(Ta)
%RUN_SIMULINK_VALIDATION  E09 – symulacja w Simulinku i porównanie z MATLAB-em.
%
%   T = run_simulink_validation(Ta)   (domyślnie Ta = 0°C – z podgrzewaniem)
%
%   1) buduje model btms_life_simulink.slx (jeśli nie istnieje),
%   2) uruchamia sesję szybkiego ładowania 20 -> 80% dla strategii LIFE,
%   3) uruchamia tę samą sesję skryptem simulate_session,
%   4) porównuje przebiegi (maks. różnice) i rysuje wykres.
if nargin < 1, Ta = 0; end
P = bms_params();
S = plot_style();
fprintf('\n=== E09: Simulink vs MATLAB (Ta = %d°C) ===\n', Ta);
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
% harmonogram GS jako tablica (gęsta siatka – błąd interpolacji < 1e-3)
simp.gs_rho_bp = -10:0.02:60;
simp.gs_k_tab = arrayfun(@(r) gs_k(P, r), simp.gs_rho_bp);

load_system(fullfile(here, [model '.slx']));
try   % zrzut schematu blokowego do raportu
    print(['-s' model], '-dpng', '-r150', fullfile(fileparts(here), 'figures', 'e09_simulink_diagram.png'));
    disp('   wykres: figures/e09_simulink_diagram.png');
catch
end
si = Simulink.SimulationInput(model);
si = si.setVariable('P', P).setVariable('cfg', cfgS).setVariable('simp', simp);
tic;
so = sim(si);
t_sl = toc;
close_system(model, 0);
xs = so.log_x; ys = so.log_y; Is = so.log_I; us = so.log_u;
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

fig = figure('Position', [60 60 1100 420]);
tiledlayout(1, 2, 'TileSpacing', 'compact');
tt = (1:n_sl)'*simp.dt/60;
nexttile;
plot(tt, xs(:,1), 'Color', S.blue, 'LineWidth', 3); hold on
plot(lg.t/60, lg.Tc, '--', 'Color', S.orange);
plot(tt, xs(:,2), 'Color', S.green, 'LineWidth', 3); plot(lg.t/60, lg.Ts, '--', 'Color', S.red);
xlabel('Czas [min]'); ylabel('Temperatura [°C]');
legend('T_c Simulink', 'T_c MATLAB', 'T_s Simulink', 'T_s MATLAB', 'Location', 'southeast');
title(sprintf('Simulink = MATLAB: maks. |\\Delta T_c| = %.1e K', d_Tc));
nexttile;
yyaxis left; plot(tt, Is, 'Color', S.blue, 'LineWidth', 3); hold on; plot(lg.t/60, lg.I, '--', 'Color', S.orange);
ylabel('Prąd [A]');
yyaxis right; plot(tt, us, 'Color', S.green, 'LineWidth', 2); ylabel('u');
xlabel('Czas [min]'); legend('I Simulink', 'I MATLAB', 'u Simulink', 'Location', 'east');
title('Prąd ładowania i sterowanie termiczne');
save_fig(fig, sprintf('e09_simulink_vs_matlab_%dC', Ta));
end

function k = gs_k(P, rho)
[~, ~, k] = gs_gains(P, P.T_chill + rho, true);
end
