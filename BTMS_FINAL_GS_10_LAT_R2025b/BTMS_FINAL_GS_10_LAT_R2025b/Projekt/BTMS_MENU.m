function BTMS_MENU(cmd)
% BTMS_MENU() -- menu interaktywne
% BTMS_MENU('calosc') -- testy, 24 symulacje, 162 testy niepewnosci,
%                        porownanie Python, wykresy. Bez Simulink i NASA.
root=fileparts(mfilename('fullpath'));
cd(root); addpath(root); addpath(fullfile(root,'matlab'));
if nargin==0 || isempty(cmd)
    while true
        pomoc();
        wybor=strtrim(lower(input('\nBTMS | numer lub komenda (0 = koniec): ','s')));
        if any(strcmp(wybor,{'0','koniec','exit'}))
            fprintf('Wyjscie. Aby wrocic wpisz BTMS_MENU()\n'); return;
        end
        try
            wykonaj(wybor,root);
        catch ME
            fprintf(2,'BLAD BTMS: %s\n',ME.message);
            for k=1:numel(ME.stack)
                fprintf(2,'  -> %s, linia %d\n',ME.stack(k).name,ME.stack(k).line);
            end
            fprintf('Kontrola: BTMS_MENU(''status''); gotowe dane: BTMS_MENU(''gotowe'').\n');
        end
    end
else
    % Try-catch rowniez przy bezposrednim wywolaniu BTMS_MENU('...'):
    try
        wykonaj(strtrim(lower(char(cmd))),root);
    catch ME
        fprintf(2,'BLAD BTMS: %s\n',ME.message);
        for k=1:numel(ME.stack)
            fprintf(2,'  -> %s, linia %d\n',ME.stack(k).name,ME.stack(k).line);
        end
        fprintf('Popraw blad zanim uznasz, ze wyniki MATLAB sa gotowe.\n');
    end
end
end

function pomoc()
fprintf('\n===================== BTMS / MATLAB =====================\n');
fprintf(' 1 status        Dostepnosc plikow, MATLAB i Simulink\n');
fprintf(' 2 pomoc         Spis funkcji\n');
fprintf(' 3 gotowe        24 zapisane wyniki REFERENCYJNE Python\n');
fprintf(' 4 porownaj_ref  PI vs GS z danych referencyjnych\n');
fprintf(' 5 soh_ref       SOH z danych referencyjnych\n');
fprintf(' 6 testy         Testy modelu MATLAB (24 sesje)\n');
fprintf(' 7 obliczenia    24 scenariusze + SOH + 162 niepewnosci MATLAB\n');
fprintf(' 8 calosc        Testy + obliczenia + zgodnosc + wykresy\n');
fprintf(' 9 wyniki        Tabela wynikow MATLAB\n');
fprintf('10 porownanie    PI / GS / SAFE / LIFE przy 35 C, MATLAB\n');
fprintf('11 nastawy       Kp i Ki wzgledem Ts-Tcool (Gain Scheduling)\n');
fprintf('12 przebieg      15 probek sygnalow GS_SAFE 35 C\n');
fprintf('13 energia       Cieplo i pomocnicza energia chlodzenia\n');
fprintf('14 soh           Prognoza modelowa SOH na 10 lat\n');
fprintf('15 odpornosc     162 testy niepewnosci parametrow\n');
fprintf('16 stabilnosc    Jakobiany w punktach rownowagi PI (+ osiagalnosc Tref)\n');
fprintf('17 wykresy       Wykresy z danych MATLAB\n');
fprintf('18 simulink      Simulink R2025b: generacja + symulacja + kontrola\n');
fprintf('19 nasa          NASA B0005: rzeczywiste dane (w paczce)\n');
fprintf('20 zgodnosc      Porownanie wynikow MATLAB z Python\n');
fprintf('21 raport        Pokaz katalogi wygenerowanych plikow\n');
fprintf('22 cel80         10 lat: analiza warunkow spelnienia SOH>=80%%\n');
fprintf('23 gcs           Wrazliwosc na przewodnosc rdzen-powierzchnia Gcs\n');
fprintf(' 0 koniec\n');
fprintf('Wpisanie 7/8 ponownie tworzy pliki *_matlab.csv. Nie rusza wynikow Python.\n');
end

function wykonaj(cmd,root)
if any(strcmp(cmd,{'1','status'}))
    fprintf('\n--- DIAGNOSTYKA PROJEKTU ---\n');
    fprintf('Katalog: %s\n',root);
    fprintf('MATLAB: %s\n',version);
    files={'START_BTMS.m','BTMS_MENU.m','matlab/btms_cfg.m',...
       'matlab/main_btms.m','matlab/quality_tests.m','matlab/btms_compare_reference.m',...
       'results/sessions_summary.csv','results/sessions_summary_matlab.csv'};
    for i=1:numel(files)
        fprintf('  %-42s %s\n',files{i},yesno(isfile(fullfile(root,files{i}))));
    end
    fprintf('Simulink - funkcja new_system: %s\n',yesno(~isempty(which('new_system'))));
    fprintf('Simulink - licencja testowa: %d\n',license('test','Simulink'));
    fprintf('NASA B0005.mat: %s (dane do analizy dostarczone)\n',yesno(isfile(fullfile(root,'nasa_data','B0005.mat'))));
elseif any(strcmp(cmd,{'2','pomoc','help'}))
    pomoc();
elseif any(strcmp(cmd,{'3','gotowe'}))
    fprintf('REFERENCJA PYTHON: to nie sa wyniki obecnej sesji MATLAB.\n');
    T=data(root,'sessions_summary.csv');
    disp(T(:,{'strategy','ambient_C','time_min','Tmax_C','energy_aux_kWh','status'}));
elseif any(strcmp(cmd,{'4','porownaj_ref'}))
    fprintf('REFERENCJA PYTHON | 35 C\n');porownaj(data(root,'sessions_summary.csv'));
elseif any(strcmp(cmd,{'5','soh_ref'}))
    fprintf('REFERENCJA PYTHON | SOH to PROGNOZA MODELOWA, nie NASA\n');
    disp(data(root,'life_summary.csv'));
elseif any(strcmp(cmd,{'6','testy'}))
    quality_tests();
elseif any(strcmp(cmd,{'7','obliczenia'}))
    fprintf('Przeliczam model; nadpisuje tylko wygenerowane wyniki *_matlab.csv w tym Projekcie.\n');
    main_btms();
elseif any(strcmp(cmd,{'8','calosc','wszystko'}))
    fprintf('1/5 Testy MATLAB...\n');quality_tests();
    fprintf('2/5 Symulacje MATLAB...\n');main_btms();
    fprintf('3/5 Kontrola MATLAB vs Python...\n');btms_compare_reference();
    fprintf('4/5 Wykresy MATLAB...\n');WYKRESY_MATLAB();
    fprintf('5/5 Wyniki MATLAB...\n');
    T=data(root,'sessions_summary_matlab.csv');
    disp(T(:,{'strategy','ambient_C','time_min','Tmax_C','energy_aux_kWh','status'}));
    fprintf('KONIEC. Zapisano nowe CSV i PNG. Simulink i NASA sa opcjonalne.\n');
elseif any(strcmp(cmd,{'9','wyniki'}))
    T=data(root,'sessions_summary_matlab.csv');
    disp(T(:,{'strategy','ambient_C','time_min','Tmax_C','energy_aux_kWh','status'}));
elseif any(strcmp(cmd,{'10','porownanie'}))
    porownaj(data(root,'sessions_summary_matlab.csv'));
elseif any(strcmp(cmd,{'11','nastawy'}))
    c=btms_cfg(); rho=[4;6;8;10;12;14;17;20];
    kp1=zeros(size(rho));ki1=kp1;kp2=kp1;ki2=kp1;
    for i=1:numel(rho)
       [kp1(i),ki1(i)]=btms_gains(c,'PI',c.Tcool+rho(i));
       [kp2(i),ki2(i)]=btms_gains(c,'GS',c.Tcool+rho(i));
    end
    disp(table(rho,kp1,ki1,kp2,ki2,'VariableNames',{'Ts_minus_Tcool_K','Kp_PI','Ki_PI','Kp_GS','Ki_GS'}));
    fprintf('GS: Kp,Ki = PI * clip(%g/(Ts-Tcool), %g, %g); punkt projektowy Ts-Tcool = %g K.\n', ...
        c.gs_rho0,c.gs_smin,c.gs_smax,c.gs_rho0);
elseif any(strcmp(cmd,{'12','przebieg'}))
    T=data(root,'session_35C_GS_SAFE_matlab.csv');
    idx=unique(round(linspace(1,height(T),min(15,height(T)))));
    disp(T(idx,{'time_min','Tc_C','Ts_C','SOC','I_A','u','Qgen_W','Qcool_W'}));
elseif any(strcmp(cmd,{'13','energia'}))
    T=data(root,'sessions_summary_matlab.csv');
    disp(T(T.ambient_C==35,{'strategy','energy_heat_kWh','energy_aux_kWh','time_min'}));
elseif any(strcmp(cmd,{'14','soh'}))
    fprintf('SOH po 10 latach: wariant scenariuszowy, brak walidacji NASA.\n');
    disp(data(root,'life_summary_matlab.csv'));
    fprintf('SOH_10y_pct: postoj przy 78%% SOC dla wszystkich strategii (porownanie samego ladowania).\n');
    fprintf('SOH_10y_park050_pct: ta sama strategia + polityka postoju przy 50%% SOC.\n');
elseif any(strcmp(cmd,{'15','odpornosc'}))
    T=data(root,'robustness_35C_matlab.csv');
    fprintf('Liczba przypadkow: %d; najwieksze Tmax = %.2f C; przypadki >= 40 C: %d\n',...
       height(T),max(T.Tmax_C),sum(T.Tmax_C>=40));
    disp(T(1:min(10,height(T)),:));
    fprintf('To test wrazliwosci, a nie formalna gwarancja odpornosci.\n');
elseif any(strcmp(cmd,{'16','stabilnosc'}))
    disp(data(root,'local_frozen_jacobian_matlab.csv'));
    fprintf('Liniaryzacja w wyznaczonym punkcie rownowagi (Tc=Tref); bez dowodu globalnego.\n');
    fprintf('feasible=0: przy tym pradzie i Ta rownowaga Tc=Tref nie istnieje - petla musi sie nasycic.\n');
elseif any(strcmp(cmd,{'17','wykresy'}))
    if ~isfile(fullfile(root,'results','session_35C_PI_matlab.csv'))
        error('Najpierw BTMS_MENU(''obliczenia'') lub BTMS_MENU(''calosc'').');
    end
    WYKRESY_MATLAB();
elseif any(strcmp(cmd,{'18','simulink'}))
    if isempty(which('new_system')) || license('test','Simulink')==0
        fprintf('SIMULINK niedostepny lub brak licencji. To NIE jest blad glownego projektu.\n');
        fprintf('Do obliczen wpisz BTMS_MENU(''calosc'').\n');
    else
        try
            run(fullfile(root,'URUCHOM_SIMULINK.m'));
        catch ME
            fprintf(2,'SIMULINK R2025b: blad demonstratora: %s\n',ME.message);
            for ii=1:numel(ME.stack), fprintf(2,'  %s:%d\n',ME.stack(ii).name,ME.stack(ii).line); end
            fprintf(2,'Sprawdz: matlab/btms_make_simulink.m. Nie zastępuj wyniku pomiarem.\n');
        end
    end
elseif any(strcmp(cmd,{'19','nasa'}))
    if ~isfile(fullfile(root,'nasa_data','B0005.mat'))
        fprintf('NASA: brak prawdziwego pliku Projekt/nasa_data/B0005.mat. To opcja.\n');
    else
        try
            run(fullfile(root,'URUCHOM_NASA_MATLAB.m'));
        catch ME
            fprintf(2,'Opcjonalna analiza NASA nie uruchomila sie: %s\n',ME.message);
        end
    end
elseif any(strcmp(cmd,{'20','zgodnosc'}))
    btms_compare_reference();
elseif any(strcmp(cmd,{'22','cel80','80','goal80'}))
    btms_goal80();
elseif any(strcmp(cmd,{'23','gcs','wrazliwosc'}))
    btms_sensitivity_gcs();
elseif any(strcmp(cmd,{'21','raport'}))
    fprintf('Wyniki MATLAB: %s\n',fullfile(root,'results'));
    fprintf('Wykresy MATLAB: %s\n',fullfile(root,'figures'));
    fprintf('Dokumentacja: %s\n',fullfile(root,'Dokumentacja'));
    fprintf('Aby otworzyc katalog wynikow: winopen(fullfile(pwd,''results''))  [Windows]\n');
else
    fprintf('Nieznana komenda: %s\n',cmd);pomoc();
end
end

function T=data(root,name)
file=fullfile(root,'results',name);
if ~isfile(file)
    error('Brak %s. Dla MATLAB: BTMS_MENU(''calosc''). Dla danych gotowych: BTMS_MENU(''gotowe'').',name);
end
T=readtable(file);
end
function porownaj(T)
ix=T.ambient_C==35 & ismember(string(T.strategy),{'PI','GS','PI_SAFE','GS_SAFE','GS_LIFE'});
disp(T(ix,{'strategy','time_min','Tmax_C','energy_aux_kWh','RMSE_error_K','sat_fraction'}));
end
function v=yesno(b)
if b,v='TAK';else,v='NIE';end
end
