function modelName = btms_make_simulink(Ta)
% Create an R2025b Simulink diagram with a supported Level-2 MATLAB
% S-Function, NOT the obsolete/misspelled 'Interpreted MATLAB Fcn'.
% The block internally calls the same btms_step.m used by MATLAB runner.
% Ta - temperatura otoczenia [C] (domyslnie 35). Ta sama wartosc trafia do
% bloku Constant i jako warunek poczatkowy do S-funkcji (parametr bloku).
if nargin<1 || isempty(Ta), Ta = 35; end
root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root,'matlab'),'-begin');
if isempty(which('new_system')) || license('test','Simulink') == 0
    error('Simulink not installed or not licensed. MATLAB analysis remains usable.');
end
load_system('simulink');
modelName = 'BTMS_GS_LIFE_R2025b_FINAL';
modelDir = fullfile(root,'simulink');
if ~isfolder(modelDir), mkdir(modelDir); end
modelFile = fullfile(modelDir,[modelName '.slx']);
% A distinct name prevents older cached demonstrations from being reused.
if bdIsLoaded(modelName), close_system(modelName,0); end
new_system(modelName);
try
    TaStr = num2str(Ta,'%.10g');
    add_block('simulink/Sources/Constant',[modelName '/Tamb'], ...
        'Position',[85 175 170 205], 'Value',TaStr, 'SampleTime','5');
    src = 'simulink/User-Defined Functions/Level-2 MATLAB S-Function';
    add_block(src,[modelName '/BTMS_GS_LIFE'], ...
        'Position',[260 148 465 227], 'FunctionName','btms_sfcn_life80', ...
        'Parameters',TaStr);
    add_block('simulink/Signal Routing/Demux',[modelName '/Rozdziel_stany'], ...
        'Position',[570 150 575 300], 'Outputs','4');
    add_block('simulink/Sinks/Scope',[modelName '/Temperatury_Tc_Ts'], ...
        'Position',[680 140 755 185], 'NumInputPorts','2');
    add_block('simulink/Sinks/Scope',[modelName '/SOC'], ...
        'Position',[680 230 755 275]);
    add_block('simulink/Sinks/Terminator',[modelName '/Integrator_z'], ...
        'Position',[680 290 700 310]);
    add_block('simulink/Sinks/To Workspace',[modelName '/Zapis_stanow'], ...
        'Position',[555 70 745 110], ...
        'VariableName','BTMS_states','SaveFormat','Structure With Time');
    add_line(modelName,'Tamb/1','BTMS_GS_LIFE/1','autorouting','on');
    add_line(modelName,'BTMS_GS_LIFE/1','Rozdziel_stany/1','autorouting','on');
    add_line(modelName,'BTMS_GS_LIFE/1','Zapis_stanow/1','autorouting','on');
    add_line(modelName,'Rozdziel_stany/1','Temperatury_Tc_Ts/1','autorouting','on');
    add_line(modelName,'Rozdziel_stany/2','Temperatury_Tc_Ts/2','autorouting','on');
    add_line(modelName,'Rozdziel_stany/3','SOC/1','autorouting','on');
    add_line(modelName,'Rozdziel_stany/4','Integrator_z/1','autorouting','on');
    set_param(modelName,'SolverType','Fixed-step', ...
        'Solver','FixedStepDiscrete','FixedStep','5', ...
        'StopTime','1800','SaveTime','on');
    set_param(modelName,'SimulationCommand','update');
    save_system(modelName,modelFile);
    fprintf('SIMULINK: new Level-2 model written: %s\n',modelFile);
catch ME
    if bdIsLoaded(modelName), close_system(modelName,0); end
    rethrow(ME);
end
end
