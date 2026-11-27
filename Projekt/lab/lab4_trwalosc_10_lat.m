%% LAB 4. Trwałość baterii przez 10 lat i adaptacyjna pętla SOH
% Sterowanie adaptacyjne i odporne, BTMS. Karol Fabianek, Paweł Fortuna
%
% Cel: sprawdzić, która strategia ładowania zachowa SOH co najmniej 80%
% po 10 latach, i pokazać działanie nadrzędnej pętli adaptacyjnej (RLS i PI).

%% 1. Przygotowanie. Dostępne klimaty: 'opole', 'madryt', 'dubaj'
if ~exist('bms_setup', 'file'), cd('..'); end
bms_setup;
P = bms_params();
klimat = 'dubaj';

%% 2. Cztery strategie przez 10 lat
strategie = {'STD_100', 'STD_90', 'LIFE', 'LIFE_ADAPT'};
figure; hold on; grid on
for k = 1:numel(strategie)
    [T, info] = simulate_lifetime(P, strategie{k}, klimat);
    plot([0; T.t_years], 100*[1; T.SOH], 'LineWidth', 1.5, 'DisplayName', strrep(strategie{k}, '_', '-'));
    fprintf('%-10s SOH po 10 latach %5.1f%%, straty: kalendarzowe %4.1f, cykliczne %4.1f, litowanie %3.1f p.p., energia BTMS %4.0f kWh/rok\n', ...
        strategie{k}, 100*info.SOH_10y, 100*info.Q_cal, 100*info.Q_cyc, 100*info.Q_pl, info.E_TM_kWh_year);
    if strcmp(strategie{k}, 'LIFE_ADAPT'), Tadapt = T; end
end
yline(80, 'r--', 'wymaganie 80%', 'HandleVisibility', 'off');
xlabel('Czas eksploatacji [lata]'); ylabel('SOH [%]'); legend('Location', 'southwest');
title(['Stan zdrowia baterii przez 10 lat, klimat: ' klimat]);
% Wynik dla Dubaju: STD_100 około 69%, STD_90 około 73%, LIFE około 78%, LIFE_ADAPT około 81%.

%% 3. Działanie pętli adaptacyjnej
figure; tiledlayout(3, 1);
nexttile; plot(Tadapt.t_years, Tadapt.lambda, 'LineWidth', 1.5); grid on
ylabel('\lambda'); title('Poziom ochrony baterii');
nexttile; plot(Tadapt.t_years, 100*Tadapt.soc_ac, 'LineWidth', 1.5); grid on; ylabel('Cel ładowania AC [%]');
nexttile; plot(Tadapt.t_years, 100*Tadapt.SOH, Tadapt.t_years, 100*soh_reference(P, Tadapt.t_years), '--', 'LineWidth', 1.5);
grid on; ylabel('SOH [%]'); xlabel('Czas eksploatacji [lata]'); legend('SOH', 'trajektoria odniesienia');

%% ZADANIA
% Z1. Zmień klimat na 'opole'. Dlaczego lambda spada do 0 i co zyskuje kierowca?
% Z2. Ustaw P.SOH_target_10y = 0.85 dla Dubaju. Czy cel jest osiągalny i co oznacza lambda = 1?
% Z3. Zmniejsz P.Ki_lam do 0.3. Jak zmieniają się przeregulowanie i czas reakcji pętli?
% Z4. Zwiększ P.km_per_day do 80. Która składowa starzenia rośnie najbardziej?
