function A = aging_init()
%AGING_INIT  Stan modelu starzenia nowej baterii.
%   A.t_eq   – zastępczy czas kalendarzowy [dni]
%   A.FEC_eq – zastępcze pełne cykle [-]
%   A.Q_cal, A.Q_cyc, A.Q_pl – składowe utraty pojemności [-]
%   A.SOH    – pojemność względna [-]
A.t_eq = 0;
A.FEC_eq = 0;
A.Q_cal = 0;
A.Q_cyc = 0;
A.Q_pl = 0;
A.SOH = 1;
end
