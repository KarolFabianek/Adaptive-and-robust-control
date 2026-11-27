function A = aging_update(P, A, S)
%AGING_UPDATE  Aktualizacja stanu starzenia o skumulowany stres S.
%   S = [suma dt_eq, suma dFEC_eq, suma dQ_pl], na przykład z jednego miesiąca.
A.t_eq   = A.t_eq + S(1);
A.FEC_eq = A.FEC_eq + S(2);
A.Q_cal  = P.k_cal*A.t_eq^P.z_cal;
A.Q_cyc  = P.k_cyc*A.FEC_eq^P.z_cyc;
A.Q_pl   = A.Q_pl + S(3);
A.SOH    = max(0.3, 1 - A.Q_cal - A.Q_cyc - A.Q_pl);
end
