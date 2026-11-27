%% START_HERE. Punkt wejścia do projektu (uruchomienie: F5 albo polecenie start_here)
%
%  Sterowanie ładowaniem i temperaturą baterii pojazdu elektrycznego
%  z ograniczeniem starzenia. Cel: co najmniej 80% pojemności po 10 latach.
%  Autorzy: Karol Fabianek, Paweł Fortuna. Politechnika Opolska, WEAiI.
%
%  Skrypt ustawia ścieżki i wyświetla menu. Każdy eksperyment można też
%  uruchomić osobno z Command Window po wywołaniu bms_setup.

root = bms_setup();
fprintf('\n  Sterowanie ładowaniem i temperaturą baterii pojazdu elektrycznego\n');
fprintf('  -----------------------------------------------------------------\n');
fprintf('   0  run_all                    cały projekt: testy i eksperymenty E01 do E09\n');
fprintf('   1  run_tests                  testy poprawności\n');
fprintf('   2  exp01_model_maps           charakterystyki modelu i mapy starzenia\n');
fprintf('   3  exp02_fast_charge          szybkie ładowanie, 6 strategii w 6 temperaturach\n');
fprintf('   4  exp03_gain_scheduling      regulatory PI i GS, analiza częstotliwościowa\n');
fprintf('   5  exp04_charge_temperature   optymalna temperatura ładowania\n');
fprintf('   6  exp05_lifetime             10 lat eksploatacji, 4 strategie w 3 klimatach\n');
fprintf('   7  exp06_monte_carlo          odporność na niepewność parametrów (Monte Carlo)\n');
fprintf('   8  exp07_rls_identification   identyfikacja parametrów metodą RLS\n');
fprintf('   9  exp08_nasa_validation      porównanie z danymi NASA B0005\n');
fprintf('  10  run_simulink_validation    model Simulink i porównanie ze skryptem MATLAB\n\n');
wybor = input('  Numer eksperymentu (Enter oznacza 0): ');
if isempty(wybor), wybor = 0; end
lista = {@run_all, @run_tests, @exp01_model_maps, @exp02_fast_charge, @exp03_gain_scheduling, ...
         @exp04_charge_temperature, @exp05_lifetime, @exp06_monte_carlo, @exp07_rls_identification, ...
         @exp08_nasa_validation, @run_simulink_validation};
lista{wybor + 1}();
