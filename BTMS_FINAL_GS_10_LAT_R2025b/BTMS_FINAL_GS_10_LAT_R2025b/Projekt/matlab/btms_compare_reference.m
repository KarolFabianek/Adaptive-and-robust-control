function T = btms_compare_reference()
% Kontrola zgodnosci implementacji MATLAB z referencja Python.
% NIE jest to walidacja pomiarowa; obie implementacje uzywaja tego samego modelu.
root=fileparts(fileparts(mfilename('fullpath')));
refFile=fullfile(root,'results','sessions_summary.csv');
matFile=fullfile(root,'results','sessions_summary_matlab.csv');
if ~isfile(refFile), error('Brak danych referencyjnych results/sessions_summary.csv'); end
if ~isfile(matFile), error('Najpierw uruchom BTMS_MENU(''obliczenia''). Brak sesji MATLAB.'); end
R=readtable(refFile); M=readtable(matFile);
if height(R)~=24 || height(M)~=24
    error('Oczekiwano 24 wierszy w obu zestawach danych.');
end
rows=cell(24,6);j=0;
for i=1:height(M)
    ix=strcmp(string(R.strategy),string(M.strategy(i))) & abs(R.ambient_C-M.ambient_C(i))<1e-9;
    if sum(ix)~=1, error('Brak jednoznacznego przypadku: %s / %g C',string(M.strategy(i)),M.ambient_C(i)); end
    j=j+1;
    rows(j,:)={string(M.strategy(i)),M.ambient_C(i),...
        abs(M.time_min(i)-R.time_min(ix)),...
        abs(M.Tmax_C(i)-R.Tmax_C(ix)),...
        abs(M.energy_aux_kWh(i)-R.energy_aux_kWh(ix)),...
        abs(M.SOC_end(i)-R.SOC_end(ix))};
end
T=cell2table(rows,'VariableNames',{'strategy','ambient_C','dt_min','dTmax_C','dEaux_kWh','dSOC'});
fprintf('ZGODNOSC Z REFERENCJA PYTHON: max |dt|=%.8g min; |dTc|=%.8g K; |dE|=%.8g kWh; |dSOC|=%.8g\n',...
    max(T.dt_min),max(T.dTmax_C),max(T.dEaux_kWh),max(T.dSOC));
% Tolerancja obejmuje roznice zaokraglen implementacji, a nie blad pomiarowy.
assert(max(T.dt_min)<0.1 && max(T.dTmax_C)<0.05 && max(T.dEaux_kWh)<0.003 && max(T.dSOC)<1e-7,...
    'Roznica MATLAB / Python jest wieksza niz spodziewana. Sprawdz cfg i algorytm.');
writetable(T,fullfile(root,'results','matlab_python_comparison.csv'));
fprintf('OK: zapisano results/matlab_python_comparison.csv\n');
end
