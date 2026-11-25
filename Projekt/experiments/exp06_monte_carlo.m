function R = exp06_monte_carlo(N, climate)
%EXP06_MONTE_CARLO  E06 – odporność na niepewność modelu starzenia (Monte Carlo).
%
%   R = exp06_monte_carlo(N, climate)   (domyślnie N = 50, climate = 'madryt')
%
%   Dla N wylosowanych „rzeczywistych” pakietów (perturb_params) każda
%   strategia jest symulowana przez 10 lat. Te same próbki dla wszystkich
%   strategii (common random numbers). Pytanie: jaki odsetek pakietów
%   kończy z SOH >= 80%? Strategie w pętli otwartej (STD_90, LIFE)
%   dziedziczą całą niepewność modelu starzenia. LIFE_ADAPT mierzy SOH
%   i koryguje parametry ładowania, więc rozrzut wyniku maleje.
if nargin < 1, N = 50; end
if nargin < 2, climate = 'madryt'; end
P = bms_params();
S = plot_style();
fprintf('\n=== E06: Monte Carlo (N = %d, klimat %s) ===\n', N, climate);
strategies = {'STD_90', 'LIFE', 'LIFE_ADAPT'};
rs = RandStream('mt19937ar', 'Seed', 2026);
soh = zeros(N, numel(strategies));
traj = zeros(N, 120, numel(strategies));
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
        traj(n, :, s) = T.SOH';
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

%% Histogramy
fig = figure('Position', [60 60 1150 420]);
tiledlayout(1, 2, 'TileSpacing', 'compact');
nexttile; hold on
edges = 70:1:92;
for s = 1:numel(strategies)
    histogram(100*soh(:, s), edges, 'FaceColor', S.col(strategies{s}), 'FaceAlpha', 0.55, 'EdgeColor', 'none');
end
xline(80, '--r', '80%', 'LineWidth', 2, 'LabelVerticalAlignment', 'bottom', 'HandleVisibility', 'off');
yl = ylim; ylim([0 1.7*yl(2)]);
xlabel('SOH po 10 latach [%]'); ylabel('liczba pakietów');
legend(arrayfun(@(s) sprintf('%s: %.0f%% spełnia cel, \\sigma = %.1f p.p.', S.label(strategies{s}), ...
    st.P_meet_80_pct(s), st.SOH_std_pp(s)), 1:numel(strategies), 'UniformOutput', false), ...
    'Location', 'northwest', 'FontSize', 9);
title(sprintf('Rozkład SOH po 10 latach – %d losowych pakietów', N));

nexttile; hold on
ty = (1:120)/12;
for s = 1:numel(strategies)
    Y = 100*traj(:, :, s);
    fill([ty, fliplr(ty)], [min(Y), fliplr(max(Y))], S.col(strategies{s}), 'FaceAlpha', 0.18, 'EdgeColor', 'none');
    plot(ty, median(Y), 'Color', S.col(strategies{s}));
end
yline(80, '--r'); xlabel('Lata'); ylabel('SOH [%]'); ylim([68 100]);
title('Obwiednie min–max i mediana');
save_fig(fig, sprintf('e06_monte_carlo_%s', climate));
end
