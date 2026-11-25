function save_fig(fig, name)
%SAVE_FIG  Zapis wykresu do figures/<name>.png (200 dpi) i zamknięcie okna
%   w trybie wsadowym. W trybie interaktywnym okno pozostaje otwarte.
root = fileparts(fileparts(mfilename('fullpath')));
f = fullfile(root, 'figures', [name '.png']);
try
    theme(fig, 'light');
catch
end
exportgraphics(fig, f, 'Resolution', 200);
if ~usejava('desktop')
    close(fig);
end
fprintf('   wykres: figures/%s.png\n', name);
end
