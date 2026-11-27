function save_fig(fig, name)
%SAVE_FIG  Zapis wykresu do pliku figures/<name>.png w rozdzielczości 200 dpi.
%   W trybie wsadowym okno jest zamykane, w trybie interaktywnym zostaje.
%   Eksport jest powtarzany do trzech razy, bo w trybie wsadowym renderer
%   bywa chwilowo niegotowy. Ostatnia próba korzysta z funkcji print.
root = fileparts(fileparts(mfilename('fullpath')));
f = fullfile(root, 'figures', [name '.png']);
try
    theme(fig, 'light');
catch
end
ok = false;
for proba = 1:3
    try
        drawnow;
        exportgraphics(fig, f, 'Resolution', 200);
        ok = true;
        break
    catch err
        pause(1);
    end
end
if ~ok
    if ~isgraphics(fig)
        rethrow(err);
    end
    print(fig, f, '-dpng', '-r200');
end
if ~usejava('desktop')
    close(fig);
end
fprintf('   wykres: figures/%s.png\n', name);
end
