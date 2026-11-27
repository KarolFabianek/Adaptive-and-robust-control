function Tc_hat_next = core_observer(Pc, Tc_hat, Ts_meas, Qgen_hat, dt)
%CORE_OBSERVER  Obserwator zredukowanego rzędu temperatury rdzenia.
%
%   Temperatury rdzenia nie da się zmierzyć, bo czujniki są na powierzchni.
%   Obserwator korzysta ze zmierzonej temperatury Ts i estymowanych strat:
%       Cc dTc_hat/dt = Qgen_hat - Gcs (Tc_hat - Ts)
%   Błąd estymacji zanika ze stałą czasową Cc/Gcs, około 95 s, niezależnie
%   od sterowania. Pc to parametry modelu znane regulatorowi.
Tc_hat_next = (Pc.Cc/dt*Tc_hat + Qgen_hat + Pc.Gcs*Ts_meas)/(Pc.Cc/dt + Pc.Gcs);
end
