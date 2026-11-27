%% LAB 3. Sterowanie parametrami ładowania: CC-CV, litowanie anody i podgrzewanie
% Sterowanie adaptacyjne i odporne, BTMS. Karol Fabianek, Paweł Fortuna
%
% Cel: pokazać, jak temperatura ogranicza bezpieczny prąd ładowania,
% i porównać typowy BMS (STD_90) z proponowaną strategią LIFE.

%% 1. Przygotowanie
if ~exist('bms_setup', 'file'), cd('..'); end
bms_setup;
P = bms_params();

%% 2. Największy prąd ładowania bez litowania anody
for T = [-10 0 10 25 35]
    [~, ~, Ran] = cell_resistance(P, T, 0.8, 1);
    Imax_C = (anode_ocp(P, 0.8) - P.phi_margin)/Ran/P.Q_cell_Ah;
    fprintf('T = %3d°C, SOC 80%%:  I_max = %.2fC  (%.0f A na pakiet)\n', T, Imax_C, Imax_C*P.Q_pack_Ah);
end
% Przy 0°C bezpieczny prąd wynosi tylko około 0,29C, przy 25°C około 1,85C.

%% 3. Szybkie ładowanie przy 0°C, strategie STD_90 i LIFE
o = struct('Ta', 0, 'soc_plug', 0.20);     % 15 min jazdy do ładowarki, potem ładowanie od 20 do 80%
[rs, ls] = simulate_session(P, strategy_config(P, 'STD_90'), o);
[rl, ll] = simulate_session(P, strategy_config(P, 'LIFE'), o);
fprintf('\nSTD_90: %.1f min, phi_min = %5.1f mV, litowanie %4.0f ppm\n', rs.t_charge_min, rs.phi_min_mV, rs.Q_pl_ppm);
fprintf('LIFE:   %.1f min, phi_min = %5.1f mV, litowanie %4.0f ppm, podgrzewanie %.2f kWh\n', ...
    rl.t_charge_min, rl.phi_min_mV, rl.Q_pl_ppm, rl.E_TM_precond_kWh);

figure; tiledlayout(3, 1);
nexttile; plot(ls.t/60, ls.I, ll.t/60, ll.I, 'LineWidth', 1.5); grid on
ylabel('Prąd [A]'); legend('STD-90', 'LIFE'); title('Szybkie ładowanie przy 0°C');
nexttile; plot(ls.t/60, ls.Tc, ll.t/60, ll.Tc, 'LineWidth', 1.5); grid on; ylabel('T_c [°C]');
nexttile; plot(ls.t/60, 1000*ls.phi, ll.t/60, 1000*ll.phi, 'LineWidth', 1.5); yline(0, 'r--'); grid on
ylabel('\phi_{an} [mV]'); xlabel('Czas od podłączenia [min]');

%% 4. Udział poszczególnych ograniczeń prądu w czasie ładowania (LIFE)
names = {'bazowe', 'profil', 'termiczne', 'tablica', 'anoda', 'CV'};
ch = ll.t > 0;
[~, idx] = min(ll.lim(ch, :), [], 2);
for k = 1:6
    fprintf('ograniczenie %-10s aktywne przez %5.1f%% czasu ładowania\n', names{k}, 100*mean(idx == k));
end

%% ZADANIA
% Z1. Ustaw P.T_precond = 10 (słabsze podgrzewanie). Jak zmieniają się czas ładowania i zużyta energia?
% Z2. Ustaw P.phi_margin na 0 i na 0.03 V. Jak zapas potencjału wpływa na czas ładowania i bezpieczeństwo?
% Z3. Uruchom sesję 'CC' przy 0°C. Ile razy większe jest zużycie baterii (res.dQ_ppm) niż dla LIFE?
