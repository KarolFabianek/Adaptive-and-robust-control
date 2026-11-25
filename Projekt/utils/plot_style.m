function S = plot_style()
%PLOT_STYLE  Wspólny styl wykresów i kolory strategii (spójne w całym projekcie).
S.font = 'Calibri';
S.fs = 11;
S.lw = 1.8;
S.grey   = [0.45 0.50 0.56];
S.blue   = [0.00 0.40 0.75];
S.green  = [0.17 0.50 0.42];
S.orange = [0.85 0.45 0.15];
S.red    = [0.75 0.18 0.16];
S.purple = [0.45 0.30 0.70];
S.navy   = [0.00 0.12 0.37];
S.col = containers.Map( ...
    {'CC','PI','GS','GS_SAFE','STD_100','STD_90','LIFE','LIFE_ADAPT'}, ...
    {S.grey, S.purple, S.green, S.navy, S.red, S.orange, S.blue, S.green});
S.label = containers.Map( ...
    {'CC','PI','GS','GS_SAFE','STD_100','STD_90','LIFE','LIFE_ADAPT'}, ...
    {'CC (bez regulatora)','PI','GS','GS\_SAFE','STD\_100 (typowy BMS, 100%)', ...
     'STD\_90 (typowy BMS, 90%)','LIFE (proponowana)','LIFE\_ADAPT (+ pętla SOH)'});
set(groot, 'defaultAxesFontName', S.font, 'defaultTextFontName', S.font, ...
    'defaultAxesFontSize', S.fs, 'defaultLineLineWidth', S.lw, ...
    'defaultAxesXGrid', 'on', 'defaultAxesYGrid', 'on', 'defaultAxesBox', 'on', ...
    'defaultAxesGridAlpha', 0.15, 'defaultFigureColor', 'w');
% MATLAB R2025a+ ma ciemny motyw okien – wykresy do raportu zawsze jasne
try
    set(groot, 'defaultFigureTheme', 'light');
catch
end
end
