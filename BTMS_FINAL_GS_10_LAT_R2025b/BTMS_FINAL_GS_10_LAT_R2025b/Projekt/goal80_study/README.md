# Studium: SOH ≥ 80% po 10 latach przy średniej temperaturze 35°C

W głównej analizie (`../goal80_analysis.m`) GS_LIFE z postojem przy 50% SOC daje przy średniej
rocznej 35°C tylko 77,1%. Tutaj sprawdzamy, co trzeba zmienić, żeby osiągnąć 80%.

Uruchomienie: ustawić folder `goal80_study` jako bieżący i uruchomić `goal80_study.m`
(skrypt korzysta z funkcji modelu z folderu `Projekt`, którego nie zmienia).

| Plik | Co robi |
|---|---|
| `goal80_study.m` | przegląd ładowania (Tref, limit prądu), postoju (SOC, chłodzenie) i 3 warianty |
| `aging_model_cooled.m` | `aging_model.m` z chłodzeniem pakietu na postoju do temperatury T_cap + energia |

## Wyniki (ładowanie i postój przy średnio 35°C, 300 szybkich ładowań/rok)

**Samo sterowanie ładowaniem nie wystarcza** przy postoju na 50% SOC: najlepszy wynik
to 79,29% (Tref 22°C, limit 150 A, ładowanie 38,6 min, chłodzenie często nasycone).
Starzenie kalendarzowe na postoju (12,3 pp) jest tu większe niż cykliczne (10,6 pp),
więc trzeba zmienić też warunki postoju.

| Wariant | Ładowanie | Postój | Czas ład. | SOH 10 lat | Dodatkowa energia |
|---|---|---|---|---|---|
| W0 punkt wyjścia | Tref 30°C, 210 A | 50% SOC, bez chłodzenia | 28,2 min | 77,12% | – |
| W1 | Tref 24°C, 175 A | 40% SOC, bez chłodzenia | 33,3 min | 80,15% | +56 kWh/rok |
| W2 | bez zmian | 50% SOC, chłodzenie do 28°C | 28,2 min | 80,49% | +492 kWh/rok |
| W3 | Tref 26°C, 175 A | 50% SOC, chłodzenie do 32°C | 33,3 min | 80,72% | +304 kWh/rok |

Dla porównania w roku ładuje się ok. 9 980 kWh, więc W3 kosztuje ok. 3% energii, a W2 ok. 5%.
Tmax podczas ładowania we wszystkich wariantach 35,1–35,2°C (start od 35°C), a w teście niepewności
(81 przypadków jak w `robustness_test.m`) maks. 38,2°C.

Wnioski:
- W1 nie wymaga dodatkowego sprzętu ani energii na postoju, ale zapas ponad 80% jest minimalny
  (0,15 pp), a postój na 40% SOC to ograniczenie dla użytkownika.
- W2 nie zmienia ładowania, ale zużywa najwięcej energii (przy 28°C pakiet jest chłodzony przez cały rok).
- W3 daje największy zapas przy umiarkowanym koszcie – połączenie chłodniejszego ładowania
  i chłodzenia na postoju tylko powyżej 32°C (ok. 8 miesięcy w roku).

## Założenia

- Chłodzenie na postoju: pakiet utrzymywany na T_cap, gdy otoczenie jest cieplejsze;
  ciepło z otoczenia Gamb·(T − T_cap), chiller COP 2,6, postój 20 h/dobę.
- Ładowanie zawsze startuje od temperatury otoczenia (zachowawczo – przy chłodzeniu na postoju
  pakiet byłby na starcie chłodniejszy).
- Model starzenia jest scenariuszowy, więc różnice rzędu 0,1–0,5 pp nie są istotne;
  wynik pokazuje kierunek i koszt zmian, a nie gwarancję.
