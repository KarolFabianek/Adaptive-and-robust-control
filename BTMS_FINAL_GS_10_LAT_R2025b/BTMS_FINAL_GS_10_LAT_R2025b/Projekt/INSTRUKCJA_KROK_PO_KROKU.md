# BTMS – MATLAB R2025b

Rozpakuj kompletny folder, nie łącz z poprzednimi paczkami.

## Pierwszy start w Command Window
```matlab
[f,p] = uigetfile('START_BTMS.m','Wybierz plik w folderze Projekt');
if ~isequal(f,0), run(fullfile(p,f)); end
```
W menu: 8 pełna symulacja, 22 warunek SOH 80%, 18 Simulink, 19 NASA, 23 wrażliwość na Gcs.

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
BTMS_MENU('gcs')
```

Dane NASA B0005.mat sa w nasa_data. Nowy generator Simulink uzywa Level-2 MATLAB S-Function.
GS_LIFE 35°C: Tc,max=35.18°C. SOH po 10 latach (GS_LIFE + postój 50% SOC): 77.12% przy średniej rocznej 35°C (NIE), 81.17% przy 25°C (TAK); próg spełnienia ≤ 27°C.
SOH_10y_pct w life_summary*.csv: wspólny postój 78% SOC dla wszystkich strategii; SOH_10y_park050_pct: polityka postoju 50% SOC.

Simulink Level-2 uruchomiony i zgodny z sesją MATLAB GS_LIFE (weryfikacja 18.11.2026, MATLAB R2026a).
