%% LAB 2 – Regulator chłodzenia: PI o stałych nastawach vs gain scheduling
% Sterowanie adaptacyjne i odporne · BTMS · K. Fabianek, P. Fortuna
%
% Cel: porównać PI i GS w trzech klimatach, zobaczyć harmonogram nastaw
%      i zmierzyć pulsację odcięcia pętli w różnych punktach pracy.
% Czas: ok. 1 min.

%% 1. Przygotowanie
if ~exist('bms_setup', 'file'), cd('..'); end
bms_setup;
P = bms_params();

%% 2. Harmonogram nastaw Kp(rho), Ki(rho)
rho = 2:0.5:25;
Kp = zeros(size(rho)); Ki = Kp;
for i = 1:numel(rho)
    [Kp(i), Ki(i)] = gs_gains(P, P.T_chill + rho(i), true);
end
figure; yyaxis left; plot(rho, Kp); ylabel('K_p [1/K]');
yyaxis right; plot(rho, 1e6*Ki); ylabel('K_i [10^{-6}/(K s)]');
xlabel('\rho = T_s - T_{chill} [K]'); grid on; title('Harmonogram GS: k = clip(17/\rho, 1, 3)');

%% 3. Sesja szybkiego ładowania 25 -> 80% SOC dla PI i GS w trzech klimatach
fprintf('\n   Ta     PI: Tc,max   GS: Tc,max   różnica\n');
for Ta = [15 25 35]
    o = struct('Ta', Ta, 'drive_s', 0, 'soc_plug', 0.25);
    a = simulate_session(P, strategy_config(P, 'PI'), o);
    b = simulate_session(P, strategy_config(P, 'GS'), o);
    fprintf('  %3d°C    %6.2f °C    %6.2f °C   %+5.2f K\n', Ta, a.Tc_max, b.Tc_max, b.Tc_max - a.Tc_max);
end
% Oczekiwane: przy 35°C (punkt projektowy) GS ≈ PI, przy 15–25°C GS chłodniej o ok. 0,4–0,6 K.

%% 4. Przebiegi przy 25°C
o = struct('Ta', 25, 'drive_s', 0, 'soc_plug', 0.25);
[~, la] = simulate_session(P, strategy_config(P, 'PI'), o);
[~, lb] = simulate_session(P, strategy_config(P, 'GS'), o);
figure; tiledlayout(2, 1);
nexttile; plot(la.t/60, la.Tc, lb.t/60, lb.Tc); grid on; ylabel('T_c [°C]'); legend('PI', 'GS');
nexttile; plot(la.t/60, la.u, lb.t/60, lb.u); grid on; ylabel('u'); xlabel('Czas [min]');

%% 5. Pulsacja odcięcia pętli otwartej (bez Control System Toolbox)
u0 = 0.3; w = logspace(-5, -1, 400);
fprintf('\n  rho    wc PI [mrad/s]   wc GS [mrad/s]\n');
for r = [6 10 17]
    A = [-P.Gcs/P.Cc, P.Gcs/P.Cc; P.Gcs/P.Cs, -(P.Gcs + P.Gamb + P.Gcool*u0)/P.Cs];
    B = [0; -P.Gcool*r/P.Cs];
    wc = zeros(1, 2);
    for g = 0:1
        [kp, ki] = gs_gains(P, P.T_chill + r, g);
        L = arrayfun(@(wk) (kp + ki/(1i*wk))*(-[1 0]*((1i*wk*eye(2) - A)\B)), w);
        wc(g+1) = w(find(abs(L) < 1, 1));
    end
    fprintf('  %2d K       %5.2f            %5.2f\n', r, 1e3*wc);
end
% Oczekiwane: PI zwalnia ok. 3x przy rho = 6 K (0.88), GS utrzymuje ok. 2.67 mrad/s.

%% ZADANIA
% Z1. Zmień P.gs_max z 3 na 5. Co dzieje się z wc przy rho = 4 K? Czy warto?
% Z2. Wyłącz feedforward (strategia 'GS' vs 'GS_SAFE'). O ile rośnie Tc,max przy 35°C?
% Z3. Dobierz własne Kp dla PI tak, by przy 15°C dorównał GS. Co dzieje się przy 35°C?
