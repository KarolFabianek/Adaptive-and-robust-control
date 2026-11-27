function cfg = apply_lambda(P, cfg, lambda)
%APPLY_LAMBDA  Przelicza poziom ochrony lambda (od 0 do 1) na parametry ładowania.
%
%   Pętla SOH steruje jedną wielkością, która zmienia cztery parametry
%   najsilniej wpływające na starzenie:
%     soc_ac      docelowy SOC ładowania AC: od 85% do 65%
%     I_cap       prąd szybkiego ładowania DC: od 300 A do 165 A,
%                 bez zmian do lambda = 0,3, aby nie wydłużać tras
%     T_park_max  próg chłodzenia auta podłączonego do ładowarki: od 32 do 22°C
%     Tref_drive  temperatura zadana chłodzenia w jeździe: od 32 do 22°C
lambda = min(max(lambda, 0), 1);
cfg.lambda     = lambda;
cfg.soc_ac     = 0.85 - 0.20*lambda;
cfg.I_cap      = P.I_dc_max - 135*max(0, lambda - 0.3)/0.7;
cfg.T_park_max = 32 - 10*lambda;
cfg.Tref_drive = 32 - 10*lambda;
end
