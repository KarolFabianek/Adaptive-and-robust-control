%% Dane NASA Ames B0005 - spadek pojemnosci ogniwa Li-ion w kolejnych cyklach
% Porownanie dwoch prostych modeli: Q = a + b*sqrt(N) oraz Q = a + b*N.
% Podzial chronologiczny: pierwsze 70% cykli do dopasowania, reszta do testu.
% Punkt odniesienia: prognoza "bez zmian" (ostatnia pojemnosc ze zbioru uczacego).
% To dane jednego ogniwa - nie sluza do walidacji modelu cieplnego pakietu.
clear; clc; close all;

S = load('data/B0005.mat');
cycles = S.B0005.cycle;

% pojemnosc z kazdego cyklu rozladowania
Q = [];
for k = 1:numel(cycles)
    if strcmp(cycles(k).type, 'discharge')
        Q(end+1, 1) = cycles(k).data.Capacity; %#ok<SAGROW>
    end
end
N = numel(Q);
n = (1:N)';
n_train = floor(0.7*N);
tr = 1:n_train;
te = n_train+1:N;
rmse = @(a, b) sqrt(mean((a - b).^2));

% model 1: Q = a + b*sqrt(N)
X1 = [ones(N,1), sqrt(n)];
b1 = X1(tr,:) \ Q(tr);
Q1 = X1*b1;

% model 2: Q = a + b*N
X2 = [ones(N,1), n];
b2 = X2(tr,:) \ Q(tr);
Q2 = X2*b2;

rmse_sqrt = rmse(Q(te), Q1(te));
rmse_lin = rmse(Q(te), Q2(te));
rmse_const = rmse(Q(te), Q(n_train));

fprintf('NASA B0005: %d cykli rozladowania (%d uczacych, %d testowych)\n', N, n_train, N - n_train);
fprintf('Pojemnosc: %.3f Ah -> %.3f Ah\n', Q(1), Q(end));
fprintf('RMSE test  sqrt(N): %.4f Ah\n', rmse_sqrt);
fprintf('RMSE test  liniowy: %.4f Ah\n', rmse_lin);
fprintf('RMSE test  bez zmian: %.4f Ah\n', rmse_const);

T = table(N, n_train, rmse(Q(tr), Q1(tr)), rmse_sqrt, rmse(Q(tr), Q2(tr)), rmse_lin, rmse_const, Q(1), Q(end), ...
    'VariableNames', {'n_cycles', 'train_n', 'RMSE_train_sqrt_Ah', 'RMSE_test_sqrt_Ah', ...
    'RMSE_train_lin_Ah', 'RMSE_test_lin_Ah', 'RMSE_test_const_Ah', 'C_first_Ah', 'C_last_Ah'});
if ~isfolder('results'), mkdir('results'); end
writetable(T, 'results/nasa_validation.csv');
writetable(table(n, Q, Q1, Q2, 'VariableNames', {'cycle', 'capacity_Ah', 'fit_sqrt_Ah', 'fit_lin_Ah'}), ...
    'results/nasa_B0005_capacity.csv');

figure('Color', 'w', 'Position', [100 100 850 420]);
plot(n, Q, '.', 'MarkerSize', 10); hold on;
plot(n, Q1, 'LineWidth', 1.8);
plot(n, Q2, 'LineWidth', 1.8);
xline(n_train, '--', 'uczenie | test');
grid on;
xlabel('Numer cyklu rozladowania');
ylabel('Pojemnosc [Ah]');
title('NASA B0005: pomiary i modele spadku pojemnosci');
legend('pomiary', sprintf('a + b sqrt(N), RMSE test %.3f Ah', rmse_sqrt), ...
    sprintf('a + b N, RMSE test %.3f Ah', rmse_lin), 'Location', 'southwest');
if ~isfolder('figures'), mkdir('figures'); end
exportgraphics(gcf, 'figures/nasa_B0005.png', 'Resolution', 150);
