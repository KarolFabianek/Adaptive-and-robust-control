# Ćwiczenia laboratoryjne – BTMS i trwałość baterii EV

Pięć ćwiczeń w folderze `Projekt/lab/`. Wszystkie wydruki poniżej pochodzą z uruchomienia w MATLAB R2026b (z Simulinkiem). Każde jest skryptem MATLAB podzielonym na sekcje `%%`. Uruchamia się je sekcja po sekcji: **Ctrl+Enter** albo *Run Section*. Każde ćwiczenie trwa ok. 1–2 min obliczeń (laptop na zasilaczu; na baterii 3–5 razy dłużej). Na końcu każdego pliku są **zadania do samodzielnego wykonania**.

**Przygotowanie:** otwórz MATLAB i ustaw folder bieżący na `Projekt` (albo `Projekt/lab`). Skrypty same dodają potrzebne ścieżki.

| Lab | Plik | Temat | Związek z przedmiotem |
|---|---|---|---|
| 1 | `lab1_model_obiektu.m` | model pakietu 96s50p, odpowiedź skokowa, bieguny, wzmocnienie dQ/du zależne od punktu pracy | identyfikacja obiektu, linearyzacja |
| 2 | `lab2_regulator_pi_gs.m` | PI vs gain scheduling w 3 klimatach, harmonogram Kp(ρ), pulsacja odcięcia | **sterowanie adaptacyjne (GS)** |
| 3 | `lab3_ladowanie_i_anoda.m` | CC-CV, limit prądu z potencjału anody, podgrzewanie, aktywne ograniczenia | sterowanie z ograniczeniami, nadzór |
| 4 | `lab4_trwalosc_10_lat.m` | 10 lat eksploatacji, pętla SOH (RLS + PI), wpływ klimatu | **adaptacja z estymacją (RLS), odporność** |
| 5 | `lab5_simulink.m` | model blokowy Simulink, Scope, porównanie ze skryptem | implementacja w Simulinku |

## Lab 1 – Model obiektu

**Co robimy:** liczymy parametry pakietu, symulujemy odpowiedź temperatury rdzenia na prąd 300 A bez chłodzenia i z chłodzeniem, wyznaczamy bieguny modelu cieplnego.

**Co powinno wyjść w Command Window:**

```
Pakiet: 345.6 V, 175 Ah, 60.48 kWh, R = 53.76 mOhm
Pojemności cieplne: Cc = 157.6 kJ/K, Cs = 49.8 kJ/K
Po 60 min: Tc = 61.7 °C (u = 0), 35.8 °C (u = 0.5)
rho =  5 K: dQcool/du = Gcool*rho =  2350 W (na 1.0 sterowania)
rho = 10 K: dQcool/du = Gcool*rho =  4700 W (na 1.0 sterowania)
rho = 17 K: dQcool/du = Gcool*rho =  7990 W (na 1.0 sterowania)
Bieguny: -4.40e-02 i -1.20e-04 1/s  ->  stałe czasowe 22.7 s oraz 2.32 h
```

Szybki biegun (22,7 s) to wymiana ciepła rdzeń–powierzchnia, wolny (2,3 h) to stygnięcie całego pakietu do otoczenia.

**Wniosek:** wzmocnienie elementu wykonawczego zmienia się 3,4× w zakresie pracy. To uzasadnia gain scheduling.

## Lab 2 – PI vs gain scheduling

**Co robimy:** rysujemy harmonogram k = clip(17/ρ; 1; 3) i porównujemy PI z GS w sesji 25 → 80% SOC przy 15/25/35°C. Liczymy też pulsację odcięcia pętli otwartej bez Control System Toolbox.

**Co powinno wyjść w Command Window:**

```
   Ta     PI: Tc,max   GS: Tc,max   różnica
   15°C     34.11 °C     33.73 °C   -0.37 K
   25°C     35.29 °C     34.71 °C   -0.58 K
   35°C     36.17 °C     35.92 °C   -0.25 K

  rho    wc PI [mrad/s]   wc GS [mrad/s]
   6 K        0.88             2.67
  10 K        1.53             2.67
  17 K        2.67             2.67
```

**Wniosek:** przy 35°C GS ≈ PI (punkt projektowy), przy 15–25°C GS utrzymuje rdzeń chłodniej o 0,4–0,6 K. PI przy ρ = 6 K ma ok. 3× mniejszą ω_c (0,88 mrad/s), a GS utrzymuje ok. 2,7 mrad/s (skrypt podaje pierwszy punkt siatki poniżej |L| = 1; E03 interpoluje i daje 2,61).

## Lab 3 – Parametry ładowania i litowanie anody

**Co robimy:** liczymy bezpieczny prąd ładowania w funkcji temperatury. Porównujemy typowy BMS (STD_90) ze strategią LIFE przy 0°C i sprawdzamy, który limit prądu jest aktywny.

**Co powinno wyjść w Command Window:**

```
T = -10°C, SOC 80%:  I_max = 0.13C  (22 A na pakiet)
T =   0°C, SOC 80%:  I_max = 0.29C  (51 A na pakiet)
T =  10°C, SOC 80%:  I_max = 0.64C  (111 A na pakiet)
T =  25°C, SOC 80%:  I_max = 1.85C  (324 A na pakiet)
T =  35°C, SOC 80%:  I_max = 3.56C  (624 A na pakiet)

STD_90: 46.7 min, phi_min =  -5.0 mV, litowanie   47 ppm
LIFE  : 21.0 min, phi_min =  48.9 mV, litowanie    0 ppm, podgrzanie 1.27 kWh
limit baza     aktywny przez 100.0% czasu ładowania
```

**Wniosek:** typowa tablica BMS (0,3C przy 0°C) nie wystarcza przy wysokim SOC – anoda lekko się lituje. LIFE podgrzewa pakiet w trasie do ok. 21°C, więc przez całe ładowanie aktywny jest tylko limit bazowy 300 A. Limit anody zadziała, gdy podgrzewanie zostanie osłabione (zadanie Z1).

## Lab 4 – Trwałość i pętla adaptacyjna

**Co robimy:** symulujemy 10 lat dla czterech strategii i obserwujemy poziom ochrony λ(t) oraz okno SOC.

**Co powinno wyjść w Command Window (Dubaj):**

```
STD_100    SOH(10 lat) =  69.2%  kal. 19.8  cykl. 11.0  lit. 0.0 p.p.  E_term =   28 kWh/rok
STD_90     SOH(10 lat) =  72.5%  kal. 17.4  cykl. 10.0  lit. 0.0 p.p.  E_term =   30 kWh/rok
LIFE       SOH(10 lat) =  78.3%  kal. 13.0  cykl.  8.7  lit. 0.0 p.p.  E_term =  166 kWh/rok
LIFE_ADAPT SOH(10 lat) =  80.8%  kal. 11.0  cykl.  8.2  lit. 0.0 p.p.  E_term =  396 kWh/rok
```

**Wniosek:** w gorącym klimacie cel 80% spełnia tylko strategia z pętlą adaptacyjną, kosztem energii chłodzenia. W Opolu i Madrycie pętla sama luzuje ochronę (λ → 0).

## Lab 5 – Simulink

**Co robimy:** budujemy model `btms_life_simulink.slx` (bloki MATLAB Function, 1-D Lookup Table jako harmonogram GS, Unit Delay jako stany). Uruchamiamy go i porównujemy ze skryptem.

**Co powinno wyjść w Command Window:**

```
Simulink: 1544 kroków = 25.7 min, Tc,max = 31.39 °C
MATLAB:   25.7 min, Tc,max = 31.39 °C, max |dTc| = 5.0e-07 K
```

**Wniosek:** model blokowy i skrypt dają te same przebiegi. Różnica ok. 10⁻⁷ K wynika tylko z interpolacji tablicy GS.

## Sprawozdanie – proponowany zakres

1. Schemat układu sterowania (3 pętle) i parametry obiektu.
2. Wyniki Lab 2: tabela Tc,max PI/GS i wykres harmonogramu. Odpowiedź na Z1–Z3.
3. Wyniki Lab 3: przebiegi I, Tc, φ_an przy 0°C. Kompromis czas – litowanie (Z2).
4. Wyniki Lab 4: SOH(10 lat) dla wybranego klimatu i interpretacja λ(t).
5. Wnioski: kiedy adaptacja (GS, RLS) jest konieczna, a kiedy wystarczy stały regulator.
