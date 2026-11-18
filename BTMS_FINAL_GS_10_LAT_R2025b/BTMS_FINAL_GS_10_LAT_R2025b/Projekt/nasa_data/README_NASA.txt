NASA Ames PCoE - plik B0005.mat dostarczony przez uzytkownika.
Rozpoznano 168 cykli rozladowania (MATLAB i Python - zgodnie).
Podzial chronologiczny: 117 uczenie + 51 test.
RMSE test: Q=a+b*sqrt(N) = 0.0827 Ah | Q=a+b*N = 0.0308 Ah | persystencja = 0.0754 Ah.
Model sqrt(N) jest gorszy od prostej persystencji (zbyt optymistyczny w ekstrapolacji);
zanik pojemnosci B0005 jest w przyblizeniu liniowy w liczbie cykli.
MATLAB: BTMS_MENU('nasa'). Python: python/nasa_validate.py nasa_data/B0005.mat
To dane ogniwa NASA, nie baterii 96s50p i NIE waliduja modelu termicznego BTMS
ani wspolczynnikow k_cal, k_cyc modelu SOH.
