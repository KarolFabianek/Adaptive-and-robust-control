# BTMS – sterowanie chłodzeniem baterii EV podczas szybkiego ładowania

Autorzy: Karol Fabianek, Paweł Fortuna

Model cieplny pakietu Li-ion 96s50p (dwa węzły: rdzeń i powierzchnia) ładowanego od 25% do 80% SOC
oraz porównanie strategii sterowania chłodzeniem cieczowym:

| Strategia | Opis |
|---|---|
| CC | stałe chłodzenie 20%, bez regulatora |
| PI | regulator PI temperatury rdzenia (Tref = 30°C), anti-windup |
| GS | PI z gain schedulingiem po ρ = Ts − Tcool |
| PI_FF, GS_FF | jak wyżej + feedforward od mocy cieplnej I²R |
| PI_SAFE, GS_SAFE | + nadzór prądu (redukcja prądu powyżej 36,5°C) |
| GS_LIFE | GS_SAFE + limit prądu 210 A |

Cel projektu: SOH ≥ 80% po 10 latach i temperatura rdzenia poniżej 40°C.

## Pliki

| Plik | Co robi |
|---|---|
| `main.m` | 24 symulacje (8 strategii × Ta = 15/25/35°C), SOH po 10 latach, wykresy |
| `params.m` | wszystkie parametry modelu i regulatora |
| `model_step.m` | jeden krok modelu (prąd, regulator, bilans cieplny) |
| `controller_gains.m` | nastawy PI / GS |
| `simulate_charging.m` | symulacja jednej sesji ładowania |
| `aging_model.m` | model starzenia (kalendarzowe + cykliczne) |
| `robustness_test.m` | 162 symulacje z niepewnymi parametrami (R ±15%, Gcs i Gcool ±20%, Ta ±3°C) |
| `stability_analysis.m` | nastawy w funkcji ρ i linearyzacja w punktach równowagi |
| `goal80_analysis.m` | przy jakiej temperaturze i SOC postoju SOH po 10 latach ≥ 80% |
| `gcs_sensitivity.m` | wpływ przewodności rdzeń–powierzchnia Gcs |
| `nasa_validation.m` | dane NASA B0005 – spadek pojemności ogniwa |
| `check_results.m` | testy poprawności (bilans energii, SOC, limit 40°C, zbieżność dt) |
| `btms_model.slx`, `btms_sfun.m`, `run_simulink.m` | model Simulink (Level-2 S-Function) i porównanie z MATLAB-em |

Foldery: `data/` – plik NASA `B0005.mat`, `results/` – wyniki CSV, `figures/` – wykresy,
`docs/` – dokumentacja, `goal80_study/` – osobne studium: co trzeba zmienić, żeby SOH ≥ 80% po 10 latach
także przy średniej temperaturze 35°C (opis w `goal80_study/README.md`).

## Dokumentacja

| Plik | Zawartość |
|---|---|
| `docs/DOKUMENTACJA_BTMS.pdf` | pełna dokumentacja (25 stron): model cieplny i pochodzenie parametrów, regulatory PI/GS, model starzenia i cel 80%, weryfikacja, wyniki, literatura |
| `docs/RAPORT_TECHNICZNY.pdf` | skrócony raport techniczny (2 strony) |

## Uruchomienie

MATLAB R2025b (Simulink potrzebny tylko do `run_simulink.m`).
Ustawić folder `Projekt` jako bieżący i uruchomić `main.m`. Pozostałe skrypty są niezależne
i można je uruchamiać w dowolnej kolejności (każdy zapisuje swoje wyniki do `results/` i `figures/`).

## Najważniejsze wyniki (Ta = 35°C)

| Strategia | Tmax [°C] | Czas [min] | Energia chłodzenia [kWh] | SOH 10 lat, postój 78% | SOH 10 lat, postój 50% |
|---|---|---|---|---|---|
| CC | 50,95 | 20,9 | 0,175 | 65,9% | 70,4% |
| PI | 37,96 | 20,9 | 0,667 | 69,7% | 74,1% |
| GS | 37,90 | 20,9 | 0,685 | 69,8% | 74,2% |
| GS_SAFE | 35,51 | 20,9 | 0,781 | 71,1% | 75,6% |
| GS_LIFE | 35,18 | 28,2 | 0,570 | 72,7% | 77,1% |

- Bez regulatora Tc dochodzi do 51°C; PI i GS trzymają ok. 38°C, z feedforwardem ok. 35,5°C.
- GS = PI przy 35°C (punkt projektowy), lepszy przy 25°C (36,31 vs 36,88°C) i 15°C (34,46 vs 34,87°C).
- Nadzór prądu przy nominalnych parametrach się nie włącza; w 162 testach niepewności Tmax ≤ 38,17°C.
- Cel 80% SOH (GS_LIFE, postój 50% SOC) jest spełniony dla średniej temperatury postoju ≤ 27°C
  (≤ 20°C przy 78% SOC, ≤ 30°C przy 40% SOC). Przy średniej 35°C wychodzi 77,1% – jak dojść do 80%,
  pokazuje `goal80_study/` (np. Tref 26°C, 175 A i chłodzenie pakietu na postoju do 32°C: 80,7%).
- Linearyzacja: 38 z 54 punktów równowagi jest osiągalnych i wszystkie są stabilne.
- NASA B0005: model liniowy Q = a + bN (RMSE testu 0,031 Ah) jest lepszy niż a + b√N (0,083 Ah).

## Założenia i ograniczenia

- Model zastępczy: brak OCV, ograniczeń napięciowych, mapy DCIR i rozrzutu temperatur ogniw.
- Gcs = 1650 W/K (ok. 2,9 K/W na ogniwo 18650) przyjęte z literatury (Bhundiya i in., TFAWS 2018), nie z pomiaru.
- Regulator używa temperatury rdzenia, której w pakiecie się nie mierzy – w praktyce potrzebny byłby obserwator.
- Model starzenia jest scenariuszowy (parametry przyjęte), dane NASA dotyczą jednego ogniwa.
