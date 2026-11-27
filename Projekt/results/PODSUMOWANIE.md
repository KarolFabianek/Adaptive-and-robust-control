# Podsumowanie wyników (wygenerowane przez run_all.m, 2026-11-27 10:06, MATLAB R2026b)

Testy poprawności: wszystkie zaliczone

## E05. SOH po 10 latach [%]

| klimat | STD-100 | STD-90 | LIFE | LIFE-ADAPT |
|---|---:|---:|---:|---:|
| opole | 81.1 | 85.0 | 87.9 | 87.6 |
| madryt | 79.1 | 82.3 | 85.2 | 84.6 |
| dubaj | 69.2 | 72.5 | 78.3 | 80.8 |

## E06. Monte Carlo, Madryt: odsetek pakietów z SOH co najmniej 80%

| strategia | średnie SOH | odchylenie standardowe | minimum | spełnia wymaganie |
|---|---:|---:|---:|---:|
| STD-90 | 81.4% | 4.09 p.p. | 69.0% | 72% |
| LIFE | 85.3% | 3.32 p.p. | 76.7% | 92% |
| LIFE-ADAPT | 84.9% | 2.98 p.p. | 78.5% | 96% |

## E02. Szybkie ładowanie od 20 do 80% SOC: czas [min] i Tc,max [°C]

| strategia | 0°C | 25°C | 35°C |
|---|---|---|---|
| CC | 22.6 min, 30.7 °C | 22.6 min, 39.4 °C | 22.6 min, 45.1 °C |
| PI | 22.6 min, 32.1 °C | 22.6 min, 35.4 °C | 22.6 min, 36.6 °C |
| GS | 22.6 min, 32.0 °C | 22.6 min, 34.8 °C | 22.6 min, 36.6 °C |
| GS-SAFE | 22.6 min, 30.5 °C | 22.6 min, 32.2 °C | 22.6 min, 36.4 °C |
| STD-90 | 46.7 min, 22.3 °C | 22.7 min, 35.3 °C | 22.7 min, 36.3 °C |
| LIFE | 21.0 min, 31.5 °C | 21.0 min, 32.2 °C | 21.0 min, 32.3 °C |

## E09. Porównanie modelu Simulink ze skryptem MATLAB

Liczba kroków: 1544 i 1544, największa różnica Tc: 5.02e-07 K, największa różnica prądu: 0.00e+00 A
