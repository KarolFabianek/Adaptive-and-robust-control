%% Sprawdzenie poprawnosci modelu i wynikow
% Kilka prostych testow: parametry, bilans energii, SOC koncowy, limit 40 C,
% nastawy GS, zbieznosc wzgledem kroku czasowego i model starzenia.
clear; clc;
p = params();
strategies = {'CC', 'PI', 'GS', 'PI_FF', 'GS_FF', 'PI_SAFE', 'GS_SAFE', 'GS_LIFE'};
n_err = 0;

%% 1. Parametry pakietu
n_err = n_err + check(abs(p.Qah - 175) < 1e-10, 'pojemnosc pakietu 175 Ah');
n_err = n_err + check(abs(p.Rn - 0.05376) < 1e-10, 'rezystancja pakietu 53.76 mOhm');
n_err = n_err + check(abs(p.E_kWh - 60.48) < 1e-10, 'energia pakietu 60.48 kWh');

%% 2. Wszystkie 24 sesje
all_done = true; balance_ok = true; u_ok = true; q_ok = true;
for Ta = [15 25 35]
    for i = 1:numel(strategies)
        [res, d] = simulate_charging(p, strategies{i}, Ta);
        all_done = all_done && res.status == "DONE" && abs(res.SOC_end - 0.8) < 1e-9;
        balance_ok = balance_ok && res.energy_balance_residual_J < 1e-7;
        u_ok = u_ok && all(d.u >= 0 & d.u <= 1);
        q_ok = q_ok && all(d.Qcool_W >= 0);
    end
end
n_err = n_err + check(all_done, '24 sesje dochodza do 80% SOC');
n_err = n_err + check(balance_ok, 'bilans energii w kazdym kroku (blad < 1e-7 J)');
n_err = n_err + check(u_ok, 'sterowanie u w zakresie [0, 1]');
n_err = n_err + check(q_ok, 'moc chlodzenia nieujemna');

%% 3. Limit 40 C przy 35 C dla strategii z regulatorem
for st = {'PI', 'GS', 'PI_SAFE', 'GS_SAFE', 'GS_LIFE'}
    res = simulate_charging(p, st{1}, 35);
    n_err = n_err + check(res.Tmax_C < 40, sprintf('%s przy 35 C: Tmax = %.2f C < 40 C', st{1}, res.Tmax_C));
end

%% 4. Nastawy GS
[Kp_gs, Ki_gs] = controller_gains(p, 'GS', p.Tcool + p.rho0);
n_err = n_err + check(Kp_gs == p.Kp && Ki_gs == p.Ki, 'GS = PI w punkcie projektowym rho0 = 17 K');
gs_ok = true;
for Ts = [10 20 30 40 50]
    gs_ok = gs_ok && controller_gains(p, 'GS', Ts) >= p.Kp;
end
n_err = n_err + check(gs_ok, 'nastawy GS nigdy ponizej PI');

%% 5. Zbieznosc: krok 5 s vs 1 s
p1 = p;
p1.dt = 1;
for st = {'PI', 'GS_SAFE', 'GS_LIFE'}
    a = simulate_charging(p, st{1}, 35);
    b = simulate_charging(p1, st{1}, 35);
    dT = abs(a.Tmax_C - b.Tmax_C);
    n_err = n_err + check(dT < 0.1 && abs(a.time_min - b.time_min) < 0.2, ...
        sprintf('%s: roznica Tmax dla dt = 5 s i 1 s = %.3f K', st{1}, dT));
end

%% 6. Model starzenia
[res, d] = simulate_charging(p, 'GS_LIFE', 35);
soh_hot = aging_model(p, mean(d.Tc_C), max(d.I_A), 35, 0.5);
soh_cold = aging_model(p, mean(d.Tc_C), max(d.I_A), 23, 0.4);
n_err = n_err + check(all(diff(soh_hot.SOH_pct) <= 1e-9), 'SOH nie rosnie w czasie');
n_err = n_err + check(soh_cold.SOH_pct(end) > soh_hot.SOH_pct(end), 'chlodniejszy postoj = mniejsze starzenie');

%% Podsumowanie
if n_err == 0
    fprintf('\nWszystkie testy OK\n');
else
    fprintf('\nLiczba bledow: %d\n', n_err);
end

function err = check(cond, text)
if cond
    fprintf('[OK]    %s\n', text);
    err = 0;
else
    fprintf('[BLAD]  %s\n', text);
    err = 1;
end
end
