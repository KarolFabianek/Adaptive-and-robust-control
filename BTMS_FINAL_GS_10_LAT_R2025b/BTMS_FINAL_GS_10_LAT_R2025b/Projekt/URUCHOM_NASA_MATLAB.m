% Oryginalny plik NASA B0005.mat jest dolaczony do tej paczki.
root=fileparts(mfilename('fullpath'));
cd(root);addpath(root);addpath(fullfile(root,'matlab'));
fn=fullfile(root,'nasa_data','B0005.mat');
if ~isfile(fn),error('NASA: nie znaleziono oryginalnego B0005.mat w nasa_data.');end
N=btms_nasa_validate(fn);
disp(N);
