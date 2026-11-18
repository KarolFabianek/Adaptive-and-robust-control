function T=btms_goal80()
% Warunki spelnienia celu SOH >= 80% po 10 latach (scenariusz modelowy).
% Szybkie ladowanie GS_LIFE odbywa sie przy Ta = 35 C. SREDNIA ROCZNA temperatura
% postoju i SOC postoju to osobne, jawne warunki (35 C srednio rocznie to rekord
% swiata - Dallol ok. 34,6 C; typowe goraca klimaty to 25-30 C).
% Funkcja niczego nie zaklada z gory o wyniku - wypisuje progi spelnienia celu.
root=fileparts(fileparts(mfilename('fullpath')));
out=fullfile(root,'results'); figDir=fullfile(root,'figures');
if ~isfolder(out),mkdir(out);end
if ~isfolder(figDir),mkdir(figDir);end
c=btms_cfg(); [session,tr]=btms_run_session(c,'GS_LIFE',35);
if session.status ~= "DONE",error('Charging did not reach the goal SOC.');end
meanTc=mean(tr(:,2)); Ipeak=max(tr(:,5));
parkTemps=[35 30 27 25 23 20]; parkSOCs=[.78 .5 .4];
T=table(); baseLife=[]; hotLife=[];
for temp=parkTemps
    for parkSoc=parkSOCs
        [l,s]=btms_life_goal(c,meanTc,Ipeak,35,temp,parkSoc,c.days_per_year);
        s.Tc_charge_max_C=session.Tmax_C;
        s.charge_time_min=session.time_min;
        s.temp_below_40=session.Tmax_C<40;
        T=[T;s]; %#ok<AGROW>
        if temp==35 && abs(parkSoc-.5)<1e-9,baseLife=l;end
        if temp==25 && abs(parkSoc-.5)<1e-9,hotLife=l;end
    end
end
writetable(T,fullfile(out,'goal80_feasibility_matlab.csv'));
assert(~isempty(baseLife) && ~isempty(hotLife));
% Niezmienniki (bez narzuconego werdyktu): chlodniejszy postoj starzeje mniej,
% a ladowanie miesci sie w limicie 40 C.
assert(hotLife.SOH_pct(end) > baseLife.SOH_pct(end));
assert(session.Tmax_C<40,'Charging pack exceeded the 40 C project temperature limit.');
figure('Color','w','Name','BTMS lifetime requirement 80%');
plot(baseLife.years,baseLife.SOH_pct,'LineWidth',2.1);hold on;
plot(hotLife.years,hotLife.SOH_pct,'LineWidth',2.4);
yline(80,'--','80% wymaganie','LineWidth',1.1);
grid on; xlabel('Lata eksploatacji'); ylabel('SOH (pojemnosciowy) [%]');
title('10 lat: modelowa wykonalnosc celu 80% SOH');
legend('Postoj srednio 35 C / 50% SOC (rekordowy klimat)', ...
       'Postoj srednio 25 C / 50% SOC (goracy klimat)','Granica 80%', ...
       'Location','southwest');
ax=gca;try, ax.Toolbar.Visible='off';catch,end
exportgraphics(gcf,fullfile(figDir,'matlab_goal80_storage.png'),'Resolution',170);
verdict={'NIE SPELNIA','SPELNIA'};
fprintf('\nCEL 80%% po 10 latach | szybkie ladowanie GS_LIFE przy Ta=35 C\n');
fprintf('GS_LIFE ladowanie: Tmax=%.2f C; czas=%.2f min\n',session.Tmax_C,session.time_min);
fprintf('Postoj srednio 35 C / 50%% SOC: %.2f%% SOH -> %s\n',baseLife.SOH_pct(end), ...
    verdict{1+double(baseLife.SOH_pct(end)>=80)});
fprintf('Postoj srednio 25 C / 50%% SOC: %.2f%% SOH -> %s\n',hotLife.SOH_pct(end), ...
    verdict{1+double(hotLife.SOH_pct(end)>=80)});
for parkSoc=parkSOCs
    ok=T.storage_temperature_C(T.meets_80 & abs(T.storage_SOC-parkSoc)<1e-9);
    if isempty(ok)
        fprintf('SOC postoju %2.0f%%: cel 80%% niespelniony w calym zakresie 20-35 C\n',100*parkSoc);
    else
        fprintf('SOC postoju %2.0f%%: cel 80%% spelniony dla sredniej temperatury postoju <= %g C\n',100*parkSoc,max(ok));
    end
end
fprintf('UWAGA: 35 C jako SREDNIA ROCZNA temperatura postoju to ekstremum klimatyczne\n');
fprintf('       (rekord swiata: Dallol, ok. 34.6 C).\n');
fprintf('Wynik nie jest gwarancja OEM ani walidacja 10 lat danymi NASA.\n');
end
