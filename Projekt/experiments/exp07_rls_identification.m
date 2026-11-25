function T = exp07_rls_identification()
%EXP07_RLS_IDENTIFICATION  E07 – identyfikacja online modelu ECM metodą RLS.
%
%   Ogniwo ECM 1RC w dyskretnej postaci ARX (dokładnej dla 1RC):
%       y_k = a y_{k-1} + b0 I_k + b1 I_{k-1},     y = V - OCV(SOC)
%       R0 = b0,  tau = -dt/ln(a),  R1 = (b1 + a b0)/(1 - a)
%   Pobudzenie: dynamiczny profil prądu jazdy (1 h, krok 1 s), szum
%   pomiaru napięcia 1 mV i prądu 10 mA. W 30. minucie rezystancje skokowo
%   rosną o 30% (np. spadek temperatury / starzenie). Porównujemy RLS
%   z zapominaniem (lambda = 0.995, pamięć ok. 200 s) i bez zapominania (lambda = 1).
%
%   To jest „oko” adaptacyjnego BMS: estymata R0 i R1 pozwala aktualizować
%   limit prądu z potencjału anody i SOH (R rośnie wraz ze starzeniem).
P = bms_params();
S = plot_style();
fprintf('\n=== E07: identyfikacja RLS parametrów ECM ===\n');
rs = RandStream('mt19937ar', 'Seed', 7);
dt = 1; N = 3600; t = (0:N-1)'*dt;
% profil prądu ogniwa: losowe odcinki stałe (5–90 s), -4…+2 A
% (odcinki porównywalne z tau = 40 s – pobudzenie „trwałe” dla gałęzi RC)
I = zeros(N, 1); k = 1;
while k <= N
    L = randi(rs, [5 90]);
    lvl = -4 + 6*rand(rs);
    I(k:min(N, k+L-1)) = lvl;
    k = k + L;
end
drift = ones(N, 1); drift(t >= 1800) = 1.3;
soc = zeros(N, 1); V = zeros(N, 1); V1 = 0; soc(1) = 0.8;
R0t = zeros(N, 1); R1t = R0t;
a_t = exp(-dt/P.tau1);
for k = 1:N
    [R0, R1] = cell_resistance(P, 25, soc(k), 1);
    R0t(k) = R0*drift(k); R1t(k) = R1*drift(k);
    V(k) = ocv_nmc(P, soc(k)) + V1 + R0t(k)*I(k);
    V1 = V1*a_t + R1t(k)*(1 - a_t)*I(k);
    if k < N, soc(k+1) = soc(k) + I(k)*dt/3600/P.Q_cell_Ah; end
end
Vm = V + 0.001*randn(rs, N, 1);
Im = I + 0.010*randn(rs, N, 1);
ocv_m = arrayfun(@(s) ocv_nmc(P, s), soc);
y = Vm - ocv_m;

lams = [0.995, 1.0];
est = zeros(N, 3, 2);
for j = 1:2
    th = [0.9; 0.02; -0.01]; Pc = 1e3*eye(3);
    for k = 2:N
        phi = [y(k-1); Im(k); Im(k-1)];
        K = Pc*phi/(lams(j) + phi'*Pc*phi);
        th = th + K*(y(k) - phi'*th);
        Pc = (Pc - K*phi'*Pc)/lams(j);
        a = min(max(th(1), 1e-3), 0.9999);
        est(k, :, j) = [th(2), (th(3) + a*th(2))/(1 - a), -dt/log(a)];
    end
end
win = t > 1500 & t < 1800; win2 = t > 3300;
T = table({'R0 [mOhm]'; 'R1 [mOhm]'; 'tau [s]'}, ...
    [mean(R0t(win))*1e3; mean(R1t(win))*1e3; P.tau1], ...
    [mean(est(win,1,1))*1e3; mean(est(win,2,1))*1e3; mean(est(win,3,1))], ...
    [mean(R0t(win2))*1e3; mean(R1t(win2))*1e3; P.tau1], ...
    [mean(est(win2,1,1))*1e3; mean(est(win2,2,1))*1e3; mean(est(win2,3,1))], ...
    [mean(est(win2,1,2))*1e3; mean(est(win2,2,2))*1e3; mean(est(win2,3,2))], ...
    'VariableNames', {'parametr','prawda_przed','RLS0995_przed','prawda_po','RLS0995_po','RLS1_po'});
save_csv(T, 'e07_rls_identification');
disp(T);

fig = figure('Position', [60 60 1150 600]);
tiledlayout(2, 2, 'TileSpacing', 'compact');
nexttile; plot(t/60, I, 'Color', S.grey, 'LineWidth', 0.8);
ylabel('I_{ogniwa} [A]'); xlabel('Czas [min]'); title('Pobudzenie: profil jazdy (ogniwo)');
nexttile; plot(t/60, 1e3*R0t, 'k', 'LineWidth', 2.5); hold on
plot(t/60, 1e3*est(:,1,1), 'Color', S.blue); plot(t/60, 1e3*est(:,1,2), '--', 'Color', S.orange);
ylim([10 35]); ylabel('R_0 [m\Omega]'); xlabel('Czas [min]');
legend('prawdziwa', 'RLS \lambda = 0,995', 'RLS \lambda = 1 (bez zapominania)', 'Location', 'northwest');
title('Rezystancja omowa R_0 – skok +30% w 30. minucie');
nexttile; plot(t/60, 1e3*R1t, 'k', 'LineWidth', 2.5); hold on
plot(t/60, 1e3*est(:,2,1), 'Color', S.blue); plot(t/60, 1e3*est(:,2,2), '--', 'Color', S.orange);
ylim([0 25]); ylabel('R_1 [m\Omega]'); xlabel('Czas [min]'); title('Rezystancja polaryzacji R_1');
nexttile; yline(P.tau1, 'k', 'LineWidth', 2.5); hold on
plot(t/60, est(:,3,1), 'Color', S.blue); plot(t/60, est(:,3,2), '--', 'Color', S.orange);
ylim([0 100]); ylabel('\tau [s]'); xlabel('Czas [min]'); title('Stała czasowa \tau = R_1C_1');
save_fig(fig, 'e07_rls_identification');
end
