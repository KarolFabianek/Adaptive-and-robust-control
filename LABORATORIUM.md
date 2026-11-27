# Ćwiczenia laboratoryjne

Sterowanie ładowaniem i temperaturą baterii pojazdu elektrycznego z ograniczeniem starzenia.

Pięć ćwiczeń w folderze `Projekt/lab/`. Każde ćwiczenie jest skryptem MATLAB podzielonym na sekcje `%%`, uruchamianym sekcja po sekcji skrótem **Ctrl+Enter** (*Run Section*). Na końcu każdego pliku są zadania do samodzielnego wykonania. Wydruki poniżej pochodzą z uruchomienia w MATLAB R2026b z Simulinkiem.

**Przygotowanie:** w MATLAB-ie ustaw folder bieżący na `Projekt` albo `Projekt/lab`. Skrypty same dodają potrzebne ścieżki.

| Lab | Plik | Temat | Związek z przedmiotem |
|---|---|---|---|
| 1 | `lab1_model_obiektu.m` | model pakietu 96s50p, odpowiedź skokowa, bieguny, wzmocnienie dQ/du zależne od punktu pracy | identyfikacja obiektu, linearyzacja |
| 2 | `lab2_regulator_pi_gs.m` | regulatory PI i GS w trzech temperaturach, harmonogram Kp(ρ), pulsacja odcięcia | **sterowanie adaptacyjne (gain scheduling)** |
| 3 | `lab3_ladowanie_i_anoda.m` | ładowanie CC-CV, limit prądu z potencjału anody, podgrzewanie, aktywne ograniczenia | sterowanie z ograniczeniami, nadzór |
| 4 | `lab4_trwalosc_10_lat.m` | 10 lat eksploatacji, pętla SOH (RLS i PI), wpływ klimatu | **adaptacja z estymacją (RLS), odporność** |
| 5 | `lab5_simulink.m` | model blokowy Simulink, blok Scope, porównanie ze skryptem | implementacja w Simulinku |

## Lab 1. Model obiektu

**Przebieg:** obliczenie parametrów pakietu, odpowiedź temperatury rdzenia na prąd 300 A bez chłodzenia i z chłodzeniem, bieguny modelu cieplnego.

**Wynik w Command Window:**

```
Pakiet: 345.6 V, 175 Ah, 60.48 kWh, R = 53.76 mOhm
Pojemności cieplne: Cc = 157.6 kJ/K, Cs = 49.8 kJ/K
Po 60 min: Tc = 61.7 °C bez chłodzenia, 35.8 °C z chłodzeniem
rho =  5 K: dQ/du = Gcool rho =  2350 W
rho = 10 K: dQ/du = Gcool rho =  4700 W
rho = 17 K: dQ/du = Gcool rho =  7990 W
Bieguny: -4.40e-02 i -1.20e-04 1/s, stałe czasowe 22.7 s i 2.32 h
```

Szybki biegun (22,7 s) opisuje wymianę ciepła między rdzeniem a powierzchnią, wolny (2,3 h) stygnięcie całego pakietu do otoczenia.

**Wniosek:** wzmocnienie elementu wykonawczego zmienia się 3,4 raza w zakresie pracy. To uzasadnia zastosowanie gain schedulingu.

## Lab 2. Regulatory PI i GS

**Przebieg:** wykres harmonogramu k(ρ) = 17/ρ w granicach od 1 do 3, porównanie PI i GS przy ładowaniu od 25 do 80% SOC w 15, 25 i 35°C, pulsacja odcięcia pętli otwartej bez Control System Toolbox.

**Wynik w Command Window:**

```
   Ta     Tc,max PI    Tc,max GS    różnica
   15°C     34.11 °C     33.73 °C   -0.37 K
   25°C     35.29 °C     34.71 °C   -0.58 K
   35°C     36.17 °C     35.92 °C   -0.25 K

  rho    wc PI [mrad/s]   wc GS [mrad/s]
   6 K        0.88             2.67
  10 K        1.53             2.67
  17 K        2.67             2.67
```

**Wniosek:** przy 35°C (punkt projektowy) regulatory działają podobnie. Przy 15 i 25°C GS utrzymuje rdzeń chłodniejszy o 0,4 do 0,6 K. Przy ρ = 6 K pętla z PI jest trzy razy wolniejsza (0,88 mrad/s), a GS zachowuje pulsację odcięcia z punktu projektowego. Skrypt podaje pierwszy punkt siatki z |L| < 1, a eksperyment E03 interpoluje i daje 2,61 mrad/s.

## Lab 3. Parametry ładowania i litowanie anody

**Przebieg:** największy prąd ładowania bez litowania w funkcji temperatury, porównanie typowego BMS (STD-90) ze strategią LIFE przy 0°C, udział poszczególnych ograniczeń prądu.

**Wynik w Command Window:**

```
T = -10°C, SOC 80%:  I_max = 0.13C  (22 A na pakiet)
T =   0°C, SOC 80%:  I_max = 0.29C  (51 A na pakiet)
T =  10°C, SOC 80%:  I_max = 0.64C  (111 A na pakiet)
T =  25°C, SOC 80%:  I_max = 1.85C  (324 A na pakiet)
T =  35°C, SOC 80%:  I_max = 3.56C  (624 A na pakiet)

STD_90: 46.7 min, phi_min =  -5.0 mV, litowanie   47 ppm
LIFE:   21.0 min, phi_min =  48.9 mV, litowanie    0 ppm, podgrzewanie 1.27 kWh
ograniczenie bazowe     aktywne przez 100.0% czasu ładowania
ograniczenie profil     aktywne przez   0.0% czasu ładowania
ograniczenie termiczne  aktywne przez   0.0% czasu ładowania
ograniczenie tablica    aktywne przez   0.0% czasu ładowania
ograniczenie anoda      aktywne przez   0.0% czasu ładowania
ograniczenie CV         aktywne przez   0.0% czasu ładowania
```

**Wniosek:** tablica typowego BMS (0,3C przy 0°C) nie wystarcza przy wysokim SOC i anoda lekko się lituje. LIFE podgrzewa pakiet w drodze do ładowarki, więc przez całe ładowanie działa tylko ograniczenie bazowe 300 A. Limit anody włącza się, gdy podgrzewanie jest słabsze (zadanie Z1).

## Lab 4. Trwałość i pętla adaptacyjna

**Przebieg:** symulacja 10 lat dla czterech strategii, przebieg poziomu ochrony λ(t) i docelowego SOC ładowania AC.

**Wynik w Command Window (Dubaj):**

```
STD_100    SOH po 10 latach  69.2%, straty: kalendarzowe 19.8, cykliczne 11.0, litowanie 0.0 p.p., energia BTMS   28 kWh/rok
STD_90     SOH po 10 latach  72.5%, straty: kalendarzowe 17.4, cykliczne 10.0, litowanie 0.0 p.p., energia BTMS   30 kWh/rok
LIFE       SOH po 10 latach  78.3%, straty: kalendarzowe 13.0, cykliczne  8.7, litowanie 0.0 p.p., energia BTMS  166 kWh/rok
LIFE_ADAPT SOH po 10 latach  80.8%, straty: kalendarzowe 11.0, cykliczne  8.2, litowanie 0.0 p.p., energia BTMS  396 kWh/rok
```

**Wniosek:** w gorącym klimacie wymaganie 80% spełnia tylko strategia z pętlą adaptacyjną, kosztem energii chłodzenia. W Opolu i Madrycie pętla sama łagodzi ochronę, λ spada do 0.

## Lab 5. Simulink

**Przebieg:** budowa modelu `btms_life_simulink.slx` (bloki MATLAB Function, harmonogram GS jako 1-D Lookup Table, stany w blokach Unit Delay), symulacja i porównanie ze skryptem.

**Wynik w Command Window:**

```
Simulink: 1544 kroków, 25.7 min, Tc,max = 31.39 °C
MATLAB:   25.7 min, Tc,max = 31.39 °C, największa różnica Tc = 5.0e-07 K
```

**Wniosek:** model blokowy i skrypt dają te same przebiegi. Różnica rzędu 10⁻⁷ K wynika wyłącznie z interpolacji tablicy harmonogramu.

## Sprawozdanie

1. Schemat układu sterowania z trzema pętlami i parametry obiektu.
2. Lab 2: tabela Tc,max dla PI i GS, wykres harmonogramu, odpowiedzi na zadania Z1 do Z3.
3. Lab 3: przebiegi prądu, temperatury rdzenia i potencjału anody przy 0°C, zależność czasu ładowania od zapasu potencjału (Z2).
4. Lab 4: SOH po 10 latach dla wybranego klimatu i interpretacja przebiegu λ(t).
5. Wnioski: kiedy adaptacja (GS, RLS) jest konieczna, a kiedy wystarcza regulator o stałych nastawach.
