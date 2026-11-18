# BTMS - Fabianek & Fortuna - wersja R2025b

**Cel:** pojemnosc SOH >= 80% po 10 latach i temperatura rdzenia ponizej 40 C.

## Najwazniejsze wyniki (Ta = 35 C, Gcs = 1650 W/K)
- Bez regulatora (CC) Tc,max = 51,0 C; PI 37,96 C, GS 37,90 C; z FF ok. 35,5 C - bez wydluzania ladowania (20,9 min).
- Nadzor pradu (SAFE) nominalnie sie nie wlacza - to zabezpieczenie; w 162 testach niepewnosci maks. 38,17 C.
- GS po Ts - Tcool: rowny PI w punkcie projektowym (35 C), lepszy poza nim (25 C: 36,31 vs 36,88 C; 15 C: 34,46 vs 34,87 C).
- SOH po 10 latach: GS_LIFE + postoj 50% SOC -> 77,12% przy sredniej rocznej 35 C (NIE spelnia), 81,17% przy 25 C (spelnia).
  Cel 80% jest spelniony dla sredniej temperatury postoju <= 27 C przy 50% SOC (<= 20 C przy 78%, <= 30 C przy 40%).

## Uruchomienie
W MATLAB Command Window wklej:

```matlab
[f,p]=uigetfile('START_BTMS.m','Wybierz plik z folderu Projekt');
if ~isequal(f,0),run(fullfile(p,f));end
```

W menu: `8` wszystkie sesje i testy, `22` cel 80%, `18` Simulink, `19` NASA, `23` wrazliwosc na Gcs.
Po `0` te same polecenia: `BTMS_MENU('calosc')`, `BTMS_MENU('cel80')`, `BTMS_MENU('simulink')`, `BTMS_MENU('nasa')`, `BTMS_MENU('gcs')`.

**Wyniki:** `results/`, `figures/`.
**NASA:** prawdziwy `nasa_data/B0005.mat`; tylko walidacja prostego modelu degradacji ogniwa, nie termiczna walidacja EV.
**Simulink:** model generowany programowo przez obslugiwany Level-2 MATLAB S-Function (plik .slx w formacie R2025b).

## Model i regulator (po przegladzie 18.11.2026)
- **Gcs = 1650 W/K** = ok. 2,9 K/W na ogniwo 18650 (k_r = 0,43 W/(m K), Bhundiya i in. 2018). Poprzednie 165 W/K bylo ok. 10x za malo
  (`BTMS_MENU('gcs')` pokazuje, jak wnioski zalezaly od tego parametru).
- **Gain Scheduling po rho = Ts - Tcool:** Kp, Ki = PI * clip(17/rho, 1, 3). Wzmocnienie chlodzenia Gcool*(Ts-Tcool) maleje,
  gdy powierzchnia stygnie; PI dostrojono dla rho0 = 17 K (35 - 18 C).
- **SOH:** `SOH_10y_pct` liczone przy tym samym postoju (78% SOC) dla wszystkich strategii; `SOH_10y_park050_pct` = polityka postoju 50% SOC.
- **Stabilnosc:** liniaryzacja w wyznaczonych punktach rownowagi PI (15/25/35 C, 120/210/300 A); 38 z 54 osiagalnych, wszystkie stabilne.
- **NASA:** model Q=a+b*N (RMSE test 0,031 Ah) zamiast Q=a+b*sqrt(N) (0,083 Ah, gorszy od persystencji 0,075 Ah).

## Status weryfikacji (18.11.2026)
- `testy`, `calosc`, `cel80`, `nasa`, `simulink`, `gcs` uruchomione w MATLAB R2026a (Simulink) - wszystkie testy PASS.
- MATLAB == Python dla wszystkich wynikow (roznice ~1e-14). Simulink == sesja MATLAB GS_LIFE (blad 0).
- Szczegoly zmian: `ZMIANY_PO_PRZEGLADZIE.md`.

## Zastrzezenia
- Model zastepczy (bez OCV, napiecia, DCIR, rozrzutu ogniw); Gcs z literatury, nie z pomiaru pakietu.
- Regulator i nadzor uzywaja temperatury rdzenia, ktorej w pakiecie sie nie mierzy - w praktyce potrzebny obserwator.
- 35 C jako srednia roczna temperatura postoju to ekstremum (rekord swiata: Dallol, ok. 34,6 C).
