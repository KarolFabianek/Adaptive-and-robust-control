# BTMS – prezentacja + projekt (R2025b)

1. `Prezentacja`: 24 slajdy w dotychczasowym stylu.
2. `Projekt`: kod MATLAB, Simulink Level-2, NASA B0005, testy i raport.

W Command Window MATLAB:
```matlab
[f,p]=uigetfile('START_BTMS.m','Wybierz Projekt/START_BTMS.m');
if ~isequal(f,0),run(fullfile(p,f));end
```

Menu: 8 = pełna symulacja, 22 = cel SOH 80%/10 lat, 18 = Simulink, 19 = NASA, 23 = wrażliwość na Gcs.
Po wyjściu z menu: `BTMS_MENU('calosc')`, `BTMS_MENU('cel80')`, `BTMS_MENU('simulink')`, `BTMS_MENU('nasa')`, `BTMS_MENU('gcs')`.

Model po przeglądzie: Gcs = 1650 W/K (2,9 K/W na ogniwo), Gain Scheduling po Ts − Tcool, SOH strategii przy wspólnym SOC postoju.

Przy 35°C regulator PI trzyma Tc ≈ 38°C (z FF ≈ 35,5°C) bez wydłużania ładowania. Cel 80% SOH po 10 latach (GS_LIFE + postój 50% SOC) jest spełniony, gdy średnia roczna temperatura postoju ≤ 27°C; przy rekordowej średniej 35°C model daje 77,1%.

Weryfikacja (18.11.2026): MATLAB vs Python dla 24 sesji – zgodne; Simulink Level-2 uruchomiony i zgodny z sesją MATLAB (MATLAB R2026a). Zmiany po przeglądzie: `Projekt/ZMIANY_PO_PRZEGLADZIE.md`.
