%% START_HERE – punkt wejścia do projektu BTMS (uruchom: F5 lub "start_here")
%
%  Sterowanie parametrami ładowania i temperaturą baterii EV tak, aby po
%  10 latach zachowała >= 80% pojemności (SOH >= 80%).
%  Autorzy: Karol Fabianek, Paweł Fortuna – Politechnika Opolska, WEAiI
%
%  Skrypt ustawia ścieżki i pokazuje menu. Każdy eksperyment można też
%  uruchomić osobno z Command Window (po wywołaniu bms_setup).

root = bms_setup();
fprintf('\n  BTMS – trwałość baterii EV (SOH >= 80%% po 10 latach)\n');
fprintf('  -----------------------------------------------------\n');
fprintf('   0  run_all                  – wszystko (testy + E01–E09)\n');
fprintf('   1  run_tests                – testy poprawności\n');
fprintf('   2  exp01_model_maps         – charakterystyki i mapy starzenia\n');
fprintf('   3  exp02_fast_charge        – szybkie ładowanie, 6 strategii x 6 temperatur\n');
fprintf('   4  exp03_gain_scheduling    – analiza PI vs GS (Bode, bieguny)\n');
fprintf('   5  exp04_charge_temperature – optymalna temperatura ładowania\n');
fprintf('   6  exp05_lifetime           – 10 lat: 4 strategie x 3 klimaty\n');
fprintf('   7  exp06_monte_carlo        – odporność (Monte Carlo)\n');
fprintf('   8  exp07_rls_identification – identyfikacja online RLS\n');
fprintf('   9  exp08_nasa_validation    – dane NASA B0005\n');
fprintf('  10  run_simulink_validation  – model Simulink vs MATLAB\n\n');
wybor = input('  Wybierz numer (Enter = 0): ');
if isempty(wybor), wybor = 0; end
lista = {@run_all, @run_tests, @exp01_model_maps, @exp02_fast_charge, @exp03_gain_scheduling, ...
         @exp04_charge_temperature, @exp05_lifetime, @exp06_monte_carlo, @exp07_rls_identification, ...
         @exp08_nasa_validation, @run_simulink_validation};
lista{wybor + 1}();
