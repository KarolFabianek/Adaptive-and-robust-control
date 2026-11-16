# BTMS - Fabianek & Fortuna - wersja R2025b

**Cel:** pojemnosc SOH >= 80% po 10 latach i temperatura rdzenia ponizej 40 C.
**Uwaga:** przy Ta=35 C GS_LIFE chroni termicznie, lecz w bazowym scenariuszu daje SOH=75,21%, wiec nie spelnia 80%.

## Uruchomienie
W MATLAB Command Window wklej:

```matlab
[f,p]=uigetfile('START_BTMS.m','Wybierz plik z folderu Projekt');
if ~isequal(f,0),run(fullfile(p,f));end
```

W menu: `8` wszystkie sesje i testy, `22` cel 80%, `18` nowy Simulink, `19` NASA.
Po `0` te same polecenia: `BTMS_MENU('calosc')`, `BTMS_MENU('cel80')`, `BTMS_MENU('simulink')`, `BTMS_MENU('nasa')`.

**Wyniki:** `results/`, `figures/`.
**NASA:** prawdziwy `nasa_data/B0005.mat`; tylko walidacja prostego modelu degradacji ogniwa, nie termiczna walidacja EV.
**Simulink:** model generowany programowo przez obsługiwany Level-2 MATLAB S-Function.
**Uwaga na wyniki:** scenariusz parkowania 23 C / 40% SOC to warunek inżynierski; chłodzenie na postoju i jego energia nie są zasymulowane.
