function T=btms_goal80()
% Life-oriented feasibility study for 35 C ambient fast charging.
% The 80%-at-10y requirement is NOT met by baseline GS_LIFE at 35 C.
% We separately model storage temperature and storage SOC as explicit
% engineering CONDITIONS. An active storage-cooling plant is NOT included.
root=fileparts(fileparts(mfilename('fullpath')));
out=fullfile(root,'results'); figDir=fullfile(root,'figures');
if ~isfolder(out),mkdir(out);end
if ~isfolder(figDir),mkdir(figDir);end
c=btms_cfg(); [session,tr]=btms_run_session(c,'GS_LIFE',35);
if session.status ~= "DONE",error('Charging did not reach the goal SOC.');end
meanTc=mean(tr(:,2)); Ipeak=max(tr(:,5));
parkTemps=[35 30 27 25 23 20]; parkSOCs=[.5 .4];
T=table(); baseLife=[]; conditionalLife=[];
for temp=parkTemps
    for parkSoc=parkSOCs
        [l,s]=btms_life_goal(c,meanTc,Ipeak,35,temp,parkSoc,c.days_per_year);
        s.Tc_charge_max_C=session.Tmax_C;
        s.charge_time_min=session.time_min;
        s.temp_below_40=session.Tmax_C<40;
        T=[T;s]; %#ok<AGROW>
        if temp==35 && abs(parkSoc-.5)<1e-9,baseLife=l;end
        if temp==23 && abs(parkSoc-.4)<1e-9,conditionalLife=l;end
    end
end
writetable(T,fullfile(out,'goal80_feasibility_matlab.csv'));
assert(~isempty(baseLife) && ~isempty(conditionalLife));
assert(baseLife.SOH_pct(end)<80,'Expected ambient 35 C baseline to fail the 80% criterion.');
assert(conditionalLife.SOH_pct(end)>=80,'Conditional design did not meet 80%.');
assert(session.Tmax_C<40,'Charging pack exceeded the 40 C project temperature limit.');
figure('Color','w','Name','BTMS lifetime requirement 80%');
plot(baseLife.years,baseLife.SOH_pct,'LineWidth',2.1);hold on;
plot(conditionalLife.years,conditionalLife.SOH_pct,'LineWidth',2.4);
yline(80,'--','80% wymaganie','LineWidth',1.1);
grid on; xlabel('Lata eksploatacji'); ylabel('SOH (pojemnosciowy) [%]');
title('10 lat: modelowa wykonalnosc celu 80% SOH');
legend('Parkowanie 35 C / 50% SOC', ...
       'Warunkowo: parkowanie 23 C / 40% SOC','Granica 80%', ...
       'Location','southwest');
ax=gca;try, ax.Toolbar.Visible='off';catch,end
exportgraphics(gcf,fullfile(figDir,'matlab_goal80_storage.png'),'Resolution',170);
sel=T(T.storage_temperature_C==23 & T.storage_SOC==.4,:);
fprintf('\nCEL 80%% po 10 latach | ladowanie przy Ta=35 C\n');
fprintf('GS_LIFE ladowanie: Tmax=%.2f C; czas=%.2f min\n',session.Tmax_C,session.time_min);
fprintf('Bez kontroli parkowania: %.2f%% SOH -> NIE SPELNIA\n',baseLife.SOH_pct(end));
fprintf('Warunkowo przy 23 C / 40%% SOC w parkowaniu: %.2f%% SOH -> %s\n', ...
   conditionalLife.SOH_pct(end), char(string(sel.meets_80)));
fprintf('UWAGA: temperatura parkowania wymaga osobnego BTMS i zuzywa energie; nie jest tu zasymulowana.\n');
fprintf('Wynik nie jest gwarancja OEM ani walidacja 10 lat danymi NASA.\n');
end
