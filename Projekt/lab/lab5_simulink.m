%% LAB 5. Model Simulink: szybkie ładowanie ze strategią LIFE
% Sterowanie adaptacyjne i odporne, BTMS. Karol Fabianek, Paweł Fortuna
%
% Cel: zbudować i uruchomić model blokowy, obejrzeć sygnały w bloku Scope
% i porównać wynik ze skryptem MATLAB. Laboratorium wymaga Simulinka.
% Pierwsza kompilacja modelu trwa dłużej niż kolejne uruchomienia.

%% 1. Przygotowanie i budowa modelu
if ~exist('bms_setup', 'file'), cd('..'); end
bms_setup;
P = bms_params();
mdl = 'btms_life_simulink';
if ~exist(fullfile('simulink', [mdl '.slx']), 'file')
    build_btms_simulink(mdl);
end

%% 2. Zmienne modelu w przestrzeni roboczej (model działa też z przycisku Run)
Ta = 0;                                   % temperatura otoczenia, można zmienić i uruchomić ponownie
cfg = rmfield(strategy_config(P, 'LIFE'), 'name');
simp = struct('dt', 1, 'Ta', Ta, 'T0', Ta, 'SOH0', 1, 'soc_target', 0.80, ...
    'x0', [Ta; Ta; 0.20; 0], 't_stop', 7200, 'T_heat', P.T_precond);
simp.gs_rho_bp = -10:0.02:60;
simp.gs_k_tab = arrayfun(@(r) min(P.gs_max, max(P.gs_min, P.rho0/max(r, P.rho0/P.gs_max))), simp.gs_rho_bp);

%% 3. Otwarcie modelu i symulacja
if usejava('desktop'), open_system(fullfile('simulink', [mdl '.slx'])); else, load_system(fullfile('simulink', [mdl '.slx'])); end
% W oknie Simulinka: przycisk Run, potem dwuklik na bloku Scope "Temperatury i SOC".
so = sim(mdl);
x = so.log_x;
fprintf('Simulink: %d kroków, %.1f min, Tc,max = %.2f °C\n', size(x, 1), size(x, 1)/60, max(x(:, 1)));

%% 4. Porównanie ze skryptem MATLAB
[r, lg] = simulate_session(P, strategy_config(P, 'LIFE'), struct('Ta', Ta, 'drive_s', 0, 'soc_plug', 0.20));
n = min(size(x, 1), numel(lg.Tc));
fprintf('MATLAB:   %.1f min, Tc,max = %.2f °C, największa różnica Tc = %.1e K\n', r.t_charge_min, r.Tc_max, max(abs(x(1:n, 1) - lg.Tc(1:n))));
figure; plot((1:size(x, 1))/60, x(:, 1), lg.t/60, lg.Tc, '--', 'LineWidth', 1.5); grid on
xlabel('Czas [min]'); ylabel('Temperatura rdzenia [°C]'); legend('Simulink', 'MATLAB');
title('Temperatura rdzenia w modelu Simulink i w skrypcie MATLAB');

%% ZADANIA
% Z1. W bloku "Harmonogram GS k(rho)" ustaw tablicę samych jedynek (simp.gs_k_tab(:) = 1).
%     Otrzymuje się zwykły regulator PI. Porównaj Tc,max przy Ta = 25°C.
% Z2. Zmień Ta na -10. Ile trwa ładowanie i dlaczego prąd na początku jest mniejszy?
% Z3. Dodaj blok Scope na wyjściu bloku "Regulator ładowania CC-CV" i obejrzyj fazę CV na końcu ładowania.
