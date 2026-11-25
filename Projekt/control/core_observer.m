function Tc_hat_next = core_observer(Pc, Tc_hat, Ts_meas, Qgen_hat, dt)
%CORE_OBSERVER  Obserwator zredukowanego rzędu temperatury rdzenia.
%
%   Temperatura rdzenia Tc nie jest mierzalna (czujniki są na powierzchni).
%   Obserwator wykorzystuje zmierzoną Ts i estymowane straty Qgen_hat:
%       Cc dTc_hat/dt = Qgen_hat - Gcs (Tc_hat - Ts_meas)
%   Błąd estymacji e = Tc - Tc_hat ma dynamikę de/dt = -(Gcs/Cc) e + d,
%   czyli zanika ze stałą czasową Cc/Gcs ~ 95 s niezależnie od sterowania.
%   Pc – parametry modelu po stronie regulatora (mogą różnić się od obiektu).
Tc_hat_next = (Pc.Cc/dt*Tc_hat + Qgen_hat + Pc.Gcs*Ts_meas)/(Pc.Cc/dt + Pc.Gcs);
end
