%% LAB 4 – Trwałość: 10 lat eksploatacji i adaptacyjna pętla SOH
% Sterowanie adaptacyjne i odporne · BTMS · K. Fabianek, P. Fortuna
%
% Cel: sprawdzić, która strategia ładowania zachowa SOH >= 80% po 10 latach,
%      i zobaczyć działanie nadrzędnej pętli adaptacyjnej (RLS + PI).
% Czas: ok. 1–2 min.

%% 1. Przygotowanie – wybierz klimat: 'opole' | 'madryt' | 'dubaj'
if ~exist('bms_setup', 'file'), cd('..'); end
bms_setup;
P = bms_params();
klimat = 'dubaj';

%% 2. Cztery strategie, 10 lat
strategie = {'STD_100', 'STD_90', 'LIFE', 'LIFE_ADAPT'};
figure; hold on; grid on
for k = 1:numel(strategie)
    [T, info] = simulate_lifetime(P, strategie{k}, klimat);
    plot([0; T.t_years], 100*[1; T.SOH], 'DisplayName', strrep(strategie{k}, '_', '\_'));
    fprintf('%-10s SOH(10 lat) = %5.1f%%  kal. %4.1f  cykl. %4.1f  lit. %3.1f p.p.  E_term = %4.0f kWh/rok\n', ...
        strategie{k}, 100*info.SOH_10y, 100*info.Q_cal, 100*info.Q_cyc, 100*info.Q_pl, info.E_TM_kWh_year);
    if strcmp(strategie{k}, 'LIFE_ADAPT'), Tadapt = T; end
end
yline(80, 'r--', 'cel 80%'); xlabel('Lata'); ylabel('SOH [%]'); legend('Location', 'southwest');
title(['SOH przez 10 lat – klimat: ' klimat]);
% Oczekiwane (Dubaj): STD_100 ok. 69%, STD_90 ok. 73%, LIFE ok. 78%, LIFE_ADAPT ok. 81%.

%% 3. Co robi pętla adaptacyjna?
figure; tiledlayout(3, 1);
nexttile; plot(Tadapt.t_years, Tadapt.lambda); grid on; ylabel('\lambda'); title('poziom ochrony');
nexttile; plot(Tadapt.t_years, 100*Tadapt.soc_ac); grid on; ylabel('SOC AC [%]');
nexttile; plot(Tadapt.t_years, 100*Tadapt.SOH, Tadapt.t_years, 100*soh_reference(P, Tadapt.t_years), '--');
grid on; ylabel('SOH [%]'); xlabel('Lata'); legend('SOH', 'odniesienie');

%% ZADANIA
% Z1. Zmień klimat na 'opole'. Dlaczego lambda spada do 0? Co zyskuje kierowca?
% Z2. Ustaw P.SOH_target_10y = 0.85 (Dubaj). Czy cel jest osiągalny? Co oznacza lambda = 1?
% Z3. Zmniejsz P.Ki_lam do 0.3. Jak zmienia się dynamika pętli (przeregulowanie, czas)?
% Z4. Zwiększ P.km_per_day do 80. Która składowa starzenia rośnie najbardziej?
