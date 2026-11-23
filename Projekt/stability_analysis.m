%% Nastawy regulatora i lokalna analiza stabilnosci
% 1) Nastawy PI i GS w funkcji rho = Ts - Tcool.
% 2) Linearyzacja ukladu zamknietego w punkcie rownowagi (Tc = Tref) i wartosci
%    wlasne macierzy przejscia (model dyskretny, krok dt). Stabilny gdy |lambda| < 1.
%    To analiza lokalna - nie jest dowodem stabilnosci dla calego zakresu pracy.
clear; clc;
p = params();

%% 1) Nastawy w funkcji rho
rho = [4 6 8 10 12 14 17 20]';
Kp_PI = zeros(size(rho)); Ki_PI = Kp_PI; Kp_GS = Kp_PI; Ki_GS = Kp_PI;
for i = 1:numel(rho)
    [Kp_PI(i), Ki_PI(i)] = controller_gains(p, 'PI', p.Tcool + rho(i));
    [Kp_GS(i), Ki_GS(i)] = controller_gains(p, 'GS', p.Tcool + rho(i));
end
disp(table(rho, Kp_PI, Ki_PI, Kp_GS, Ki_GS));

figure('Color', 'w');
plot(rho, Kp_PI, 'o-', rho, Kp_GS, 's-', 'LineWidth', 1.5);
grid on;
xlabel('\rho = T_s - T_{cool} [K]');
ylabel('K_p [1/K]');
title('Nastawa K_p: PI (stala) i GS (zalezna od \rho)');
legend('PI', 'GS');
if ~isfolder('figures'), mkdir('figures'); end
exportgraphics(gcf, 'figures/gains_vs_rho.png', 'Resolution', 150);

%% 2) Linearyzacja w punktach rownowagi
% W stanie ustalonym integrator sprowadza Tc do Tref, wiec:
%   Ts* = Tref - Qgen/Gcs,   Qcool* = Qgen - Gamb*(Ts* - Ta),   u* z Qcool*
% Jesli Ts* <= Tcool albo u* poza [0, 1], rownowaga nie istnieje (chlodzenie
% nasycone) - wtedy punkt oznaczamy jako nieosiagalny.
ambients = [15 25 35];
currents = [120 210 300];
socs = [0.25 0.52 0.79];
strategies = {'PI', 'GS'};

rows = {};
for Ta = ambients
    for I = currents
        for soc = socs
            for k = 1:numel(strategies)
                st = strategies{k};
                Tc = p.Tref;
                R = p.Rn*min(1.4, max(0.7, 1 + 0.2*(0.5 - soc) + 0.002*(25 - Tc)));
                Qgen = I^2*R;
                Ts = Tc - Qgen/p.Gcs;
                [Kp, Ki] = controller_gains(p, st, Ts);
                Qcool = Qgen - p.Gamb*(Ts - Ta);

                if p.Gcool*(Ts - p.Tcool) <= p.Qcool_max
                    Bu = p.Gcool*(Ts - p.Tcool);   % dQcool/du
                    u = Qcool/Bu;
                    Bs = p.Gcool*u;                % dQcool/dTs
                else
                    Bu = p.Qcool_max;              % ograniczenie mocy chlodzenia
                    u = Qcool/Bu;
                    Bs = 0;
                end

                feasible = Ts > p.Tcool && u >= 0 && u <= 1;
                lam = NaN;
                tau = NaN;
                if feasible
                    dR_dTc = -0.002*p.Rn;
                    % stany: [Tc; Ts; z]
                    A = [1 + p.dt*(I^2*dR_dTc - p.Gcs)/p.Cc,  p.dt*p.Gcs/p.Cc,                       0;
                         p.dt*(p.Gcs - Bu*Kp)/p.Cs,          1 - p.dt*(p.Gcs + p.Gamb + Bs)/p.Cs,  -p.dt*Bu/p.Cs;
                         p.dt*Ki,                            0,                                     1];
                    lam = max(abs(eig(A)));
                    tau = -p.dt/log(lam);         % dominujaca stala czasowa [s]
                end
                rows(end+1, :) = {string(st), soc, I, Ta, Ts, u, feasible, lam, tau}; %#ok<SAGROW>
            end
        end
    end
end

J = cell2table(rows, 'VariableNames', {'strategy', 'SOC', 'I_A', 'Ta_C', 'Ts_eq_C', 'u_eq', ...
    'feasible', 'max_abs_lambda', 'tau_dominant_s'});
if ~isfolder('results'), mkdir('results'); end
writetable(J, 'results/stability.csv');

ok = J.feasible;
fprintf('\nPunkty rownowagi osiagalne: %d z %d\n', sum(ok), height(J));
fprintf('Wszystkie osiagalne punkty stabilne (|lambda| < 1): %d\n', all(J.max_abs_lambda(ok) < 1));
fprintf('Najwieksze |lambda|: %.4f\n', max(J.max_abs_lambda(ok)));
for st = strategies
    tau = J.tau_dominant_s(ok & J.strategy == st{1});
    fprintf('%s: dominujaca stala czasowa %.0f - %.0f s\n', st{1}, min(tau), max(tau));
end
