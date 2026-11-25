function save_csv(T, name)
%SAVE_CSV  Zapis tabeli do results/<name>.csv.
root = fileparts(fileparts(mfilename('fullpath')));
writetable(T, fullfile(root, 'results', [name '.csv']));
fprintf('   wyniki: results/%s.csv\n', name);
end
