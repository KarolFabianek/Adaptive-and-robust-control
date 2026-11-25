function [T, info] = simulate_lifetime(P, strategy, climate, opts, Pc)
%SIMULATE_LIFETIME  Symulacja 10 lat eksploatacji: starzenie + sterowanie.
%
%   [T, info] = simulate_lifetime(P, strategy, climate)
%   [T, info] = simulate_lifetime(P, strategy, climate, opts, Pc)
%     strategy – 'STD_100' | 'STD_90' | 'LIFE' | 'LIFE_ADAPT'
%     climate  – 'opole' | 'madryt' | 'dubaj'
%     opts.seed   – ziarno szumu pomiaru SOH (domyślnie 1)
%     opts.dT_amb – przesunięcie klimatu [K] (domyślnie 0)
%     opts.years  – horyzont [lata] (domyślnie P.years)
%     Pc – parametry modelu w regulatorach (domyślnie = P)
%
%   Metoda wieloskalowa: w każdym miesiącu symulowany jest dokładnie jeden
%   reprezentatywny dzień roboczy i jeden dzień w trasie (z szybkim
%   ładowaniem). Stres starzenia doby jest skalowany liczbą dni w miesiącu
%   i raz w miesiącu aktualizuje stan zdrowia baterii. Nowe SOH wpływa
%   na pojemność i rezystancję w kolejnym miesiącu (sprzężenie SOH -> R, Q).
%
%   T – tabela miesięczna, info – podsumowanie (SOH_10y itd.).

if nargin < 4 || isempty(opts), opts = struct(); end
if nargin < 5, Pc = P; end
if ~isfield(opts, 'seed'), opts.seed = 1; end
if ~isfield(opts, 'dT_amb'), opts.dT_amb = 0; end
if ~isfield(opts, 'years'), opts.years = P.years; end

C = climate_profile(climate);
cfg = strategy_config(Pc, strategy);
rs = RandStream('mt19937ar', 'Seed', opts.seed);

A = aging_init();
sup = [];
n_m = round(12*opts.years);
days_m = 365/12;
n_dc = P.dc_per_month;

% stan początkowy: 1 stycznia, pakiet w temperaturze otoczenia, SOC = cel AC
st = init_state(ambient_temp(C, 1, 0, opts.dT_amb), cfg.soc_ac, 1);

cols = {'t_years','SOH','SOH_hat','Q_cal','Q_cyc','Q_pl','lambda','soc_ac','I_cap', ...
        'T_park_max','E_TM_kWh','Tc_mean','Tc_max','Tc_max_active','soc_mean','t_dc_min','Ta_mean'};
M = nan(n_m, numel(cols));

for m = 1:n_m
    doy = (mod(m - 1, 12) + 0.5)*days_m;
    st_start = st;
    [st, Dn] = simulate_day(P, Pc, cfg, st_start, C, doy, false, opts.dT_amb);
    Dt = Dn; Dt.S = [0 0 0]; Dt.E_TM_kWh = 0; Dt.t_dc_min = NaN; Dt.Tc_max = -Inf; Dt.Tc_max_active = -Inf;
    if n_dc > 0
        [~, Dt] = simulate_day(P, Pc, cfg, st_start, C, doy, true, opts.dT_amb);
    end
    n_norm = days_m - n_dc;
    S_m = n_norm*Dn.S + n_dc*Dt.S;
    A = aging_update(P, A, S_m);

    % „pomiar” pojemności (estymator w BMS) + nadrzędna pętla SOH
    t_y = m/12;
    SOH_meas = A.SOH + P.sigma_soh_meas*randn(rs);
    [sup, lam] = soh_supervisor(Pc, sup, SOH_meas, t_y);
    if cfg.adaptive
        cfg = apply_lambda(Pc, cfg, lam);
    end
    st.SOH = A.SOH;
    st.SOH_hat = sup.soh_hat;

    w = [n_norm, n_dc]/days_m;
    M(m,:) = [t_y, A.SOH, sup.soh_hat, A.Q_cal, A.Q_cyc, A.Q_pl, cfg.lambda, cfg.soc_ac, cfg.I_cap, ...
              cfg.T_park_max, n_norm*Dn.E_TM_kWh + n_dc*Dt.E_TM_kWh, ...
              w(1)*Dn.Tc_mean + w(2)*Dt.Tc_mean, max(Dn.Tc_max, Dt.Tc_max), max(Dn.Tc_max_active, Dt.Tc_max_active), ...
              w(1)*Dn.soc_mean + w(2)*Dt.soc_mean, Dt.t_dc_min, ...
              ambient_temp(C, doy, 12, opts.dT_amb) - C.A_day*cos(2*pi*(12 - 15)/24)];
end

T = array2table(M, 'VariableNames', cols);
info.strategy = strategy;
info.climate = C.name;
info.SOH_10y = A.SOH;
info.Q_cal = A.Q_cal; info.Q_cyc = A.Q_cyc; info.Q_pl = A.Q_pl;
info.E_TM_kWh_year = sum(T.E_TM_kWh)/opts.years;
info.t_dc_mean_min = mean(T.t_dc_min, 'omitnan');
info.t_dc_max_min = max(T.t_dc_min);
info.Tc_max = max(T.Tc_max);
info.Tc_max_active = max(T.Tc_max_active);
info.soc_mean = mean(T.soc_mean);
info.lambda_mean = mean(T.lambda);
info.soc_ac_mean = mean(T.soc_ac);
info.meets_80 = A.SOH >= P.SOH_EOL;
end
