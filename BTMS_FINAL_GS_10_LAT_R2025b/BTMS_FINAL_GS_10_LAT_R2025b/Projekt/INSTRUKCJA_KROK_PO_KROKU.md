# BTMS – MATLAB R2025b

Rozpakuj kompletny folder, nie łącz z poprzednimi paczkami.

## Pierwszy start w Command Window
```matlab
[f,p] = uigetfile('START_BTMS.m','Wybierz plik w folderze Projekt');
if ~isequal(f,0), run(fullfile(p,f)); end
```
W menu: 8 pełna symulacja, 22 warunek SOH 80%, 18 Simulink, 19 NASA.

## Po wyjściu z menu: komendy bezpośrednie
```matlab
BTMS_MENU('calosc')
BTMS_MENU('cel80')
BTMS_MENU('porownanie')
BTMS_MENU('nastawy')
BTMS_MENU('przebieg')
BTMS_MENU('energia')
BTMS_MENU('soh')
BTMS_MENU('odpornosc')
BTMS_MENU('stabilnosc')
BTMS_MENU('zgodnosc')
BTMS_MENU('wykresy')
BTMS_MENU('simulink')
BTMS_MENU('nasa')
```

Dane NASA B0005.mat sa w nasa_data. Nowy generator Simulink uzywa Level-2 MATLAB S-Function.
GS_LIFE 35°C: Tc,max=37.56°C; SOH=75.21%, czyli NIE OSIAGA 80%. Dodatkowy warunkowy scenariusz parkowania 23°C i SOC 40% daje ok. 80.68%. Energia chłodzenia podczas parkowania nie została zamodelowana.

Nowe modele Simulink należy przetestować na lokalnym MATLAB R2025b (nieprzetestowane w kontenerze).
