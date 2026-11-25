%% LAB 1 – Model obiektu: pakiet 96s50p i jego dynamika cieplna
% Sterowanie adaptacyjne i odporne · BTMS · K. Fabianek, P. Fortuna
%
% Cel: poznać model pakietu i sprawdzić, dlaczego wzmocnienie obiektu
%      zależy od punktu pracy (podstawa gain schedulingu).
% Uruchamiaj sekcja po sekcji: Ctrl+Enter (Run Section).
% Czas: ok. 1 min.

%% 1. Ścieżki i parametry
if ~exist('bms_setup', 'file'), cd('..'); end     % z folderu lab/ przejdź do Projekt/
bms_setup;
P = bms_params();
fprintf('Pakiet: %.1f V, %.0f Ah, %.2f kWh, R = %.2f mOhm\n', ...
    P.ns*P.V_nom_cell, P.Q_pack_Ah, P.E_pack_kWh, 1000*P.Rn_pack);
fprintf('Pojemności cieplne: Cc = %.1f kJ/K, Cs = %.1f kJ/K\n', P.Cc/1e3, P.Cs/1e3);
% Oczekiwany wynik: 345.6 V, 175 Ah, 60.48 kWh, 53.76 mOhm; Cc = 157.6, Cs = 49.8

%% 2. Odpowiedź skokowa: stały prąd 300 A, bez chłodzenia i z chłodzeniem u = 0.5
dt = 1; N = 3600; Ta = 25;
u_list = [0 0.5];
Tc = zeros(N, 2);
for j = 1:2
    x = [Ta; Ta; 0.2; 0];
    for k = 1:N
        [x, y] = pack_step(P, x, 300, u_list(j), Ta, dt, 1);
        x(3) = 0.5;                      % SOC stały – badamy tylko termikę
        Tc(k, j) = x(1);
    end
end
figure; plot((1:N)/60, Tc); grid on
xlabel('Czas [min]'); ylabel('T_c [°C]'); legend('u = 0', 'u = 0.5', 'Location', 'southeast');
title('Odpowiedź skokowa temperatury rdzenia na prąd 300 A');
fprintf('Po 60 min: Tc = %.1f °C (u = 0), %.1f °C (u = 0.5)\n', Tc(end, 1), Tc(end, 2));

%% 3. Linearyzacja: wzmocnienie dQ/du zależy od rho = Ts - Tchill
rho = [5 10 17];
for r = rho
    fprintf('rho = %2d K: dQcool/du = Gcool*rho = %5.0f W (na 1.0 sterowania)\n', r, P.Gcool*r);
end
% Wniosek: przy rho = 5 K obiekt jest 3.4x „słabszy” niż przy 17 K.
% Stałe nastawy PI dobrane dla 17 K będą w chłodnym klimacie za wolne.

%% 4. Bieguny modelu cieplnego (bez chłodzenia)
A = [-P.Gcs/P.Cc, P.Gcs/P.Cc; P.Gcs/P.Cs, -(P.Gcs + P.Gamb)/P.Cs];
ev = sort(eig(A));                          % ev(1) – szybki, ev(2) – wolny
fprintf('Bieguny: %.2e i %.2e 1/s  ->  stałe czasowe %.1f s oraz %.2f h\n', ev(1), ev(2), -1/ev(1), -1/ev(2)/3600);
% Pytanie: która stała czasowa odpowiada wymianie rdzeń–powierzchnia,
% a która stygnięciu całego pakietu do otoczenia?

%% ZADANIA
% Z1. Zmień P.Gcs o -20% (P.Gcs = 0.8*P.Gcs; P = bms_derive(P);) i powtórz
%     sekcję 2. O ile wzrośnie różnica Tc - Ts przy 300 A? (wzór: I^2 R / Gcs)
% Z2. Ile ciepła [kW] generuje pakiet przy 150 A i 300 A? Sprawdź prawo I^2.
% Z3. Policz, po jakim czasie bez chłodzenia rdzeń przekroczy 40°C przy Ta = 35°C.
