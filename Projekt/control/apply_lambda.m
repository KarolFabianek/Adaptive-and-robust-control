function cfg = apply_lambda(P, cfg, lambda)
%APPLY_LAMBDA  Mapowanie poziomu ochrony lambda (0..1) na parametry ładowania.
%
%   Jeden skalarny „pokrętło” sterowane przez nadrzędną pętlę SOH zmienia
%   jednocześnie cztery parametry, które najsilniej wpływają na starzenie:
%     soc_ac     – docelowy SOC ładowania codziennego (AC):   0.85 -> 0.65
%     I_cap      – maks. prąd szybkiego ładowania DC:          300 A -> 165 A
%                  (bez zmian do lambda = 0.3, aby nie wydłużać tras)
%     T_park_max – próg chłodzenia na postoju z wtyczką:      32 -> 22°C
%     Tref_drive – temperatura zadana chłodzenia w jeździe:    32 -> 22°C
lambda = min(max(lambda, 0), 1);
cfg.lambda     = lambda;
cfg.soc_ac     = 0.85 - 0.20*lambda;
cfg.I_cap      = P.I_dc_max - 135*max(0, lambda - 0.3)/0.7;
cfg.T_park_max = 32 - 10*lambda;
cfg.Tref_drive = 32 - 10*lambda;
end
