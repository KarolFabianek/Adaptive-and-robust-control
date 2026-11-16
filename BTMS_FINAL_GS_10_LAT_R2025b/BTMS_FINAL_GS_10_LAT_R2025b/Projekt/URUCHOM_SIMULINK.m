% Project Simulink (R2025b): supported Level-2 MATLAB S-Function.
root=fileparts(mfilename('fullpath'));cd(root);
addpath(root,'-begin');addpath(fullfile(root,'matlab'),'-begin');
if isempty(which('new_system')) || ~license('test','Simulink')
    error('Simulink not available; the core MATLAB project is independent.');
end
modelName=btms_make_simulink();
fprintf('Running Simulink model: %s\n',modelName);
try
    out=sim(modelName,'ReturnWorkspaceOutputs','on');
    report=btms_verify_simulink(out);
    open_system(modelName);
    if ~all(report.pass),error('Simulink verification failed');end
catch ME
    fprintf(2,'Simulink diagnosis: %s\n',ME.message);
    rethrow(ME)
end
