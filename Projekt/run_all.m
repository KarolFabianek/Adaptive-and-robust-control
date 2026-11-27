function run_all(opts)
%RUN_ALL  Uruchamia cały projekt: testy, eksperymenty E01 do E09 i podsumowanie.
%
%   run_all                          pełny przebieg (Monte Carlo N = 50)
%   run_all(struct('quick', 1))      szybki przebieg z Monte Carlo N = 10,
%                                    nadpisuje wyniki E06
%   run_all(struct('simulink', 0))   przebieg bez Simulinka
%   run_all(struct('summary', 1))    tylko odtworzenie results/PODSUMOWANIE.md z plików CSV
%
%   Pełny przebieg trwa około 25 min przy zasilaniu z sieci. Na laptopie
%   zasilanym z baterii obliczenia trwają 3 do 5 razy dłużej.
%   Wyniki: results/*.csv, figures/*.png, results/PODSUMOWANIE.md
if nargin < 1, opts = struct(); end
if ~isfield(opts, 'quick'), opts.quick = 0; end
if ~isfield(opts, 'simulink'), opts.simulink = 1; end
if ~isfield(opts, 'summary'), opts.summary = 0; end
root = bms_setup();
if opts.summary
    T = readtable(fullfile(root, 'results', 'tests.csv'));
    write_summary(root, all(T.passed));
    return
end
t_all = tic;
fprintf('Sterowanie ładowaniem i temperaturą baterii pojazdu elektrycznego z ograniczeniem starzenia\n');
fprintf('Folder projektu: %s\n', root);

t = tic; ok = run_tests(); czas('testy', t);
if ~ok
    warning('run_all:tests', 'Nie wszystkie testy zaliczone, szczegóły w results/tests.csv');
end

if opts.quick, N = 10; else, N = 50; end
t = tic; exp01_model_maps();          czas('E01', t);
t = tic; exp02_fast_charge();         czas('E02', t);
t = tic; exp03_gain_scheduling();     czas('E03', t);
t = tic; exp04_charge_temperature();  czas('E04', t);
t = tic; exp05_lifetime();            czas('E05', t);
t = tic; exp06_monte_carlo(N, 'madryt'); czas('E06', t);
t = tic; exp07_rls_identification();  czas('E07', t);
t = tic; exp08_nasa_validation();     czas('E08', t);
if opts.simulink
    if license('test', 'Simulink') && ~isempty(ver('simulink'))
        t = tic; run_simulink_validation(0); czas('E09', t);
    else
        fprintf(2, 'Simulink nie jest zainstalowany, eksperyment E09 pominięty.\n');
    end
end
write_summary(root, ok);
fprintf('\nGotowe w %.1f min. Podsumowanie: results/PODSUMOWANIE.md\n', toc(t_all)/60);
end

function write_summary(root, ok)
%WRITE_SUMMARY  Tabela najważniejszych wyników z plików results/*.csv.
rd = @(n) readtable(fullfile(root, 'results', [n '.csv']), 'TextType', 'char');
fid = fopen(fullfile(root, 'results', 'PODSUMOWANIE.md'), 'w', 'n', 'UTF-8');
cleaner = onCleanup(@() fclose(fid));
fprintf(fid, '# Podsumowanie wyników (wygenerowane przez run_all.m, %s, MATLAB R%s)\n\n', ...
    char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm')), version('-release'));
fprintf(fid, 'Testy poprawności: %s\n\n', tern(ok, 'wszystkie zaliczone', 'wykryto błędy, szczegóły w tests.csv'));
fprintf(fid, '## E05. SOH po 10 latach [%%]\n\n| klimat | STD-100 | STD-90 | LIFE | LIFE-ADAPT |\n|---|---:|---:|---:|---:|\n');
S = rd('e05_lifetime_summary');
for kl = {'opole', 'madryt', 'dubaj'}
    v = cellfun(@(s) S.SOH_10y_pct(strcmp(S.climate, kl{1}) & strcmp(S.strategy, s)), ...
        {'STD_100', 'STD_90', 'LIFE', 'LIFE_ADAPT'});
    fprintf(fid, '| %s | %.1f | %.1f | %.1f | %.1f |\n', kl{1}, v);
end
fprintf(fid, '\n## E06. Monte Carlo, Madryt: odsetek pakietów z SOH co najmniej 80%%\n\n');
st = rd('e06_monte_carlo_stats_madryt');
fprintf(fid, '| strategia | średnie SOH | odchylenie standardowe | minimum | spełnia wymaganie |\n|---|---:|---:|---:|---:|\n');
for k = 1:height(st)
    fprintf(fid, '| %s | %.1f%% | %.2f p.p. | %.1f%% | %.0f%% |\n', strrep(st.strategy{k}, '_', '-'), st.SOH_mean_pct(k), ...
        st.SOH_std_pp(k), st.SOH_min_pct(k), st.P_meet_80_pct(k));
end
fprintf(fid, '\n## E02. Szybkie ładowanie od 20 do 80%% SOC: czas [min] i Tc,max [°C]\n\n| strategia | 0°C | 25°C | 35°C |\n|---|---|---|---|\n');
E = rd('e02_fast_charge');
for s = {'CC', 'PI', 'GS', 'GS_SAFE', 'STD_90', 'LIFE'}
    fprintf(fid, '| %s |', strrep(s{1}, '_', '-'));
    for Ta = [0 25 35]
        r = E(strcmp(E.strategy, s{1}) & E.Ta_C == Ta, :);
        fprintf(fid, ' %.1f min, %.1f °C |', r.t_charge_min, r.Tc_max_C);
    end
    fprintf(fid, '\n');
end
f9 = fullfile(root, 'results', 'e09_simulink_validation_0C.csv');
if exist(f9, 'file')
    V = readtable(f9);
    fprintf(fid, '\n## E09. Porównanie modelu Simulink ze skryptem MATLAB\n\nLiczba kroków: %d i %d, największa różnica Tc: %.2e K, największa różnica prądu: %.2e A\n', ...
        V.steps_simulink, V.steps_matlab, V.max_dTc_K, V.max_dI_A);
end
end

function czas(nazwa, t)
fprintf('%s zakończone, czas %.0f s\n', nazwa, toc(t));
end

function s = tern(c, a, b)
if c, s = a; else, s = b; end
end
