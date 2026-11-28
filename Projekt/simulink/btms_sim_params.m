function btms_sim_params(Ta)
%BTMS_SIM_PARAMS  Zmienne modelu btms_life_simulink w przestrzeni roboczej.
%
%   btms_sim_params(Ta) tworzy w przestrzeni roboczej zmienne P, cfg i simp
%   dla sesji szybkiego ładowania od 20 do 80% SOC ze strategią LIFE przy
%   temperaturze otoczenia Ta [°C] (domyślnie 0°C). Model wywołuje tę funkcję
%   sam przy uruchomieniu, jeśli zmiennych jeszcze nie ma.
if nargin < 1, Ta = 0; end
root = fileparts(fileparts(mfilename('fullpath')));
addpath(root);
bms_setup;
P = bms_params();
c = strategy_config(P, 'LIFE');
cfg = rmfield(c, 'name');
simp = struct('dt', 1, 'Ta', Ta, 'T0', Ta, 'SOH0', 1, 'soc_target', 0.80, ...
    'x0', [Ta; Ta; 0.20; 0], 't_stop', 7200, 'T_heat', -1e9);
if c.precond, simp.T_heat = P.T_precond; end
simp.gs_rho_bp = -10:0.02:60;
simp.gs_k_tab = arrayfun(@(r) min(P.gs_max, max(P.gs_min, P.rho0/max(r, P.rho0/P.gs_max))), simp.gs_rho_bp);
assignin('base', 'P', P);
assignin('base', 'cfg', cfg);
assignin('base', 'simp', simp);
fprintf('   zmienne modelu przygotowane: Ta = %g°C, strategia LIFE\n', Ta);
end
