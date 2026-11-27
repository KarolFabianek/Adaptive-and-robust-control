%% LAB 2. Regulator chłodzenia: PI o stałych nastawach i gain scheduling
% Sterowanie adaptacyjne i odporne, BTMS. Karol Fabianek, Paweł Fortuna
%
% Cel: porównać regulatory PI i GS w trzech temperaturach otoczenia,
% obejrzeć harmonogram nastaw i zmierzyć pulsację odcięcia pętli
% w różnych punktach pracy.

%% 1. Przygotowanie
if ~exist('bms_setup', 'file'), cd('..'); end
bms_setup;
P = bms_params();

%% 2. Harmonogram nastaw Kp(rho) i Ki(rho)
rho = 2:0.5:25;
Kp = zeros(size(rho)); Ki = Kp;
for i = 1:numel(rho)
    [Kp(i), Ki(i)] = gs_gains(P, P.T_chill + rho(i), true);
end
figure; yyaxis left; plot(rho, Kp, 'LineWidth', 1.5); ylabel('K_p [1/K]');
yyaxis right; plot(rho, 1e6*Ki, 'LineWidth', 1.5); ylabel('K_i [10^{-6}/(K s)]');
xlabel('\rho = T_s - T_{chill} [K]'); grid on
title('Harmonogram nastaw: k(\rho) = 17/\rho w granicach od 1 do 3');

%% 3. Szybkie ładowanie od 25 do 80% SOC, regulatory PI i GS
fprintf('\n   Ta     Tc,max PI    Tc,max GS    różnica\n');
for Ta = [15 25 35]
    o = struct('Ta', Ta, 'drive_s', 0, 'soc_plug', 0.25);
    a = simulate_session(P, strategy_config(P, 'PI'), o);
    b = simulate_session(P, strategy_config(P, 'GS'), o);
    fprintf('  %3d°C    %6.2f °C    %6.2f °C   %+5.2f K\n', Ta, a.Tc_max, b.Tc_max, b.Tc_max - a.Tc_max);
end
% Przy 35°C (punkt projektowy) oba regulatory działają tak samo.
% Przy 15°C i 25°C regulator GS utrzymuje rdzeń chłodniejszy o 0,4 do 0,6 K.

%% 4. Przebiegi przy 25°C
o = struct('Ta', 25, 'drive_s', 0, 'soc_plug', 0.25);
[~, la] = simulate_session(P, strategy_config(P, 'PI'), o);
[~, lb] = simulate_session(P, strategy_config(P, 'GS'), o);
figure; tiledlayout(2, 1);
nexttile; plot(la.t/60, la.Tc, lb.t/60, lb.Tc, 'LineWidth', 1.5); grid on
ylabel('Temperatura rdzenia [°C]'); legend('PI', 'GS'); title('Szybkie ładowanie przy 25°C');
nexttile; plot(la.t/60, la.u, lb.t/60, lb.u, 'LineWidth', 1.5); grid on
ylabel('Sterowanie chłodzeniem u'); xlabel('Czas [min]');

%% 5. Pulsacja odcięcia pętli otwartej, bez Control System Toolbox
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
% Przy rho = 6 K pętla z regulatorem PI jest trzy razy wolniejsza (0,88 mrad/s).
% Regulator GS utrzymuje pulsację odcięcia na podobnym poziomie we wszystkich punktach pracy.

%% ZADANIA
% Z1. Zmień P.gs_max z 3 na 5. Jak zmienia się wc przy rho = 4 K? Czy taka zmiana jest uzasadniona?
% Z2. Porównaj strategie 'GS' i 'GS_SAFE' przy 35°C. Jaki jest wpływ sprzężenia w przód na Tc,max?
% Z3. Dobierz Kp regulatora PI tak, aby przy 15°C dorównał GS. Jak działa wtedy przy 35°C?
