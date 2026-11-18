# Zmiany po przeglądzie projektu (18.11.2026)

Kopia stanu sprzed zmian: `../_KOPIA_PRZED_PRZEGLADEM_2026-11-18.zip` (bez B0005.mat, który się nie zmienił).
Bazowe wyniki (24 sesje, 162 testy niepewności, SOH w kolumnie `SOH_10y_pct`, cel80) **nie zmieniły się** – zmieniono
tylko to, co było błędne lub mylące, i dodano analizy, których brakowało.

## Błędy naprawione
| Plik | Problem | Poprawka |
|---|---|---|
| `POKAZ.cmd` | `help`/`pomoc` i tryb bez Pythona wołały nieistniejący `KOMENDY.txt` | pomoc idzie do `CLI_BTMS.py help`, awaryjnie `KOMENDY_MATLAB.txt` |
| `CLI_BTMS.py` | `report` otwierał nieistniejący `RAPORT_PROJEKTU.pdf`; `full` nie liczył cel80 | ścieżka `RAPORT_TECHNICZNY.pdf`; `full` uruchamia też `life_goal80.py` i `sensitivity_gcs.py`; nowe komendy `gcs`, `goal80` |
| `WYKRESY_MATLAB.m`, `btms_nasa_validate.m` | `gca.Toolbar.Visible='off'` tworzyło zmienną-strukturę `gca` (nic nie robiło) | `ax=gca; ax.Toolbar.Visible='off'` |
| `btms_sfcn_life80.m` | po osiągnięciu 80% SOC cały stan (też temperatura) był „zamrażany” do końca symulacji | po końcu ładowania I=0, temperatura dalej stygnie; test w `btms_verify_simulink.m` |
| `btms_sfcn_life80.m`, `btms_make_simulink.m` | warunek początkowy 35°C wpisany na sztywno, niezależny od bloku `Tamb` | parametr bloku S-Function = Ta; jedna wartość dla `Tamb` i warunku początkowego; Ts na scope, terminator dla z |
| `btms_goal80.m` | wydruk `-> true` zamiast werdyktu | `SPELNIA (warunkowo)` / `NIE SPELNIA` |
| dokumentacja | „Simulink jeszcze nie uruchomiony”, odwołanie do nieistniejącego `RAPORT_TECHNICZNY.md`, nieaktualne zdania o NASA w `build_report.py` | zaktualizowano |

## Błędy metodyczne poprawione
1. **Linearyzacja / „stabilność”** (`btms_local_jacobian.m`, `run_reference.py`): punkt pracy (Ts=27°C, u=0,3) był przyjęty ręcznie.
   Teraz jest wyznaczany jako rzeczywista równowaga pętli PI (Tc=Tref) dla I = 120/210/300 A. Wynik: przy 35°C
   równowaga istnieje tylko dla ~120 A; dla 210 i 300 A Tref=30°C jest **nieosiągalne** (wymagałoby Ts < Tcool),
   więc pętla musi się nasycić, a analiza liniowa nie ma tam zastosowania. Kolumny `feasible`, `Ts_eq_C`, `u_eq`, `tau_dominant_s`.
2. **Porównanie SOH strategii** (`main_btms.m`, `run_reference.py`): `SOH_10y_pct` mieszało efekt sterowania z założeniem
   postoju (GS_LIFE 50% SOC, reszta 78%). Dodano `SOH_10y_park078_pct` i `SOH_10y_park050_pct`. Przy 35°C z 5,9 pp
   przewagi GS_LIFE nad GS_SAFE ok. 4,4 pp to efekt SOC postoju, a tylko ok. 1,5 pp – limitu 210 A.
3. **NASA** (`btms_nasa_validate.m`, `nasa_validate.py`): model Q=a+b·√N miał RMSE testu 0,083 Ah – gorzej niż prosta
   persystencja (0,075 Ah). Dodano model liniowy Q=a+b·N (RMSE 0,031 Ah) i punkt odniesienia persystencji.
4. **Testy** (`quality_tests.m`, `test_reference.py`): „bilans energii” to tożsamość algebraiczna kroku Eulera (opisano to
   uczciwie). Dodano testy, które coś sprawdzają: zbieżność dt=5 s vs 1 s, zgodność `btms_life` z `btms_life_goal`,
   stabilność w osiągalnych punktach równowagi i brak równowagi przy 300 A.

## Nowa analiza
`btms_sensitivity_gcs.m` / `python/sensitivity_gcs.py` (menu 23, `POKAZ.cmd gcs`): Gcs=165 W/K to ~29 K/W na ogniwo,
literatura podaje ~2–3 K/W. Przy Gcs ≥ ~660 W/K sam PI (bez ograniczania prądu) utrzymuje Tc < 40°C przy 35°C.
Parametrów bazowych **nie zmieniono** – to decyzja autorów.

## Do zrobienia ręcznie (runda 1 – wykonane w rundzie 2)
- `Dokumentacja/RAPORT_TECHNICZNY.pdf` – zdanie „demonstrator nadal wymaga weryfikacji lokalnie” jest nieaktualne;
  warto dopisać wyniki NASA dla modelu liniowego i zastrzeżenie o Gcs.
- Prezentacja – patrz raport z przeglądu (sugestie do slajdów 10, 11, 13, 15, 20, 22).

## Runda 2 (18.11.2026): poprawione wnioski – decyzje autorów
Na podstawie przeglądu przyjęto trzy decyzje: Gcs z literatury, harmonogram GS po Ts − Tcool, aktualizacja prezentacji i raportu.
Uwaga: ta runda **zmienia** wyniki bazowe (24 sesje, SOH, cel80) – poprzednie liczby są w kopii zapasowej.

| Zmiana | Pliki | Skutek |
|---|---|---|
| Gcs 165 → 1650 W/K (2,9 K/W na ogniwo 18650) | `btms_cfg.m`, `run_reference.py` | PI przy 35°C: 47,3 → 38,0°C; CC 51,0°C; nadzór SAFE nominalnie nieaktywny |
| GS po ρ = Ts − Tcool: Kp,Ki = PI·clip(17/ρ; 1; 3) | `btms_gains.m` (nowa sygnatura `(c,strategy,Ts)`), `btms_step.m`, `run_reference.py`, menu `nastawy`, CLI `gains` | GS = PI przy 35°C; −0,4…−0,6 K przy 15–25°C; rozrzut stałej czasowej 900–3560 s → 1230–2560 s |
| SOH: wspólny postój 78% SOC dla wszystkich strategii, kolumna `SOH_10y_park050_pct` dla polityki postoju | `main_btms.m`, `run_reference.py`, CLI `life`, menu `soh` | GS_LIFE nie dostaje już „darmowej” przewagi z postoju |
| Cel 80%: siatka SOC postoju 78/50/40%, progi temperatury, bez narzuconego werdyktu w asercjach | `btms_goal80.m`, `life_goal80.py`, testy | GS_LIFE + 50%: 77,12% (35°C), 81,17% (25°C); próg ≤ 27°C |
| Liniaryzacja: klimaty 15/25/35°C, nastawy GS w Ts* | `btms_local_jacobian.m`, `run_reference.py` | 38/54 punktów osiągalnych, wszystkie stabilne |
| Testy: niezmienniki zamiast zakodowanych wyników | `quality_tests.m`, `test_reference.py` | PI i GS < 40°C przy 35°C; GS = PI w ρ0; GS ≥ PI |
| Wykresy 02/03 czytelne przy nowych wynikach | `run_reference.py` | 02: nominalnie + najgorszy test niepewności; 03: grupowanie identycznych wyników |
| Prezentacja (slajdy 5–8, 10–13, 15–23 i notatki), wykresy na slajdach | `Prezentacja/*.pptx`, `*.pdf` | liczby i wnioski zgodne z kodem |
| Raport techniczny odtworzony | `Dokumentacja/RAPORT_TECHNICZNY.pdf` | nowe liczby, NASA liniowy, zakres weryfikacji |

Weryfikacja rundy 2: MATLAB R2026a + Simulink (wszystkie testy PASS, .slx zapisany w R2025b), Python (PASS), MATLAB = Python (≤ 7·10⁻¹⁴).
