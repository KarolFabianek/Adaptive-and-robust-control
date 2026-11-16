function modelName = btms_make_simulink()
% Create an R2025b Simulink diagram with a supported Level-2 MATLAB
% S-Function, NOT the obsolete/misspelled 'Interpreted MATLAB Fcn'.
% The block internally calls the same btms_step.m used by MATLAB runner.
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
    add_block('simulink/Sources/Constant',[modelName '/Tamb_35C'], ...
        'Position',[85 175 170 205], 'Value','35', 'SampleTime','5');
    src = 'simulink/User-Defined Functions/Level-2 MATLAB S-Function';
    add_block(src,[modelName '/BTMS_GS_LIFE'], ...
        'Position',[260 148 465 227], 'FunctionName','btms_sfcn_life80');
    add_block('simulink/Signal Routing/Demux',[modelName '/Rozdziel_stany'], ...
        'Position',[570 150 575 300], 'Outputs','4');
    add_block('simulink/Sinks/Scope',[modelName '/Temperatura_rdzenia'], ...
        'Position',[680 140 755 185]);
    add_block('simulink/Sinks/Scope',[modelName '/SOC'], ...
        'Position',[680 230 755 275]);
    add_block('simulink/Sinks/To Workspace',[modelName '/Zapis_stanow'], ...
        'Position',[555 70 745 110], ...
        'VariableName','BTMS_states','SaveFormat','Structure With Time');
    add_line(modelName,'Tamb_35C/1','BTMS_GS_LIFE/1','autorouting','on');
    add_line(modelName,'BTMS_GS_LIFE/1','Rozdziel_stany/1','autorouting','on');
    add_line(modelName,'BTMS_GS_LIFE/1','Zapis_stanow/1','autorouting','on');
    add_line(modelName,'Rozdziel_stany/1','Temperatura_rdzenia/1','autorouting','on');
    add_line(modelName,'Rozdziel_stany/3','SOC/1','autorouting','on');
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
