function root = bms_setup()
%BMS_SETUP  Dodaje foldery projektu do ścieżki MATLAB-a i tworzy foldery wyników.
%   root = bms_setup() zwraca ścieżkę do folderu Projekt.
root = fileparts(mfilename('fullpath'));
addpath(fullfile(root, 'config'), fullfile(root, 'model'), fullfile(root, 'control'), ...
        fullfile(root, 'sim'), fullfile(root, 'utils'), fullfile(root, 'experiments'), ...
        fullfile(root, 'simulink'), fullfile(root, 'tests'));
if ~exist(fullfile(root, 'results'), 'dir'), mkdir(fullfile(root, 'results')); end
if ~exist(fullfile(root, 'figures'), 'dir'), mkdir(fullfile(root, 'figures')); end
end
