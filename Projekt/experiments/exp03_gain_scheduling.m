function out = exp03_gain_scheduling()
%EXP03_GAIN_SCHEDULING  E03. Analiza regulatora chłodzenia: PI i gain scheduling.
%
%   1. Linearyzacja pętli termicznej w punktach pracy rho = Ts - Tchill
%      od 4 do 20 K i analiza częstotliwościowa (bez Control System Toolbox):
%      pulsacja odcięcia, zapas fazy i bieguny układu zamkniętego.
%   2. Odpowiedź modelu zlinearyzowanego na skok strat cieplnych o 1 kW.
%   3. Porównanie nieliniowe z wykładu: sesja od 25 do 80% SOC w 15, 25 i 35°C.
%
%   Przy stałych nastawach wzmocnienie pętli maleje proporcjonalnie do rho,
%   więc regulator PI zwalnia w chłodnym punkcie pracy. Harmonogram GS
%   utrzymuje stałą pulsację odcięcia.
P = bms_params();
S = plot_style();
fprintf('\n=== E03: gain scheduling ===\n');

rhos = 4:0.5:20;
u0 = 0.3;
w = logspace(-5, -1, 400);
n = numel(rhos);
wc = zeros(n, 2); pm = wc; pole = wc; peak = wc; trec = wc;
Lmag = struct();
for i = 1:n
    rho = rhos(i);
    [A, B, Cm, Bd] = lin_thermal(P, rho, u0);
    for g = 0:1
        [Kp, Ki] = gs_gains(P, P.T_chill + rho, g);
        L = zeros(size(w));
        for k = 1:numel(w)
            G = -Cm*((1i*w(k)*eye(2) - A)\B);   % wzmocnienie od u do -Tc
            L(k) = (Kp + Ki/(1i*w(k)))*G;
        end
        [wc(i,g+1), pm(i,g+1)] = crossover(w, L);
        Acl = [A + B*[Kp 0], B; [Ki 0], 0];
        pole(i,g+1) = max(real(eig(Acl)));
        [peak(i,g+1), trec(i,g+1)] = dist_step(Acl, [Bd; 0], 1000);
        if any(abs(rho - [5 10 17]) < 1e-9)
            Lmag.(sprintf('r%d_g%d', rho, g)) = L;
        end
    end
end
T = table(rhos', wc(:,1), pm(:,1), pole(:,1), peak(:,1), trec(:,1), ...
          wc(:,2), pm(:,2), pole(:,2), peak(:,2), trec(:,2), ...
    'VariableNames', {'rho_K','PI_wc_rad_s','PI_PM_deg','PI_max_real_pole','PI_dTc_peak_K','PI_t_recover_s', ...
                      'GS_wc_rad_s','GS_PM_deg','GS_max_real_pole','GS_dTc_peak_K','GS_t_recover_s'});
save_csv(T, 'e03_gs_linear_analysis');

%% Charakterystyki częstotliwościowe
fig = figure('Position', [80 80 1300 430]);
tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
cl = {S.red, S.orange, S.blue};
rr = [5 10 17];
nexttile; hold on
for k = 1:3
    loglog(w, abs(Lmag.(sprintf('r%d_g0', rr(k)))), '--', 'Color', cl{k}, ...
        'DisplayName', sprintf('PI, \\rho = %d K', rr(k)));
    loglog(w, abs(Lmag.(sprintf('r%d_g1', rr(k)))), '-', 'Color', cl{k}, ...
        'DisplayName', sprintf('GS, \\rho = %d K', rr(k)));
end
set(gca, 'XScale', 'log', 'YScale', 'log');
yline(1, 'k:', 'HandleVisibility', 'off');
xlabel('\omega [rad/s]'); ylabel('|L(j\omega)|');
legend('Location', 'southwest', 'NumColumns', 1);
title('Moduł transmitancji pętli otwartej');
nexttile; hold on
plot(rhos, 1e3*T.PI_wc_rad_s, '--', 'Color', S.purple);
plot(rhos, 1e3*T.GS_wc_rad_s, '-', 'Color', S.green);
xlabel('\rho = T_s - T_{chill} [K]'); ylabel('\omega_c [mrad/s]');
legend('PI', 'GS', 'Location', 'southeast');
title('Pulsacja odcięcia');
nexttile; hold on
plot(rhos, T.PI_PM_deg, '--', 'Color', S.purple);
plot(rhos, T.GS_PM_deg, '-', 'Color', S.green);
ylim([80 100]);
xlabel('\rho = T_s - T_{chill} [K]'); ylabel('Zapas fazy [°]');
legend('PI', 'GS', 'Location', 'southeast');
title('Zapas fazy');
save_fig(fig, 'e03_bode_gs');

%% Odpowiedź na zakłócenie
fig = figure('Position', [80 80 1200 450]);
tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile; hold on
for k = 1:3
    [A, B, ~, Bd] = lin_thermal(P, rr(k), u0);
    for g = 0:1
        [Kp, Ki] = gs_gains(P, P.T_chill + rr(k), g);
        Acl = [A + B*[Kp 0], B; [Ki 0], 0];
        [~, ~, t, y] = dist_step(Acl, [Bd; 0], 1000);
        if g, ls = '-'; nm = 'GS'; else, ls = '--'; nm = 'PI'; end
        plot(t/60, y, ls, 'Color', cl{k}, 'DisplayName', sprintf('%s, \\rho = %d K', nm, rr(k)));
    end
end
xlim([0 240]); xlabel('Czas [min]'); ylabel('\Delta T_c [K]');
legend('Location', 'northeast');
title('Odpowiedź na skok strat cieplnych o 1 kW');
nexttile; hold on
plot(rhos, T.PI_t_recover_s/60, '--', 'Color', S.purple);
plot(rhos, T.GS_t_recover_s/60, '-', 'Color', S.green);
xlabel('\rho = T_s - T_{chill} [K]'); ylabel('Czas [min]');
legend('PI', 'GS', 'Location', 'northeast');
title('Czas powrotu do 10% wartości szczytowej');
save_fig(fig, 'e03_disturbance');

%% Porównanie nieliniowe z wykładu: sesja od 25 do 80% SOC
rows = {};
for Ta = [15 25 35]
    for s = {'CC', 'PI', 'GS', 'GS_SAFE'}
        r = simulate_session(P, strategy_config(P, s{1}), struct('Ta', Ta, 'drive_s', 0, 'soc_plug', 0.25));
        rows(end+1, :) = {s{1}, Ta, r.t_charge_min, r.Tc_max, r.E_TM_kWh}; %#ok<AGROW>
    end
end
N = cell2table(rows, 'VariableNames', {'strategy','Ta_C','t_charge_min','Tc_max_C','E_TM_kWh'});
save_csv(N, 'e03_lecture_comparison');
disp(N);

%% Przebiegi do wykładu: sesja od 25 do 80% SOC w 35°C i 25°C
o35 = struct('Ta', 35, 'drive_s', 0, 'soc_plug', 0.25);
o25 = struct('Ta', 25, 'drive_s', 0, 'soc_plug', 0.25);
names = {'CC', 'PI', 'GS', 'GS_SAFE', 'LIFE'};
fig = figure('Position', [80 80 1200 450]);
tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile; hold on
for k = 1:numel(names)
    [~, lg] = simulate_session(P, strategy_config(P, names{k}), o35);
    plot(lg.t/60, lg.Tc, 'Color', S.col(names{k}), 'DisplayName', S.short(names{k}));
    L35.(names{k}) = lg;
end
yline(P.T_lim, '--', 'limit 40°C', 'Color', S.red, 'HandleVisibility', 'off');
xlabel('Czas [min]'); ylabel('T_c [°C]'); legend('Location', 'northwest');
title('Temperatura rdzenia, otoczenie 35°C');
nexttile; hold on
plot(L35.GS_SAFE.t/60, L35.GS_SAFE.I, 'Color', S.navy);
plot(L35.LIFE.t/60, L35.LIFE.I, 'Color', S.blue);
xlabel('Czas [min]'); ylabel('Prąd pakietu [A]'); ylim([0 320]);
legend('CC, PI, GS, GS-SAFE (profil SOC z wykładu)', 'LIFE (bez profilu SOC)', 'Location', 'southwest');
title('Prąd ładowania, otoczenie 35°C');
save_fig(fig, 'e03_lecture_session_35C');

fig = figure('Position', [80 80 800 450]); hold on
lab = cell(1, 2);
for k = 2:3
    [r, lg] = simulate_session(P, strategy_config(P, names{k}), o25);
    plot(lg.t/60, lg.u, 'Color', S.col(names{k}));
    lab{k-1} = sprintf('%s, T_{c,max} = %s°C', names{k}, strrep(sprintf('%.2f', r.Tc_max), '.', ','));
end
xlabel('Czas [min]'); ylabel('Sterowanie chłodzeniem u [-]'); ylim([0 1]);
legend(lab, 'Location', 'southeast');
title('Sygnał chłodzenia PI i GS, otoczenie 25°C');
save_fig(fig, 'e03_lecture_u_25C');
out.lin = T; out.nonlin = N;
end

function [A, B, Cm, Bd] = lin_thermal(P, rho, u0)
% Model zlinearyzowany: stan [Tc; Ts], wejście u, zakłócenie Qgen
A = [-P.Gcs/P.Cc, P.Gcs/P.Cc;
      P.Gcs/P.Cs, -(P.Gcs + P.Gamb + P.Gcool*u0)/P.Cs];
B = [0; -P.Gcool*rho/P.Cs];
Cm = [1 0];
Bd = [1/P.Cc; 0];
end

function [wc, pm] = crossover(w, L)
% Pulsacja, przy której |L| = 1, i zapas fazy (interpolacja logarytmiczna)
m = abs(L);
k = find(m(1:end-1) >= 1 & m(2:end) < 1, 1);
if isempty(k), wc = NaN; pm = NaN; return, end
f = log(m(k))/(log(m(k)) - log(m(k+1)));
wc = exp(log(w(k)) + f*(log(w(k+1)) - log(w(k))));
Lc = L(k) + f*(L(k+1) - L(k));
pm = 180 + angle(Lc)*180/pi;
end

function [peak, t_rec, t, y] = dist_step(Acl, Bd, Q)
% Odpowiedź skokowa na zakłócenie Q [W], dyskretyzacja dokładna (expm)
dt = 5; t = (0:dt:4*3600)'; n = numel(t);
Ad = expm(Acl*dt);
Bdd = Acl\((Ad - eye(size(Ad)))*Bd);
x = zeros(size(Acl, 1), 1); y = zeros(n, 1);
for k = 2:n
    x = Ad*x + Bdd*Q;
    y(k) = x(1);
end
[peak, kp] = max(y);
kr = find(y(kp:end) <= 0.1*peak, 1);
if isempty(kr), t_rec = NaN; else, t_rec = t(kp + kr - 1); end
end
