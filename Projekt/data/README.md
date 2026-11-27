# Dane pomiarowe

## B0005.mat

Ogniwo litowo-jonowe 18650 o pojemności znamionowej 2 Ah z zestawu danych starzeniowych NASA Ames Prognostics Center of Excellence.

| Parametr | Wartość |
|---|---|
| Temperatura badania | 24°C |
| Ładowanie | CC-CV, 1,5 A do 4,2 V, koniec przy 20 mA |
| Rozładowanie | 2 A do 2,7 V |
| Liczba cykli rozładowania | 168 |
| Zmienna w pliku | `B0005.cycle`, pole `type` (`charge`, `discharge`, `impedance`), pole `data` z pomiarami |

Eksperyment E08 (`experiments/exp08_nasa_validation.m`) odczytuje pojemność z każdego cyklu rozładowania (`data.Capacity`) i porównuje kształt krzywej degradacji z modelami potęgowymi.

Źródło: B. Saha, K. Goebel, *Battery Data Set*, NASA Ames Prognostics Data Repository, NASA Ames Research Center, Moffett Field, CA, 2007.
