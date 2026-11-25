# Podsumowanie wyników (wygenerowane przez run_all.m, 2026-11-25 20:48, MATLAB R2026b)

Testy poprawności: wszystkie zaliczone

## E05 – SOH po 10 latach [%]

| klimat | STD_100 | STD_90 | LIFE | LIFE_ADAPT |
|---|---:|---:|---:|---:|
| opole | 81.1 | 85.0 | 87.9 | 87.6 |
| madryt | 79.1 | 82.3 | 85.2 | 84.6 |
| dubaj | 69.2 | 72.5 | 78.3 | 80.8 |

## E06 – Monte Carlo (Madryt): odsetek pakietów z SOH >= 80%

| strategia | średnie SOH | odch. std. | min | spełnia cel |
|---|---:|---:|---:|---:|
| STD_90 | 81.4% | 4.09 p.p. | 69.0% | 72% |
| LIFE | 85.3% | 3.32 p.p. | 76.7% | 92% |
| LIFE_ADAPT | 84.9% | 2.98 p.p. | 78.5% | 96% |

## E02 – szybkie ładowanie 20 -> 80% (czas [min] / Tc_max [°C])

| strategia | 0°C | 25°C | 35°C |
|---|---|---|---|
| CC | 22.6 / 30.7 | 22.6 / 39.4 | 22.6 / 45.1 |
| PI | 22.6 / 32.1 | 22.6 / 35.4 | 22.6 / 36.6 |
| GS | 22.6 / 32.0 | 22.6 / 34.8 | 22.6 / 36.6 |
| GS_SAFE | 22.6 / 30.5 | 22.6 / 32.2 | 22.6 / 36.4 |
| STD_90 | 46.7 / 22.3 | 22.7 / 35.3 | 22.7 / 36.3 |
| LIFE | 21.0 / 31.5 | 21.0 / 32.2 | 21.0 / 32.3 |

## E09 – Simulink vs MATLAB

kroki: 1544 / 1544, maks. |dTc| = 5.02e-07 K, maks. |dI| = 0.00e+00 A
