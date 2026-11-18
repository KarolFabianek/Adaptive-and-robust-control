function T = btms_sensitivity_gcs(Ta)
% WRAZLIWOSC WYNIKOW NA PRZEWODNOSC RDZEN-POWIERZCHNIA Gcs.
% Baza: Gcs = 1650 W/K (ok. 2,9 K/W na ogniwo 18650; k_r = 0,43 W/(m K),
% R ~ 1/(4*pi*k*L)); Lin i in. (IEEE TCST 2013) podaja Rc = 1,83 K/W dla 26650.
% Siatka obejmuje tez stara wartosc 165 W/K (~29 K/W), zeby pokazac, jak
% wnioski (czy sam PI utrzyma Tc < 40 C) zalezaly od tego parametru.
if nargin<1 || isempty(Ta), Ta=35; end
root=fileparts(fileparts(mfilename('fullpath')));
c0=btms_cfg(); ncell=c0.ns*c0.np;
Gvals=[165 330 660 1650 2600];
strategies={'CC','PI','GS','GS_SAFE','GS_LIFE'};
rows=cell(numel(Gvals)*numel(strategies),9); k=0;
for G=Gvals
    c=c0; c.Gcs=G;
    for i=1:numel(strategies)
        s=btms_run_session(c,strategies{i},Ta); k=k+1;
        rows(k,:)={G,ncell/G,string(strategies{i}),Ta,s.Tmax_C,s.time_min, ...
            s.energy_aux_kWh,s.sat_fraction,s.Tmax_C<c.Tlim};
    end
end
T=cell2table(rows,'VariableNames',{'Gcs_W_per_K','Rth_cell_K_per_W','strategy', ...
    'ambient_C','Tmax_C','time_min','energy_aux_kWh','sat_fraction','below_40C'});
out=fullfile(root,'results'); if ~isfolder(out),mkdir(out);end
writetable(T,fullfile(out,'gcs_sensitivity_matlab.csv'));
disp(T);
fprintf('Baza Gcs=%g W/K = %.1f K/W na ogniwo; stara wartosc 165 W/K = %.1f K/W.\n',c0.Gcs,ncell/c0.Gcs,ncell/165);
fprintf('Przy 165 W/K sam PI przekracza 40 C; przy >= 660 W/K miesci sie ponizej 40 C.\n');
end
