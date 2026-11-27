function R = exp06_monte_carlo(N, climate)
%EXP06_MONTE_CARLO  E06. Odporność na niepewność modelu starzenia (Monte Carlo).
%
%   R = exp06_monte_carlo(N, climate)   domyślnie N = 50, climate = 'madryt'
%
%   Dla N wylosowanych pakietów (perturb_params) każda strategia jest
%   symulowana przez 10 lat. Wszystkie strategie dostają te same próbki.
%   Strategie w pętli otwartej (STD_90, LIFE) dziedziczą niepewność modelu
%   starzenia. LIFE_ADAPT mierzy SOH i koryguje parametry ładowania.
%   Wykresy rysuje plot_e06 z plików CSV.
if nargin < 1, N = 50; end
if nargin < 2, climate = 'madryt'; end
P = bms_params();
fprintf('\n=== E06: Monte Carlo (N = %d, klimat %s) ===\n', N, climate);
strategies = {'STD_90', 'LIFE', 'LIFE_ADAPT'};
rs = RandStream('mt19937ar', 'Seed', 2026);
soh = zeros(N, numel(strategies));
lam_end = zeros(N, 1); socac_end = zeros(N, 1);
D = [];
t0 = tic;
for n = 1:N
    [Pp, d] = perturb_params(P, rs);
    D = [D; struct2table(d)]; %#ok<AGROW>
    for s = 1:numel(strategies)
        o = struct('seed', n, 'dT_amb', d.dT_amb);
        [T, info] = simulate_lifetime(Pp, strategies{s}, climate, o, P);
        soh(n, s) = info.SOH_10y;
        if strcmp(strategies{s}, 'LIFE_ADAPT')
            lam_end(n) = T.lambda(end); socac_end(n) = T.soc_ac(end);
        end
    end
    if mod(n, 5) == 0
        fprintf('   %d/%d próbek (%.0f s)\n', n, N, toc(t0));
    end
end
R = [D, array2table(100*soh, 'VariableNames', strcat('SOH10_', strategies)), ...
     table(lam_end, 100*socac_end, 'VariableNames', {'ADAPT_lambda_end', 'ADAPT_soc_ac_end_pct'})];
save_csv(R, sprintf('e06_monte_carlo_%s', climate));

st = table(strategies', 100*mean(soh)', 100*std(soh)', 100*min(soh)', 100*max(soh)', 100*mean(soh >= 0.80)', ...
    'VariableNames', {'strategy','SOH_mean_pct','SOH_std_pp','SOH_min_pct','SOH_max_pct','P_meet_80_pct'});
save_csv(st, sprintf('e06_monte_carlo_stats_%s', climate));
disp(st);
plot_e06(climate);
end
