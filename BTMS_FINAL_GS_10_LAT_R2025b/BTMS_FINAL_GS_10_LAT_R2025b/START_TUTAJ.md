# BTMS – prezentacja + projekt (R2025b)

1. `Prezentacja`: 24 slajdy w dotychczasowym stylu.
2. `Projekt`: kod MATLAB, Simulink Level-2, NASA B0005, testy i raport.

W Command Window MATLAB:
```matlab
[f,p]=uigetfile('START_BTMS.m','Wybierz Projekt/START_BTMS.m');
if ~isequal(f,0),run(fullfile(p,f));end
```

Menu: 8 = pełna symulacja, 22 = cel SOH 80%/10 lat, 18 = Simulink, 19 = NASA.
Po wyjściu z menu: `BTMS_MENU('calosc')`, `BTMS_MENU('cel80')`, `BTMS_MENU('simulink')`, `BTMS_MENU('nasa')`.

W 35°C bez dodatkowych warunków przechowywania cel 80% nie jest osiągnięty. Scenariusz przy 23°C i 40% SOC w czasie parkowania osiąga modelowo 80,68%; wymaga niezamodelowanego aktywnego chłodzenia w okresie przechowywania.

Wyniki MATLAB i Python dla podstawowych 24 sesji zostały już porównane przez użytkownika; nowego Simulink Level-2 jeszcze nie uruchomiono w R2025b w tym środowisku.
