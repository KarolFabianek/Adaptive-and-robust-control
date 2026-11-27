function S = plot_style()
%PLOT_STYLE  Wspólny styl wykresów: czcionki, kolory i nazwy strategii.
S.font = 'Calibri';
S.fs = 12;
S.lw = 2;
S.grey   = [0.45 0.50 0.56];
S.blue   = [0.00 0.40 0.75];
S.green  = [0.17 0.50 0.42];
S.orange = [0.85 0.45 0.15];
S.red    = [0.75 0.18 0.16];
S.purple = [0.45 0.30 0.70];
S.navy   = [0.00 0.12 0.37];
keys = {'CC','PI','GS','GS_SAFE','STD_100','STD_90','LIFE','LIFE_ADAPT'};
S.col = containers.Map(keys, ...
    {S.grey, S.purple, S.green, S.navy, S.red, S.orange, S.blue, S.green});
% Nazwy na wykresach: kod strategii z myślnikiem zamiast podkreślenia
S.short = containers.Map(keys, ...
    {'CC','PI','GS','GS-SAFE','STD-100','STD-90','LIFE','LIFE-ADAPT'});
S.label = containers.Map(keys, ...
    {'CC (stałe chłodzenie)','PI','GS','GS-SAFE (GS, FF, nadzór prądu)', ...
     'STD-100 (typowy BMS, do 100%)','STD-90 (typowy BMS, do 90%)', ...
     'LIFE (limit anody, ładowanie do 79%)','LIFE-ADAPT (LIFE z pętlą SOH)'});
set(groot, 'defaultAxesFontName', S.font, 'defaultTextFontName', S.font, ...
    'defaultAxesFontSize', S.fs, 'defaultLineLineWidth', S.lw, ...
    'defaultAxesXGrid', 'on', 'defaultAxesYGrid', 'on', 'defaultAxesBox', 'on', ...
    'defaultAxesGridAlpha', 0.15, 'defaultFigureColor', 'w', ...
    'defaultAxesTitleFontWeight', 'bold', 'defaultAxesTitleFontSizeMultiplier', 1.05, ...
    'defaultLegendFontSize', 10.5, 'defaultLegendBox', 'on');
% Wykresy do raportu zawsze w jasnym motywie (MATLAB R2025a i nowsze)
try
    set(groot, 'defaultFigureTheme', 'light');
catch
end
end
