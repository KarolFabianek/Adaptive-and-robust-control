function cfg = strategy_config(P, name, lambda)
%STRATEGY_CONFIG  Konfiguracja strategii ładowania i zarządzania termicznego.
%
%   cfg = strategy_config(P, name)          – lambda = P.lambda0
%   cfg = strategy_config(P, name, lambda)
%
%   Strategie sesyjne (z wykładu, porównanie regulatorów chłodzenia):
%     'CC'       stałe chłodzenie u = 0.2, profil prądu bez nadzoru
%     'PI'       regulator PI o stałych nastawach
%     'GS'       PI z gain schedulingiem po rho = Ts - Tchill
%     'GS_SAFE'  GS + feedforward + nadzór termiczny prądu
%   Strategie całego życia baterii (cel projektu: SOH >= 80% po 10 latach):
%     'STD_100'    typowy BMS: tablice statyczne, ładowanie AC do 100% od razu
%     'STD_90'     jak wyżej, limit 90%
%     'LIFE'       proponowana: GS+FF, limit prądu z potencjału anody,
%                  podgrzewanie przed DC, ładowanie AC „na czas wyjazdu”,
%                  ochrona termiczna na postoju – stały poziom ochrony lambda
%     'LIFE_ADAPT' LIFE + nadrzędna pętla SOH (RLS + PI) adaptująca lambda
%
%   lambda (0..1) – poziom ochrony baterii: 0 = maks. komfort, 1 = maks. ochrona.

if nargin < 3, lambda = P.lambda0; end

cfg = struct('name', name, 'cool_mode', 2, 'cc_u', 0, 'ff', 0, 'derate', 0, ...
    'std_table', 0, 'taper', 1, 'plating', 0, 'precond', 0, ...
    'I_cap', P.I_dc_max, 'Vmax', P.V_max_cell, 'soc_ac', 0.9, 'jit', 0, ...
    'park_guard', 0, 'T_park_max', 99, 'Tref_drive', 99, 'adaptive', 0, ...
    'lambda', NaN);

switch name
    case 'CC'
        cfg.cool_mode = 1; cfg.cc_u = 0.20;
    case 'PI'
        cfg.cool_mode = 2;
    case 'GS'
        cfg.cool_mode = 3;
    case 'GS_SAFE'
        cfg.cool_mode = 3; cfg.ff = 1; cfg.derate = 1;
    case {'STD_100', 'STD_90'}
        cfg.cool_mode = 2; cfg.derate = 1; cfg.std_table = 1;
        cfg.Tref_drive = 35;
        if strcmp(name, 'STD_100'), cfg.soc_ac = 1.0; else, cfg.soc_ac = 0.9; end
    case {'LIFE', 'LIFE_ADAPT'}
        cfg.cool_mode = 3; cfg.ff = 1; cfg.derate = 1; cfg.taper = 0;
        cfg.plating = 1; cfg.precond = 1; cfg.jit = 1; cfg.park_guard = 1;
        cfg.adaptive = double(strcmp(name, 'LIFE_ADAPT'));
        cfg = apply_lambda(P, cfg, lambda);
    otherwise
        error('strategy_config:unknown', 'Nieznana strategia: %s', name);
end
end
