function [sup, lambda] = soh_supervisor(P, sup, SOH_meas, t_years)
%SOH_SUPERVISOR  Nadrzędna (wolna) pętla sterowania trwałością baterii.
%
%   Pętla działa raz w miesiącu. Składa się z dwóch elementów:
%
%   1) Estymator RLS z zapominaniem (lambda_f) dopasowuje lokalny model
%      SOH(t) = th1 + th2 t do zaszumionych pomiarów pojemności (np. z
%      liczenia ładunku między spoczynkowymi punktami OCV). Daje poziom
%      SOH_hat i bieżące tempo degradacji dSOH/dt [1/rok].
%
%   2) Regulator PI „budżetu zdrowia”: porównuje SOH_hat z trajektorią
%      odniesienia SOH_ref(t), która kończy się na P.SOH_target_10y po
%      10 latach, i ustawia poziom ochrony lambda (0..1):
%          e      = SOH_ref(t) - SOH_hat      (e > 0: bateria starzeje się za szybko)
%          lambda = sat( lambda0 + Kp e + Ki sum(e) )
%      Anti-windup: całkowanie zatrzymane w nasyceniu lambda.
%
%   Zmienna sterująca lambda przestawia parametry ładowania (apply_lambda).
%   To sprzężenie zwrotne „po zdrowiu” czyni strategię odporną na
%   niepewność współczynników starzenia (patrz eksperyment E06).
%
%   sup – stan: theta (2x1), Pcov (2x2), integ, lambda, soh_hat, rate.

if isempty(sup)
    sup.theta = [1; 0];
    sup.Pcov  = diag([1e-2, 1e-2]);
    sup.integ = 0;
    sup.lambda = P.lambda0;
    sup.soh_hat = 1;
    sup.rate = 0;
end

% --- RLS z zapominaniem ---
phi = [1; t_years];
lf  = P.rls_lambda;
K   = sup.Pcov*phi/(lf + phi'*sup.Pcov*phi);
sup.theta = sup.theta + K*(SOH_meas - phi'*sup.theta);
sup.Pcov  = (sup.Pcov - K*phi'*sup.Pcov)/lf;
sup.soh_hat = phi'*sup.theta;
sup.rate    = sup.theta(2);

% --- PI budżetu zdrowia ---
e = soh_reference(P, t_years) - sup.soh_hat;
lam_unsat = P.lambda0 + P.Kp_lam*e + P.Ki_lam*(sup.integ + e);
if (lam_unsat > 1 && e > 0) || (lam_unsat < 0 && e < 0)
    % nasycenie – nie całkujemy
else
    sup.integ = sup.integ + e;
end
lambda = min(1, max(0, P.lambda0 + P.Kp_lam*e + P.Ki_lam*sup.integ));
sup.lambda = lambda;
sup.e = e;
end
