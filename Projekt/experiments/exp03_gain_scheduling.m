function out = exp03_gain_scheduling()
%EXP03_GAIN_SCHEDULING  E03 – analiza regulatora chłodzenia PI vs GS.
%
%   1) Linearyzacja pętli termicznej w punktach pracy rho = Ts - Tchill
%      (4…20 K) i analiza częstotliwościowa bez Control System Toolbox:
%      pulsacja odcięcia omega_c, zapas fazy PM, bieguny pętli zamkniętej.
%   2) Odpowiedź liniowa na skok strat cieplnych +1 kW (zakłócenie).
%   3) Porównanie nieliniowe z wykładu: sesja 25 -> 80% przy 15/25/35°C.
%
%   Wniosek oczekiwany: przy stałych nastawach wzmocnienie pętli maleje
%   proporcjonalnie do rho, więc regulator PI „zwalnia” w chłodnym klimacie.
%   GS utrzymuje omega_c i dynamikę niemal stałe w całym zakresie pracy.
P = bms_params();
S = plot_style();
fprintf('\n=== E03: gain scheduling – analiza ===\n');

rhos = 4:0.5:20;
u0 = 0.3;
w = logspace(-5, -1, 400);
res = zeros(numel(rhos), 9);
Lmag = struct();
for i = 1:numel(rhos)
    rho = rhos(i);
    [A, B, Cm, Bd] = lin_thermal(P, rho, u0);
    for g = 0:1
        [Kp, Ki] = gs_gains(P, P.T_chill + rho, g);
        L = zeros(size(w));
        for k = 1:numel(w)
            G = -Cm*((1i*w(k)*eye(2) - A)\B);     % dodatnie wzmocnienie u -> -Tc
            L(k) = (Kp + Ki/(1i*w(k)))*G;
        end
        [wc, pm] = crossover(w, L);
        Acl = [A + B*[Kp 0], B; [Ki 0], 0];
        ev = eig(Acl);
        [dTmax, t_rec] = dist_step(Acl, [Bd; 0], 1000);
        res(i, (1:4) + 4*g) = [wc, pm, max(real(ev)), dTmax];
        if g == 0, res(i, 9) = t_rec; else, res(i, 9) = res(i, 9) + 1i*t_rec; end
        if any(abs(rho - [5 10 17]) < 1e-9)
            Lmag.(sprintf('r%d_g%d', rho, g)) = L;
        end
    end
end
T = table(rhos', res(:,1), res(:,2), res(:,3), res(:,4), real(res(:,9)), ...
          res(:,5), res(:,6), res(:,7), res(:,8), imag(res(:,9)), ...
    'VariableNames', {'rho_K','PI_wc_rad_s','PI_PM_deg','PI_max_real_pole','PI_dTc_peak_K','PI_t_recover_s', ...
                      'GS_wc_rad_s','GS_PM_deg','GS_max_real_pole','GS_dTc_peak_K','GS_t_recover_s'});
save_csv(T, 'e03_gs_linear_analysis');

%% Wykres: Bode
fig = figure('Position', [80 80 1100 430]);
tiledlayout(1, 2, 'TileSpacing', 'compact');
cl = {S.red, S.orange, S.blue};
rr = [5 10 17];
nexttile; hold on
for k = 1:3
    loglog(w, abs(Lmag.(sprintf('r%d_g0', rr(k)))), '--', 'Color', cl{k});
    loglog(w, abs(Lmag.(sprintf('r%d_g1', rr(k)))), '-', 'Color', cl{k});
end
set(gca, 'XScale', 'log', 'YScale', 'log'); yline(1, 'k:');
xlabel('\omega [rad/s]'); ylabel('|L(j\omega)|');
legend('PI, \rho = 5 K', 'GS, \rho = 5 K', 'PI, \rho = 10 K', 'GS, \rho = 10 K', 'PI, \rho = 17 K', 'GS = PI, \rho = 17 K', ...
    'Location', 'southwest');
title('Charakterystyka amplitudowa pętli otwartej');
nexttile; yyaxis left
plot(rhos, T.PI_wc_rad_s*1e3, '--', 'Color', S.orange); hold on
plot(rhos, T.GS_wc_rad_s*1e3, '-', 'Color', S.blue);
ylabel('\omega_c [mrad/s]');
yyaxis right
plot(rhos, T.PI_PM_deg, '--', 'Color', S.grey); plot(rhos, T.GS_PM_deg, '-', 'Color', S.green);
ylabel('zapas fazy [°]'); xlabel('\rho = T_s - T_{chill} [K]');
legend('\omega_c PI', '\omega_c GS', 'PM PI', 'PM GS', 'Location', 'east');
title('GS utrzymuje stałą pulsację odcięcia dla \rho \geq 5,7 K');
save_fig(fig, 'e03_bode_gs');

%% Wykres: odpowiedź na zakłócenie
fig = figure('Position', [80 80 1100 400]);
tiledlayout(1, 2, 'TileSpacing', 'compact');
nexttile; hold on
for k = 1:3
    [A, B, Cm, Bd] = lin_thermal(P, rr(k), u0); %#ok<ASGLU>
    for g = 0:1
        [Kp, Ki] = gs_gains(P, P.T_chill + rr(k), g);
        Acl = [A + B*[Kp 0], B; [Ki 0], 0];
        [~, ~, t, y] = dist_step(Acl, [Bd; 0], 1000);
        ls = '--'; if g, ls = '-'; end
        plot(t/60, y, ls, 'Color', cl{k});
    end
end
xlabel('Czas [min]'); ylabel('\Delta T_c [K]');
legend('PI, \rho = 5 K', 'GS, \rho = 5 K', 'PI, \rho = 10 K', 'GS, \rho = 10 K', 'PI, \rho = 17 K', 'GS, \rho = 17 K');
title('Skok strat cieplnych +1 kW (model zlinearyzowany)');
nexttile;
plot(rhos, T.PI_t_recover_s/60, '--', 'Color', S.orange); hold on
plot(rhos, T.GS_t_recover_s/60, '-', 'Color', S.blue);
xlabel('\rho [K]'); ylabel('czas powrotu do 10% piku [min]');
legend('PI', 'GS'); title('Szybkość kompensacji zakłócenia');
save_fig(fig, 'e03_disturbance');

%% Porównanie nieliniowe (wykład): 25 -> 80% SOC
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

%% Przebiegi do wykładu: sesja 25 -> 80% przy 35°C i 25°C
o35 = struct('Ta', 35, 'drive_s', 0, 'soc_plug', 0.25);
o25 = struct('Ta', 25, 'drive_s', 0, 'soc_plug', 0.25);
names = {'CC', 'PI', 'GS', 'GS_SAFE', 'LIFE'};
fig = figure('Position', [80 80 1150 420]);
tiledlayout(1, 2, 'TileSpacing', 'compact');
nexttile; hold on
for k = 1:numel(names)
    [~, lg] = simulate_session(P, strategy_config(P, names{k}), o35);
    plot(lg.t/60, lg.Tc, 'Color', S.col(names{k}));
    L35.(names{k}) = lg;
end
yline(P.T_lim, '--r', 'kryterium 40°C', 'HandleVisibility', 'off');
xlabel('Czas [min]'); ylabel('T_c [°C]'); title('Temperatura rdzenia, T_a = 35°C');
legend(cellfun(@(x) S.label(x), names, 'UniformOutput', false), 'Location', 'northwest');
nexttile; hold on
ls_ = {'', '', '', '-', '-'};
plot(L35.PI.t/60, L35.PI.I, '--', 'Color', S.col('PI'), 'LineWidth', 3.5);
for k = [4 5]
    plot(L35.(names{k}).t/60, L35.(names{k}).I, ls_{k}, 'Color', S.col(names{k}));
end
xlabel('Czas [min]'); ylabel('Prąd pakietu [A]'); ylim([0 320]);
legend('PI (= GS\_SAFE, ten sam profil)', S.label('GS_SAFE'), S.label('LIFE'), 'Location', 'southwest');
title('Prąd: profil SOC (PI, GS\_SAFE) vs LIFE (300 A do końca, anoda bezpieczna)');
save_fig(fig, 'e03_lecture_session_35C');

fig = figure('Position', [80 80 800 400]); hold on
for k = 2:3
    [r, lg] = simulate_session(P, strategy_config(P, names{k}), o25);
    plot(lg.t/60, lg.u, 'Color', S.col(names{k}));
    lab{k-1} = sprintf('%s · T_{c,max} = %.2f°C', names{k}, r.Tc_max); %#ok<AGROW>
end
xlabel('Czas [min]'); ylabel('sygnał chłodzenia u [0…1]'); ylim([0 1]);
legend(lab, 'Location', 'southeast'); title('PI vs GS przy T_a = 25°C (sesja 25 \rightarrow 80% SOC)');
save_fig(fig, 'e03_lecture_u_25C');
out.lin = T; out.nonlin = N;
end

function [A, B, Cm, Bd] = lin_thermal(P, rho, u0)
% Model zlinearyzowany: x = [Tc; Ts], wejście u, zakłócenie Qgen
A = [-P.Gcs/P.Cc, P.Gcs/P.Cc;
      P.Gcs/P.Cs, -(P.Gcs + P.Gamb + P.Gcool*u0)/P.Cs];
B = [0; -P.Gcool*rho/P.Cs];
Cm = [1 0];
Bd = [1/P.Cc; 0];
end

function [wc, pm] = crossover(w, L)
m = abs(L);
k = find(m(1:end-1) >= 1 & m(2:end) < 1, 1);
if isempty(k), wc = NaN; pm = NaN; return, end
f = log(m(k))/(log(m(k)) - log(m(k+1)));
wc = exp(log(w(k)) + f*(log(w(k+1)) - log(w(k))));
Lc = L(k) + f*(L(k+1) - L(k));
pm = 180 + angle(Lc)*180/pi;
end

function [peak, t_rec, t, y] = dist_step(Acl, Bd, Q)
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
