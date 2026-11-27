function save_fig(fig, name)
%SAVE_FIG  Zapis wykresu do pliku figures/<name>.png w rozdzielczości 200 dpi.
%   W trybie wsadowym okno jest zamykane, w trybie interaktywnym zostaje.
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
