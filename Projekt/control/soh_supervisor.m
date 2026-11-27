function [sup, lambda] = soh_supervisor(P, sup, SOH_meas, t_years)
%SOH_SUPERVISOR  Nadrzędna pętla sterowania trwałością baterii (raz w miesiącu).
%
%   1. Estymator RLS z zapominaniem dopasowuje lokalny model
%      SOH(t) = th1 + th2 t do zaszumionych pomiarów pojemności. Daje
%      bieżący poziom SOH_hat i tempo degradacji dSOH/dt [1/rok].
%   2. Regulator PI porównuje SOH_hat z trajektorią odniesienia SOH_ref(t)
%      i ustawia poziom ochrony lambda z przedziału od 0 do 1:
%          e      = SOH_ref(t) - SOH_hat   (e > 0 oznacza zbyt szybkie starzenie)
%          lambda = lambda0 + Kp e + Ki sum(e), ograniczone do [0, 1]
%      W nasyceniu całkowanie jest wstrzymane (anti-windup).
%
%   Poziom ochrony lambda zmienia parametry ładowania (apply_lambda).
%   Sprzężenie zwrotne od zmierzonego SOH zmniejsza wpływ błędów modelu
%   starzenia na wynik (eksperyment E06).
%
%   Stan sup zawiera pola theta, Pcov, integ, lambda, soh_hat i rate.

if isempty(sup)
    sup.theta = [1; 0];
    sup.Pcov  = diag([1e-2, 1e-2]);
    sup.integ = 0;
    sup.lambda = P.lambda0;
    sup.soh_hat = 1;
    sup.rate = 0;
end

% Estymator RLS z zapominaniem
phi = [1; t_years];
lf  = P.rls_lambda;
K   = sup.Pcov*phi/(lf + phi'*sup.Pcov*phi);
sup.theta = sup.theta + K*(SOH_meas - phi'*sup.theta);
sup.Pcov  = (sup.Pcov - K*phi'*sup.Pcov)/lf;
sup.soh_hat = phi'*sup.theta;
sup.rate    = sup.theta(2);

% Regulator PI
e = soh_reference(P, t_years) - sup.soh_hat;
lam_unsat = P.lambda0 + P.Kp_lam*e + P.Ki_lam*(sup.integ + e);
if (lam_unsat > 1 && e > 0) || (lam_unsat < 0 && e < 0)
    % Nasycenie: całkowanie wstrzymane
else
    sup.integ = sup.integ + e;
end
lambda = min(1, max(0, P.lambda0 + P.Kp_lam*e + P.Ki_lam*sup.integ));
sup.lambda = lambda;
sup.e = e;
end
