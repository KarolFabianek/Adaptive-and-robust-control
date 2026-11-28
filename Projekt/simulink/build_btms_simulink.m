function model = build_btms_simulink(model)
%BUILD_BTMS_SIMULINK  Programowa budowa modelu Simulink sesji szybkiego ładowania.
%
%   build_btms_simulink() zapisuje model simulink/btms_life_simulink.slx.
%
%   Struktura modelu (krok stały dt, solver FixedStepDiscrete):
%     Regulator ładowania   CC-CV z limitem potencjału anody (strategia LIFE)
%     Harmonogram GS        tablica 1-D k(rho), rho = Ts - Tchill, wyznacza Kp i Ki
%     Regulator PI          chłodzenie z anti-windupem, sprzężenie w przód, grzanie
%     Pakiet 96s50p         model elektryczny 1RC i dwuwęzłowy model cieplny
%     Obserwator Tc         estymacja niemierzalnej temperatury rdzenia
%     Starzenie             sumowanie stresu starzenia
%     Unit Delay            stany x = [Tc Ts SOC V1], z, Tc_hat, S
%   Bloki MATLAB Function wywołują te same funkcje co skrypty MATLAB
%   (pack_step, charge_controller i inne), więc wyniki można porównać
%   krok po kroku w run_simulink_validation.m.

if nargin < 1, model = 'btms_life_simulink'; end
here = fileparts(mfilename('fullpath'));
load_system('simulink');               % uruchomienie Simulinka, potrzebne w trybie -batch
if bdIsLoaded(model), close_system(model, 0); end
f = fullfile(here, [model '.slx']);
if exist(f, 'file'), delete(f); end
new_system(model);
set_param(model, 'Solver', 'FixedStepDiscrete', 'FixedStep', 'simp.dt', ...
    'StopTime', 'simp.t_stop', 'SaveOutput', 'off', 'SaveTime', 'off', ...
    'SignalLogging', 'off', 'ReturnWorkspaceOutputs', 'on');
% Przy uruchomieniu przyciskiem Run model sam tworzy brakujące zmienne
set_param(model, 'InitFcn', sprintf(['if ~(exist(''P'', ''var'') && exist(''cfg'', ''var'') && exist(''simp'', ''var''))\n' ...
    '    addpath(fileparts(get_param(bdroot, ''FileName'')));\n    btms_sim_params(0);\nend']));

%% Bloki źródłowe
add_block('simulink/Sources/Constant', [model '/Ta'], 'Value', 'simp.Ta', 'Position', [30 330 90 360]);
add_block('simulink/Sources/Constant', [model '/SOH'], 'Value', 'simp.SOH0', 'Position', [30 400 90 430]);

%% Stany (Unit Delay)
ud(model, 'x[k]',      'simp.x0',    [160 60 200 100]);
ud(model, 'z[k]',      '0',          [560 470 600 510]);
ud(model, 'Tc_hat[k]', 'simp.T0',    [160 180 200 220]);
ud(model, 'S[k]',      '[0; 0; 0]',    [1200 520 1240 560]);

%% MATLAB Function: regulator ładowania
mlfb(model, 'Regulator ładowania CC-CV', ...
    {'function I_pack = fcn(x, Tc_hat, SOH_hat, P, cfg, simp)'
     '% Warstwowy limit prądu: CC-CV, nadzór termiczny, potencjał anody'
     'I_pack = charge_controller(P, cfg, true, x(3), simp.soc_target, Tc_hat, x(4), SOH_hat, simp.dt);'}, ...
    {'P', 'cfg', 'simp'}, [300 40 470 120]);

mlfb(model, 'Estymata strat cieplnych', ...
    {'function Qgen_hat = fcn(I_pack, x, Tc_hat, SOH_hat, P)'
     '[R0, R1] = cell_resistance(P, Tc_hat, x(3), SOH_hat);'
     'Qgen_hat = P.ns*P.np*(I_pack/P.np)^2*(R0 + R1);'}, ...
    {'P'}, [560 150 700 230]);

%% Harmonogram GS (bloki standardowe)
add_block('simulink/Signal Routing/Selector', [model '/Ts'], 'IndexMode', 'One-based', ...
    'Indices', '2', 'InputPortWidth', '4', 'Position', [300 300 340 330]);
add_block('simulink/Math Operations/Bias', [model '/rho = Ts - Tchill'], 'Bias', '-P.T_chill', ...
    'Position', [380 300 450 330]);
add_block('simulink/Lookup Tables/1-D Lookup Table', [model '/Harmonogram GS k(rho)'], ...
    'BreakpointsForDimension1', 'simp.gs_rho_bp', 'Table', 'simp.gs_k_tab', ...
    'ExtrapMethod', 'Clip', 'Position', [490 290 570 340]);
add_block('simulink/Math Operations/Gain', [model '/Kp0'], 'Gain', 'P.Kp', 'Position', [610 280 660 310]);
add_block('simulink/Math Operations/Gain', [model '/Ki0'], 'Gain', 'P.Ki', 'Position', [610 330 660 360]);

mlfb(model, 'Regulator chłodzenia PI', ...
    {'function [u, z_next] = fcn(Kp, Ki, z, Tc_hat, Qgen_hat, P, cfg, simp)'
     '% Działanie odwrotne, anti-windup przez całkowanie warunkowe'
     'if Tc_hat < simp.T_heat'
     '    u = -min(1, P.Kh*(simp.T_heat - Tc_hat)); z_next = 0; return'
     'end'
     'e = Tc_hat - P.Tref_charge;'
     'FF = cfg.ff*P.ff_gain*Qgen_hat/P.Qcool_max;'
     'u_raw = Kp*e + z + FF;'
     'u = min(1, max(0, u_raw));'
     'if (u_raw >= 1 && e > 0) || (u_raw <= 0 && e < 0)'
     '    z_next = z;'
     'else'
     '    z_next = z + Ki*simp.dt*e;'
     'end'}, ...
    {'P', 'cfg', 'simp'}, [740 290 920 400]);

%% Pakiet, obserwator, starzenie
mlfb(model, 'Pakiet 96s50p', ...
    {'function [x_next, y] = fcn(x, I_pack, u, Ta, SOH, P, simp)'
     '[x_next, y] = pack_step(P, x, I_pack, u, Ta, simp.dt, SOH);'}, ...
    {'P', 'simp'}, [980 40 1160 160]);
mlfb(model, 'Obserwator Tc', ...
    {'function Tc_hat_next = fcn(Tc_hat, x_next, Qgen_hat, P, simp)'
     'Tc_hat_next = core_observer(P, Tc_hat, x_next(2), Qgen_hat, simp.dt);'}, ...
    {'P', 'simp'}, [1000 200 1140 270]);
mlfb(model, 'Starzenie', ...
    {'function S_next = fcn(S, x, x_next, y, P, simp)'
     's = aging_stress(P, 0.5*(x(1) + x_next(1)), x(3), y(6), y(7), simp.dt);'
     'S_next = S(:) + s(:);'}, ...
    {'P', 'simp'}, [1000 380 1140 460]);

%% Zatrzymanie po osiągnięciu SOC docelowego
add_block('simulink/Signal Routing/Selector', [model '/SOC'], 'IndexMode', 'One-based', ...
    'Indices', '3', 'InputPortWidth', '4', 'Position', [1240 560 1280 590]);
add_block('simulink/Logic and Bit Operations/Compare To Constant', [model '/SOC >= cel'], ...
    'relop', '>=', 'const', 'simp.soc_target - 1e-4', 'Position', [1310 560 1380 590]);
add_block('simulink/Sinks/Stop Simulation', [model '/Stop'], 'Position', [1410 560 1440 590]);

%% Zapis i podgląd
tw(model, 'log_x', [1300 40 1360 70]);
tw(model, 'log_y', [1300 100 1360 130]);
tw(model, 'log_I', [560 60 620 90]);
tw(model, 'log_u', [1000 520 1060 550]);
tw(model, 'log_S', [1300 400 1360 430]);
add_block('simulink/Sinks/Scope', [model '/Temperatury i SOC'], 'NumInputPorts', '1', 'Position', [1300 160 1340 200]);

%% Połączenia
L = @(a, b) add_line(model, a, b, 'autorouting', 'smart');
L('x[k]/1', 'Regulator ładowania CC-CV/1');
L('Tc_hat[k]/1', 'Regulator ładowania CC-CV/2');
L('SOH/1', 'Regulator ładowania CC-CV/3');
L('Regulator ładowania CC-CV/1', 'Estymata strat cieplnych/1');
L('x[k]/1', 'Estymata strat cieplnych/2');
L('Tc_hat[k]/1', 'Estymata strat cieplnych/3');
L('SOH/1', 'Estymata strat cieplnych/4');
L('x[k]/1', 'Ts/1');
L('Ts/1', 'rho = Ts - Tchill/1');
L('rho = Ts - Tchill/1', 'Harmonogram GS k(rho)/1');
L('Harmonogram GS k(rho)/1', 'Kp0/1');
L('Harmonogram GS k(rho)/1', 'Ki0/1');
L('Kp0/1', 'Regulator chłodzenia PI/1');
L('Ki0/1', 'Regulator chłodzenia PI/2');
L('z[k]/1', 'Regulator chłodzenia PI/3');
L('Tc_hat[k]/1', 'Regulator chłodzenia PI/4');
L('Estymata strat cieplnych/1', 'Regulator chłodzenia PI/5');
L('Regulator chłodzenia PI/2', 'z[k]/1');
L('x[k]/1', 'Pakiet 96s50p/1');
L('Regulator ładowania CC-CV/1', 'Pakiet 96s50p/2');
L('Regulator chłodzenia PI/1', 'Pakiet 96s50p/3');
L('Ta/1', 'Pakiet 96s50p/4');
L('SOH/1', 'Pakiet 96s50p/5');
L('Pakiet 96s50p/1', 'x[k]/1');
L('Tc_hat[k]/1', 'Obserwator Tc/1');
L('Pakiet 96s50p/1', 'Obserwator Tc/2');
L('Estymata strat cieplnych/1', 'Obserwator Tc/3');
L('Obserwator Tc/1', 'Tc_hat[k]/1');
L('S[k]/1', 'Starzenie/1');
L('x[k]/1', 'Starzenie/2');
L('Pakiet 96s50p/1', 'Starzenie/3');
L('Pakiet 96s50p/2', 'Starzenie/4');
L('Starzenie/1', 'S[k]/1');
L('Pakiet 96s50p/1', 'SOC/1');
L('SOC/1', 'SOC >= cel/1');
L('SOC >= cel/1', 'Stop/1');
L('Pakiet 96s50p/1', 'log_x/1');
L('Pakiet 96s50p/2', 'log_y/1');
L('Pakiet 96s50p/1', 'Temperatury i SOC/1');
L('Regulator ładowania CC-CV/1', 'log_I/1');
L('Regulator chłodzenia PI/1', 'log_u/1');
L('Starzenie/1', 'log_S/1');

try
    txt = ['Szybkie ładowanie ze strategią LIFE' newline ...
           'Regulator chłodzenia GS-PI, limit prądu z potencjału anody, obserwator temperatury rdzenia' newline ...
           'Karol Fabianek, Paweł Fortuna. Sterowanie adaptacyjne i odporne, Politechnika Opolska'];
    a = Simulink.Annotation(model, txt);
    a.Position = [30 520 520 590];
catch
    % Adnotacja jest tylko opisem i nie wpływa na symulację
end
save_system(model, f);
close_system(model, 0);
fprintf('   model Simulink zapisany: %s\n', f);
end

function ud(model, name, ic, pos)
add_block('simulink/Discrete/Unit Delay', [model '/' name], 'InitialCondition', ic, ...
    'SampleTime', 'simp.dt', 'Position', pos);
end

function tw(model, name, pos)
add_block('simulink/Sinks/To Workspace', [model '/' name], 'VariableName', name, ...
    'SaveFormat', 'Array', 'Position', pos);
end

function mlfb(model, name, code, params, pos)
blk = [model '/' name];
add_block('simulink/User-Defined Functions/MATLAB Function', blk, 'Position', pos);
rt = sfroot;
ch = rt.find('-isa', 'Stateflow.EMChart', 'Path', blk);
ch.Script = strjoin(code, newline);
for k = 1:numel(params)
    d = ch.find('-isa', 'Stateflow.Data', 'Name', params{k});
    d.Scope = 'Parameter';
end
end
