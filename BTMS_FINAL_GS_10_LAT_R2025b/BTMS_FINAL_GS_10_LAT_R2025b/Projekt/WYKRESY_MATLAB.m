function WYKRESY_MATLAB()
% Wykresy tylko z plikow *_matlab.csv; nigdy nie miesza referencji Python.
root=fileparts(mfilename('fullpath'));
out=fullfile(root,'results'); figdir=fullfile(root,'figures');
if ~isfolder(figdir),mkdir(figdir);end
names={'PI','GS','GS_SAFE','GS_LIFE'};
C=[.15,.43,.75;.07,.63,.48;.92,.47,.28;.48,.33,.75];
for i=1:numel(names)
  fn=fullfile(out,['session_35C_' names{i} '_matlab.csv']);
  if ~isfile(fn),error('Brak %s. Najpierw BTMS_MENU(''calosc'').',fn);end
end
fig=figure('Name','BTMS - temperatury 35 C','Color','w','Position',[100 80 970 520]);
hold on;
for i=1:numel(names)
  T=readtable(fullfile(out,['session_35C_' names{i} '_matlab.csv']));
  plot(T.time_min,T.Tc_C,'LineWidth',2,'Color',C(i,:));
end
Tlim=40; plot(xlim,[Tlim Tlim],'--','LineWidth',1.4,'Color',[.85,.22,.24]);
grid on; xlabel('Czas [min]'); ylabel('Temperatura rdzenia [C]');
title('BTMS: temperatura rdzenia, T otoczenia = 35 C');
legend([names {'kryterium 40 C'}],'Location','best');
try, gca.Toolbar.Visible='off'; catch, end
exportgraphics(fig,fullfile(figdir,'matlab_temperatura_35C.png'),'Resolution',170);
fig=figure('Name','BTMS - prady 35 C','Color','w','Position',[120 90 970 520]);
hold on;
for i=1:numel(names)
  T=readtable(fullfile(out,['session_35C_' names{i} '_matlab.csv']));
  plot(T.time_min,T.I_A,'LineWidth',2,'Color',C(i,:));
end
grid on; xlabel('Czas [min]'); ylabel('Prad [A]');
title('BTMS: prad ladowania, T otoczenia = 35 C');
legend(names,'Location','best');
try, gca.Toolbar.Visible='off'; catch, end
exportgraphics(fig,fullfile(figdir,'matlab_prad_35C.png'),'Resolution',170);
fprintf('Wykresy zapisano w: %s\n',figdir);
end
