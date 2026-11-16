function T = btms_verify_simulink(simOut)
% Compare samples from independently executed Simulink model against
% the exact MATLAB session (same numerical transition equation).
root=fileparts(fileparts(mfilename('fullpath')));
raw=simOut.get('BTMS_states');
if ~isstruct(raw) || ~isfield(raw,'time') || ~isfield(raw,'signals')
    error('Simulink: To Workspace must use Structure With Time for BTMS_states.');
end
t=double(raw.time(:));
v=double(squeeze(raw.signals.values));
if size(v,2) ~= 4 && size(v,1) == 4, v=v.'; end
if size(v,1) ~= numel(t) || size(v,2) ~= 4
    error('Simulink returned dimensions %s, expected samples x 4.',mat2str(size(v)));
end
c=btms_cfg(); [s,tr]=btms_run_session(c,'GS_LIFE',35);
if s.status ~= "DONE", error('MATLAB reference run did not finish.'); end
wanted = round(tr(:,1)*60*1000);
[tf,loc] = ismember(wanted,round(t*1000));
if ~all(tf), error('Missing %d timestamps in Simulink output.',sum(~tf)); end
D=abs(v(loc,1:3)-tr(:,2:4));
T=table(max(D(:,1)),max(D(:,2)),max(D(:,3)), ...
    'VariableNames',{'max_error_Tc_K','max_error_Ts_K','max_error_SOC'});
T.pass = T.max_error_Tc_K < 1e-4 && T.max_error_Ts_K < 1e-4 && ...
    T.max_error_SOC < 1e-8;
out=fullfile(root,'results');if ~isfolder(out),mkdir(out);end
writetable(T,fullfile(out,'simulink_matlab_check.csv'));
disp(T);
if ~T.pass, error('Simulink != MATLAB: do not present model as verified.'); end
fprintf('PASS: Simulink states match the MATLAB GS_LIFE session.\n');
end
