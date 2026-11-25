function T = exp08_nasa_validation()
%EXP08_NASA_VALIDATION  E08 – kształt krzywej degradacji na danych NASA B0005.
%
%   Dane: NASA Ames PCoE, ogniwo 18650 (2 Ah), cykle 24°C, ładowanie CC-CV
%   1.5 A do 4.2 V, rozładowanie 2 A do 2.7 V. Plik data/B0005.mat.
%
%   Dopasowujemy model potęgowy Q(n) = Q0 - b n^z (MNK dla każdego z)
%   na pierwszych 70% cykli i sprawdzamy prognozę na pozostałych 30%.
%   Porównanie: z dopasowane, z = 0.5 (jak w naszym modelu ~ sqrt(Ah)),
%   z = 1 (model liniowy z wersji v1 projektu).
%   Uwaga: to walidacja KSZTAŁTU degradacji cyklicznej pojedynczego
%   ogniwa, nie termiki pakietu ani starzenia kalendarzowego.
S = plot_style();
fprintf('\n=== E08: dane NASA B0005 ===\n');
root = fileparts(fileparts(mfilename('fullpath')));
d = load(fullfile(root, 'data', 'B0005.mat'));
c = d.B0005.cycle;
Q = [];
for k = 1:numel(c)
    if strcmp(c(k).type, 'discharge')
        Q(end+1, 1) = c(k).data.Capacity; %#ok<AGROW>
    end
end
n = (1:numel(Q))';
ntr = round(0.7*numel(Q));
tr = n <= ntr; te = ~tr;

zs = 0.2:0.01:3.0;
rm = zeros(size(zs));
for i = 1:numel(zs)
    [~, ~, rm(i)] = fitz(n, Q, tr, zs(i));
end
[~, ib] = min(rm);
z_best = zs(ib);
cases = [z_best, 0.5, 1.0];
names = {sprintf('dopasowane z = %.2f', z_best), 'z = 0.5 (pierwiastek)', 'z = 1 (liniowy)'};
rows = zeros(3, 5);
fits = zeros(numel(n), 3);
for i = 1:3
    [Q0, b, rtr] = fitz(n, Q, tr, cases(i));
    fits(:, i) = Q0 - b*n.^cases(i);
    rte = sqrt(mean((Q(te) - fits(te, i)).^2));
    rows(i, :) = [cases(i), Q0, b, rtr, rte];
end
T = array2table(rows, 'VariableNames', {'z','Q0_Ah','b','RMSE_train_Ah','RMSE_test_Ah'});
T = addvars(T, names', 'Before', 1, 'NewVariableNames', 'model');
save_csv(T, 'e08_nasa_fit');
save_csv(table(n, Q, 'VariableNames', {'cycle','capacity_Ah'}), 'e08_nasa_B0005_capacity');
disp(T);

fig = figure('Position', [60 60 1100 420]);
tiledlayout(1, 2, 'TileSpacing', 'compact');
nexttile;
plot(n, Q, '.', 'Color', S.grey, 'MarkerSize', 10); hold on
cl = {S.blue, S.green, S.orange};
for i = 1:3, plot(n, fits(:, i), 'Color', cl{i}); end
xline(ntr + 0.5, ':', 'uczenie | test');
yline(0.8*Q(1), '--r', '80% pojemności początkowej');
xlabel('Numer cyklu'); ylabel('Pojemność [Ah]');
legend([{'pomiar NASA B0005'}, names], 'Location', 'northeast');
title('Degradacja ogniwa 18650: pomiar i modele potęgowe');
nexttile;
plot(zs, 1000*rm, 'Color', S.navy); hold on
plot(z_best, 1000*rm(ib), 'o', 'MarkerFaceColor', S.blue);
xline(0.5, ':', 'z = 0.5'); xline(1, ':', 'z = 1');
xlabel('wykładnik z'); ylabel('RMSE na danych uczących [mAh]');
title('Który wykładnik najlepiej opisuje dane?');
save_fig(fig, 'e08_nasa_B0005');
end

function [Q0, b, r] = fitz(n, Q, tr, z)
X = [ones(nnz(tr), 1), -n(tr).^z];
th = X\Q(tr);
Q0 = th(1); b = th(2);
r = sqrt(mean((Q(tr) - X*th).^2));
end
