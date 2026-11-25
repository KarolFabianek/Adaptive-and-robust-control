function ok = run_tests()
%RUN_TESTS  Testy poprawności modelu i regulatorów. Wypisuje [OK] / [BŁĄD].
%
%   ok = run_tests() zwraca true, gdy wszystkie testy przeszły.
%   Testy sprawdzają fizykę (bilans energii, ładunku), numerykę (zbieżność
%   względem kroku, stabilność metody niejawnej) i logikę regulatorów.
P = bms_params();
fprintf('\n=== Testy poprawności ===\n');
res = {};

%% T1: bilans energii w każdym kroku
[~, lg] = simulate_session(P, strategy_config(P, 'LIFE'), struct('Ta', 0, 'soc_plug', 0.2));
e = max(abs(lg.bal));
res(end+1,:) = {'T1 bilans energii (maks. reszta kroku < 1e-6 J)', e < 1e-6, sprintf('%.2e J', e)};

%% T2: bilans ładunku (całka prądu = zmiana SOC)
o = struct('Ta', 25, 'soc_plug', 0.2, 'drive_s', 0);
[~, lg] = simulate_session(P, strategy_config(P, 'GS_SAFE'), o);
dq = sum(lg.I)*1/3600/P.Q_pack_Ah;
dsoc = lg.soc(end) - 0.2;
res(end+1,:) = {'T2 bilans ładunku (|int I dt - dSOC| < 1e-9)', abs(dq - dsoc) < 1e-9, sprintf('%.2e', abs(dq - dsoc))};

%% T3: zbieżność względem kroku (dt = 1 s vs 0.25 s)
o1 = o; o1.dt = 1; o2 = o; o2.dt = 0.25;
r1 = simulate_session(P, strategy_config(P, 'GS_SAFE'), o1);
r2 = simulate_session(P, strategy_config(P, 'GS_SAFE'), o2);
d = abs(r1.Tc_max - r2.Tc_max);
res(end+1,:) = {'T3 zbieżność kroku (|dTmax| < 0.05 K)', d < 0.05, sprintf('%.3f K', d)};

%% T4: stabilność metody niejawnej przy dużym kroku (postój, dt = 600 s)
x = [40; 40; 0.5; 0]; Tlog = zeros(200, 1);
for k = 1:200
    x = pack_step(P, x, 0, 0, 10, 600, 1);
    Tlog(k) = x(1);
end
mono = all(diff(Tlog) <= 1e-12) && Tlog(end) > 10 - 1e-6;
res(end+1,:) = {'T4 stabilność przy dt = 600 s (monotoniczne stygnięcie)', mono, sprintf('T_end = %.3f °C', Tlog(end))};

%% T5: napięcie nie przekracza Vmax (faza CV)
[~, lg] = simulate_session(P, strategy_config(P, 'STD_90'), struct('Ta', 25, 'soc_plug', 0.5, 'soc_target', 1.0, 'drive_s', 0));
vm = max(lg.V);
res(end+1,:) = {'T5 faza CV: U_ogniwa <= 4.20 V + 2 mV', vm <= P.V_max_cell + 0.002, sprintf('U_max = %.4f V', vm)};

%% T6: strategia LIFE nie dopuszcza litowania
worst = Inf;
for Ta = [-10 0 10 25]
    [r, ~] = simulate_session(P, strategy_config(P, 'LIFE'), struct('Ta', Ta, 'soc_plug', 0.2));
    worst = min(worst, r.phi_min_mV);
end
res(end+1,:) = {'T6 LIFE: phi_anody >= 0 mV we wszystkich klimatach', worst >= 0, sprintf('phi_min = %.1f mV', worst)};

%% T7: GS = PI w punkcie projektowym, k = 3 przy małym rho
[Kp1, Ki1] = gs_gains(P, P.T_chill + 17, true);
[Kp2, ~, k2] = gs_gains(P, P.T_chill + 2, true);
okgs = abs(Kp1 - P.Kp) < 1e-12 && abs(Ki1 - P.Ki) < 1e-15 && abs(k2 - 3) < 1e-12 && abs(Kp2 - 3*P.Kp) < 1e-12;
res(end+1,:) = {'T7 harmonogram GS: k(17 K) = 1, k(2 K) = 3', okgs, ''};

%% T8: zbieżność obserwatora Tc (błąd początkowy 5 K)
st = init_state(30, 0.5, 1); st.Tc_hat = 25;
cfg = strategy_config(P, 'GS_SAFE');
seg = struct('mode', 2, 'P_drive', 0, 'soc_target', 0.8, 'charge_en', 0, 'precond', 0);
for k = 1:600
    st = bms_step(P, P, cfg, st, seg, 30, 1);
end
eo = abs(st.x(1) - st.Tc_hat);
res(end+1,:) = {'T8 obserwator: |Tc - Tc_hat| < 0.1 K po 10 min', eo < 0.1, sprintf('%.4f K', eo)};

%% T9: monotoniczność modelu starzenia
s1 = aging_stress(P, 25, 0.5, 0, 0, 86400); s2 = aging_stress(P, 35, 0.5, 0, 0, 86400);
s3 = aging_stress(P, 25, 0.9, 0, 0, 86400);
c1 = aging_stress(P, 25, 0.5, 3.5, 0, 3600); c2 = aging_stress(P, 25, 0.5, 7, 0, 1800);
okm = s2(1) > s1(1) && s3(1) > s1(1) && c2(2) > c1(2);
res(end+1,:) = {'T9 starzenie rośnie z T, SOC i C-rate', okm, ...
    sprintf('35°C: x%.2f, SOC 90%%: x%.2f, 2C vs 1C: x%.2f', s2(1)/s1(1), s3(1)/s1(1), c2(2)/c1(2))};

%% T10: kalibracja – 9% po 10 latach przy 25°C i SOC 50%
A = aging_update(P, aging_init(), [3650*s1(1), 0, 0]);
res(end+1,:) = {'T10 kalibracja: Q_cal(10 lat, 25°C, 50%) = 9%', abs(A.Q_cal - 0.09) < 1e-9, sprintf('%.4f', A.Q_cal)};

%% T11: powtarzalność symulacji 10-letniej (to samo ziarno)
P1 = P; P1.years = 1;
[~, i1] = simulate_lifetime(P1, 'LIFE_ADAPT', 'madryt', struct('seed', 3, 'years', 1));
[~, i2] = simulate_lifetime(P1, 'LIFE_ADAPT', 'madryt', struct('seed', 3, 'years', 1));
res(end+1,:) = {'T11 powtarzalność (to samo ziarno -> ten sam wynik)', i1.SOH_10y == i2.SOH_10y, sprintf('SOH(1 rok) = %.5f', i1.SOH_10y)};

%% T12: parametry pakietu zgodne z wykładem
okp = abs(P.Q_pack_Ah - 175) < 1e-9 && abs(P.E_pack_kWh - 60.48) < 1e-9 && abs(P.Rn_pack - 0.05376) < 1e-12;
res(end+1,:) = {'T12 pakiet 96s50p: 175 Ah, 60.48 kWh, 53.76 mOhm', okp, ''};

ok = all(cell2mat(res(:,2)));
for k = 1:size(res, 1)
    if res{k,2}, tag = '[OK]  '; else, tag = '[BŁĄD]'; end
    fprintf('  %s %-60s %s\n', tag, res{k,1}, res{k,3});
end
fprintf('  Wynik: %d/%d testów zaliczonych\n', nnz(cell2mat(res(:,2))), size(res, 1));
T = cell2table(res, 'VariableNames', {'test','passed','value'});
save_csv(T, 'tests');
end
