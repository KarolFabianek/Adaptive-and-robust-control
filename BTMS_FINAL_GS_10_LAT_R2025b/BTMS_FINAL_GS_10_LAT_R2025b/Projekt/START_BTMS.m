% START_BTMS: select this file via uigetfile from the user chat.
% No administrator, no saving of MATLAB global path, no edits to Windows PATH.
root=fileparts(mfilename('fullpath'));
if ~isfolder(fullfile(root,'matlab'))
    error('Unzip all files first; directory Projekt/matlab is missing.');
end
% Remove older BTMS folders from *this* MATLAB session to prevent old code shadowing.
parts=strsplit(path,pathsep);
for i=1:numel(parts)
    old=parts{i};
    if isempty(old)||strcmpi(old,root)||strcmpi(old,fullfile(root,'matlab'))
        continue;
    end
    if isfile(fullfile(old,'BTMS_MENU.m')) || isfile(fullfile(old,'btms_cfg.m'))
        rmpath(old);
        fprintf('Usunieto z sesji stara sciezke BTMS: %s\n',old);
    end
end
cd(root);
addpath(root,'-begin');addpath(fullfile(root,'matlab'),'-begin');
clear BTMS_MENU btms_make_simulink btms_sfcn_life80 btms_goal80;
rehash;
fprintf('\nBTMS FINAL R2025b | uruchomione z: %s\n',root);
fprintf('Biezace BTMS_MENU.m: %s\n',which('BTMS_MENU'));
fprintf('Nowy model Simulink: Level-2 MATLAB S-Function.\n');
fprintf('Najpierw 8: calosc, 22: cel80, 18: simulink, 19: nasa.\n');
BTMS_MENU();
