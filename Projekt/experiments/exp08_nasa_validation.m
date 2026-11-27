function T = exp08_nasa_validation()
%EXP08_NASA_VALIDATION  E08. Kształt krzywej degradacji na danych NASA B0005.
%
%   Dane: NASA Ames PCoE, ogniwo 18650 o pojemności 2 Ah, cykle w 24°C,
%   ładowanie CC-CV 1,5 A do 4,2 V, rozładowanie 2 A do 2,7 V.
%   Model potęgowy Q(n) = Q0 - b n^z dopasowujemy metodą najmniejszych
%   kwadratów na pierwszych 70% cykli i sprawdzamy na pozostałych 30%.
%   Porównanie: wykładnik dopasowany, z = 0,5 (pierwiastkowy, jak w modelu
%   starzenia cyklicznego projektu) i z = 1 (liniowy).
%   To sprawdzenie kształtu degradacji pojedynczego ogniwa, a nie termiki
%   pakietu ani starzenia kalendarzowego.
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
rm = zeros(size(zs)); rmt = rm;
for i = 1:numel(zs)
    [Q0, b, rm(i)] = fitz(n, Q, tr, zs(i));
    rmt(i) = sqrt(mean((Q(te) - (Q0 - b*n(te).^zs(i))).^2));
end
[~, ib] = min(rm);
z_best = zs(ib);
cases = [z_best, 0.5, 1.0];
names = {sprintf('dopasowane z = %s', strrep(sprintf('%.2f', z_best), '.', ',')), ...
         'z = 0,5 (pierwiastkowy)', 'z = 1 (liniowy)'};
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

fig = figure('Position', [60 60 1250 470]);
tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile; hold on
xregion(ntr + 0.5, numel(Q) + 0.5, 'FaceColor', [0.85 0.85 0.85], 'FaceAlpha', 0.35, 'HandleVisibility', 'off');
plot(n, Q, '.', 'Color', S.grey, 'MarkerSize', 11, 'DisplayName', 'pomiar NASA B0005');
cl = {S.blue, S.green, S.orange};
for i = 1:3, plot(n, fits(:, i), 'Color', cl{i}, 'DisplayName', names{i}); end
yline(0.8*Q(1), '--', '80% pojemności początkowej', 'Color', S.red, 'HandleVisibility', 'off');
text(ntr + 3, 1.95, 'dane testowe', 'FontSize', 11, 'Color', [0.35 0.35 0.35]);
xlabel('Numer cyklu'); ylabel('Pojemność [Ah]');
legend('Location', 'southwest');
title('Pojemność ogniwa B0005 i modele potęgowe');
nexttile; hold on
plot(zs, 1000*rm, 'Color', S.navy);
plot(zs, 1000*rmt, '--', 'Color', S.orange);
plot(z_best, 1000*rm(ib), 'o', 'Color', S.navy, 'MarkerFaceColor', S.navy, 'HandleVisibility', 'off');
xline(0.5, ':', 'z = 0,5', 'HandleVisibility', 'off'); xline(1, ':', 'z = 1', 'HandleVisibility', 'off');
ylim([0 200]);
xlabel('Wykładnik z'); ylabel('RMSE [mAh]');
legend('dane uczące (70% cykli)', 'dane testowe (30% cykli)', 'Location', 'north');
title('Błąd modelu w funkcji wykładnika z');
save_fig(fig, 'e08_nasa_B0005');
end

function [Q0, b, r] = fitz(n, Q, tr, z)
% Metoda najmniejszych kwadratów dla Q = Q0 - b n^z przy ustalonym z
X = [ones(nnz(tr), 1), -n(tr).^z];
th = X\Q(tr);
Q0 = th(1); b = th(2);
r = sqrt(mean((Q(tr) - X*th).^2));
end
