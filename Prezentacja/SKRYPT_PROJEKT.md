# Skrypt wystąpienia: prezentacja projektu

**Sterowanie ładowaniem i temperaturą baterii pojazdu elektrycznego z ograniczeniem starzenia**

Karol Fabianek, Paweł Fortuna. Sterowanie adaptacyjne i odporne, Politechnika Opolska, WEAiI.

Plik prezentacji: `BTMS_PROJEKT_FABIANEK_FORTUNA.pptx`, 29 slajdów, czas wystąpienia około 17 min przy tempie 130 słów na minutę. Ten sam tekst jest w notatkach prelegenta w pliku .pptx (widok prezentera).

## Podział na osoby

| Osoba | Slajdy | Liczba slajdów | Czas mówienia |
|---|---|---:|---:|
| Karol Fabianek | 1-14, 27-29 | 17 | około 10 min |
| Paweł Fortuna | 15-26 | 12 | około 7 min |

## Kolejność wystąpienia

- slajdy 1-14: Karol Fabianek
- slajdy 15-26: Paweł Fortuna
- slajdy 27-29: Karol Fabianek

## Tekst slajd po slajdzie

### Slajd 1. Sterowanie ładowaniem i temperaturą baterii pojazdu elektrycznego z ograniczeniem starzenia

**Mówi: Karol Fabianek**

Dzień dobry. Nazywam się Karol Fabianek, a to Paweł Fortuna. Przedstawiamy sterowanie ładowaniem i temperaturą baterii pojazdu elektrycznego z ograniczeniem starzenia. Postawiliśmy pytanie: jak sterować prądem, napięciem, stanem naładowania i temperaturą pakietu, aby po dziesięciu latach eksploatacji bateria zachowała co najmniej osiemdziesiąt procent pojemności? Odpowiedź opiera się na modelu elektryczno-cieplnym pakietu, modelu starzenia i trzech pętlach sterowania. Ja omówię cel, model i szybkie ładowanie, a Paweł regulator, wyniki dziesięcioletnie i odporność.

### Slajd 2. Wymagania projektowe

**Mówi: Karol Fabianek**

Założenia są cztery. Pierwsze: SOH, czyli pojemność względna, ma po dziesięciu latach wynosić co najmniej osiemdziesiąt procent. To ostrzejsze niż typowa gwarancja producentów, która mówi o siedemdziesięciu procentach po ośmiu latach. Drugie: walczymy o pojemność, więc rozbijamy jej utratę na trzy mechanizmy. Trzecie: sterujemy parametrami ładowania, prądem, napięciem fazy CV, oknem SOC, momentem ładowania i temperaturą przy ładowaniu. Czwarte: pilnujemy nominalnej temperatury, czyli rdzeń poniżej czterdziestu stopni. Obiektem jest pakiet 96s50p, 345,6 V, 175 Ah, około 60 kWh.

### Slajd 3. Najważniejsze wyniki

**Mówi: Karol Fabianek**

Zacznę od wyników. W gorącym klimacie, czyli w Dubaju, typowy BMS ładujący do stu procent kończy dziesięć lat z 69,2 procent SOH. Nasza strategia z pętlą adaptacyjną osiąga 80,8 procent. W Madrycie sama zmiana sposobu ładowania podnosi wynik z 79,1 do 85,2 procent. Przy zerze stopni szybkie ładowanie skraca się z 47 do 21 minut i jest bezpieczne dla anody. W analizie odporności cel spełnia 72 procent losowych pakietów z typowym BMS i 96 procent z naszą pętlą. Najważniejszy wniosek: o trwałości bardziej niż prąd szybkiego ładowania decyduje to, jak długo i w jakiej temperaturze bateria stoi naładowana.

### Slajd 4. Zjawiska uwzględnione w modelu

**Mówi: Karol Fabianek**

Ten slajd zestawia zjawiska, które uwzględnia model. Dynamikę elektryczną opisuje krzywa napięcia obwodu otwartego i obwód RC, dzięki czemu można modelować pełne ładowanie CC-CV z ograniczeniem 4,2 V na ogniwo. Rezystancja zależy od temperatury według prawa Arrheniusa, a jej parametry można identyfikować na bieżąco metodą RLS. Temperatury rdzenia nie da się zmierzyć, więc estymuje ją obserwator. Stan zdrowia zmienia pojemność i rezystancję, a samo starzenie opisuje model półempiryczny z trzema składowymi.

### Slajd 5. Trzy pętle sterowania w trzech skalach czasu

**Mówi: Karol Fabianek**

Sterowanie ma trzy warstwy o różnych skalach czasu. Pętla szybka działa co sekundę: regulator PI chłodzenia z harmonogramem nastaw, feedforward od strat cieplnych, anti-windup, warstwowy limit prądu i obserwator. Pętla średnia działa na poziomie sesji i doby: ustala okno SOC, moment ładowania w domu i podgrzewanie przed szybkim ładowaniem. Pętla wolna działa raz w miesiącu: estymator RLS ocenia stan zdrowia, a regulator PI porównuje go z planem i ustawia jeden parametr, poziom ochrony lambda. Rozdzielenie skal czasu upraszcza syntezę, bo każda pętla widzi szybsze jako już ustalone.

### Slajd 6. Model elektryczny 1RC i dwuwęzłowy model cieplny

**Mówi: Karol Fabianek**

Model pakietu to obwód zastępczy z jedną gałęzią RC i dwuwęzłowy model cieplny: rdzeń i powierzchnia. Gałąź RC dyskretyzujemy dokładnie, a równania cieplne całkujemy niejawną metodą Eulera. To ważny szczegół numeryczny: metoda niejawna jest stabilna przy każdym kroku, więc postój liczymy z krokiem sześćdziesięciu sekund, a dziesięć lat eksploatacji w kilka sekund. Wykres pokazuje rezystancję w funkcji temperatury. W zerze stopni rezystancja ogniwa rośnie ponad dwukrotnie, a rezystancja anody, która decyduje o litowaniu, około pięciokrotnie. Linia przerywana to uproszczony model liniowy, który w zimnie mocno zaniżał rezystancję.

### Slajd 7. Anoda pracuje tylko około 100 mV nad potencjałem litu

**Mówi: Karol Fabianek**

To pierwsza ciekawostka. Anoda grafitowa przy wysokim SOC pracuje tylko około stu miliwoltów nad potencjałem metalicznego litu. Podczas ładowania spadek napięcia na rezystancji anody obniża ten potencjał. Gdy zejdzie poniżej zera, lit zamiast wnikać w grafit osadza się na jego powierzchni. Część tego litu traci się bezpowrotnie, a w skrajnych przypadkach rosną dendryty. Mapa pokazuje największy bezpieczny prąd. Przy 25 stopniach to 1,85C, a przy zerze tylko 0,29C. Wniosek praktyczny: zimą nawet wolne ładowanie z wallboxa do stu procent może litować anodę.

### Slajd 8. Postój naładowanej baterii zużywa ją bardziej niż jazda

**Mówi: Karol Fabianek**

Model starzenia ma trzy składowe. Kalendarzowa rośnie jak czas do potęgi 0,75 i zależy od temperatury oraz napięcia, czyli SOC. Cykliczna rośnie jak pierwiastek z liczby cykli i zależy od temperatury, prądu i zakresu SOC. Trzecia to litowanie. Różne warunki sumujemy metodą czasu zastępczego, która poprawnie łączy lato z zimą i postój z jazdą. Mapa pokazuje samo starzenie kalendarzowe. Ciekawostka: bateria stojąca przy stu procentach SOC starzeje się około 2,2 raza szybciej niż przy pięćdziesięciu, a każde dziesięć stopni podwaja tempo. To najtańsze pokrętła trwałości, bo nie wymagają mocniejszego chłodzenia.

### Slajd 9. Zużycie baterii ma minimum w funkcji temperatury ładowania

**Mówi: Karol Fabianek**

Druga ciekawostka z modelu: istnieje optymalna temperatura szybkiego ładowania. Wykres pokazuje zużycie baterii na jedno ładowanie w funkcji temperatury ogniwa. Lewe ramię tworzy litowanie, które rośnie w zimnie. Prawe ramię to wzrost warstwy SEI, który przyspiesza w cieple. Optimum przesuwa się z prądem: dla 0,5C to około 5 stopni, dla 1C 14, a dla 1,71C 22 stopni. Ten kształt V jakościowo potwierdzają badania post-mortem Waldmanna z 2014 roku. Wniosek: im szybciej ładujemy, tym cieplejsza powinna być bateria.

### Slajd 10. Warstwowe ograniczenie prądu ładowania

**Mówi: Karol Fabianek**

Prąd ładowania wybieramy jako minimum sześciu limitów. Limit bazowy to możliwości stacji lub wallboxa. Profil SOC redukuje prąd powyżej 70 procent. Nadzór termiczny redukuje prąd między 36,5 a 39,5 stopnia. Tablica typowego BMS ogranicza prąd na zimno. Faza CV pilnuje napięcia 4,2 V. Nowością jest limit anody: największy prąd, przy którym potencjał anody zostaje co najmniej piętnaście miliwoltów nad zerem. Nie pochodzi on z tablicy, tylko z modelu, więc sam maleje w zimnie, przy wysokim SOC i gdy bateria się starzeje.

### Slajd 11. Podgrzewanie w drodze skraca ładowanie ponad dwukrotnie

**Mówi: Karol Fabianek**

Pierwszy scenariusz: zero stopni, kierowca jedzie autostradą do szybkiej ładowarki. Typowy BMS ładuje zimną baterię według tablicy, więc trwa to 46,7 minuty. Przy wysokim SOC anoda i tak lekko się lituje, 47 ppm. Strategia LIFE wie z nawigacji, że zbliża się ładowarka, i przez ostatnie dwadzieścia minut jazdy grzeje pakiet. Zużywa na to 1,27 kWh, czyli około dwóch procent pojemności. Potem ładuje się w 21,0 minut bez litowania. Dla porównania: ładowanie bez żadnej ochrony anody zużywa baterię około 38 razy bardziej.

### Slajd 12. Chłodzenie wstępne i regulator GS-PI ze sprzężeniem w przód

**Mówi: Karol Fabianek**

Drugi scenariusz to upał, 35 stopni. Bez regulatora rdzeń osiąga 45,1 stopnia, czyli przekracza kryterium. Typowy BMS z regulatorem PI dochodzi do 36,3. LIFE chłodzi pakiet już w trasie, dojeżdża z 28,1 stopniami i kończy ładowanie na 32,3. Ładuje się przy tym szybciej, 21,0 zamiast 22,7 minuty. Powodem jest brak sztywnego profilu SOC: limit anody pokazuje, że w tej temperaturze pełny prąd jest bezpieczny aż do końca.

### Slajd 13. Czas ładowania i zużycie baterii dla 6 strategii

**Mówi: Karol Fabianek**

Ten slajd zestawia sześć strategii w sześciu temperaturach otoczenia. Po lewej czas ładowania, po prawej zużycie baterii na sesję w skali logarytmicznej. Bez ochrony anody zużycie w zimnie rośnie o dwa rzędy wielkości. Typowa tablica BMS chroni, ale kosztem czasu. Przy minus dziesięciu stopniach nie kończy ładowania nawet w ciągu dwóch godzin, dlatego jej punkt jest obcięty na wartości 120 minut. Strategia LIFE utrzymuje około 21 minut w całym zakresie od minus dziesięciu do czterdziestu stopni.

### Slajd 14. Zimna bateria nagrzewa się sama, ale wymaga limitu anody

**Mówi: Karol Fabianek**

Ostatni slajd mojej części odpowiada na pytanie, co się dzieje, gdy nie zdążymy podgrzać baterii. Jeśli ma ona 5 stopni, ładowanie bez limitu anody kosztuje 2247 ppm pojemności, a z limitem tylko 36 ppm. Ładowanie trwa wtedy o 8,4 minuty dłużej. Ciekawostka: zimna bateria grzeje się sama prądem ładowania, około półtora stopnia na minutę, więc limit działa głównie przez pierwsze minuty. Powyżej 33 stopni hamuje z kolei nadzór termiczny. Oddaję głos Pawłowi.

### Slajd 15. GS utrzymuje stałą pulsację odcięcia pętli chłodzenia

**Mówi: Paweł Fortuna** (zmiana prowadzącego)

Dziękuję. Zacznę od analizy regulatora chłodzenia, czyli serca układu. Wzmocnienie obiektu, ile ciepła odbiera chłodzenie na jednostkę sterowania, jest proporcjonalne do różnicy temperatur rho między powierzchnią a cieczą. Zlinearyzowaliśmy pętlę w 33 punktach pracy i policzyliśmy charakterystyki częstotliwościowe bez Control System Toolbox. Przy stałych nastawach pulsacja odcięcia spada razem z rho: przy 6 kelwinach PI ma 0,88 miliradiana na sekundę, czyli trzy razy mniej niż w punkcie projektowym. GS utrzymuje 2,61, tyle samo co przy 17 kelwinach. Zapas fazy wynosi około 90 stopni w całym zakresie.

### Slajd 16. Odpowiedź na zakłócenie i symulacja nieliniowa

**Mówi: Paweł Fortuna**

Ten sam efekt widać w dziedzinie czasu. Po lewej odpowiedź temperatury rdzenia na skok strat cieplnych o jeden kilowat. W chłodnym punkcie pracy, przy rho równym 5 kelwinów, PI pozwala na prawie dwa i pół kelwina przyrostu, a GS na około 1,3. Po prawej czas powrotu: dla PI rośnie do ponad dwóch godzin, dla GS zostaje około 80 minut. W tabeli wynik symulacji nieliniowej. Przy 25 stopniach GS trzyma rdzeń o 0,58 kelwina chłodniej. W punkcie projektowym, przy 35 stopniach, różnica wynosi tylko 0,25 kelwina. Tak właśnie powinien zachowywać się harmonogram nastaw.

### Slajd 17. Estymator RLS śledzi parametry ogniwa

**Mówi: Paweł Fortuna**

Gain scheduling to adaptacja w torze otwartym. Drugą formą adaptacji jest identyfikacja online. Model ARX z trzema parametrami jest dokładny dla obwodu RC, a estymator RLS liczy je w każdej sekundzie z prądu i napięcia. W trzydziestej minucie testu rezystancje rosną skokowo o trzydzieści procent, co odpowiada spadkowi temperatury albo starzeniu. Estymator z zapominaniem dochodzi do 23,2 miliomów przy prawdziwej wartości 23,3. Bez zapominania zostaje na 19,9, bo uśrednia całą historię. Wniosek: estymator bez zapominania nigdy nie zauważy starzenia baterii.

### Slajd 18. Metoda wieloskalowa: dwa dni reprezentują miesiąc

**Mówi: Paweł Fortuna**

Przechodzę do symulacji dziesięciu lat. Nie da się liczyć dziesięciu lat z krokiem jednej sekundy, dlatego stosujemy metodę wieloskalową. W każdym miesiącu symulujemy dwa reprezentatywne dni. Pierwszy to dzień roboczy: dwa dojazdy po pół godziny, praca bez ładowarki i wieczór w domu z wallboxem. Drugi to dzień w trasie: 150 kilometrów autostradą, szybkie ładowanie i powrót. Stres starzenia mnożymy przez liczbę dni w miesiącu, aktualizujemy SOH, a nowe SOH zmienia pojemność i rezystancję w kolejnym miesiącu. Każda strategia przejeżdża dokładnie ten sam dystans. Porównujemy trzy klimaty: Opole, Madryt i Dubaj.

### Slajd 19. Stan zdrowia baterii: 4 strategie w 3 klimatach

**Mówi: Paweł Fortuna**

Oto główny wynik projektu. W Opolu cel spełnia każda strategia, bo chłodny klimat sam chroni baterię. W Madrycie odpada ładowanie do stu procent: 79,1 procent. Już ograniczenie do dziewięćdziesięciu daje 82,3, a LIFE 85,2 procent. W Dubaju typowy BMS kończy z 69,2 procent, wersja z limitem dziewięćdziesięciu procent z 72,5, LIFE z 78,3. Dopiero pętla adaptacyjna utrzymuje 80,8 procent. Linia kropkowana to trajektoria odniesienia, którą śledzi regulator nadrzędny.

### Slajd 20. Składniki utraty pojemności po 10 latach

**Mówi: Paweł Fortuna**

Skąd się bierze utrata pojemności? Pomarańczowa część to starzenie kalendarzowe, niebieska cykliczne, czerwona litowanie. W gorącym klimacie dominuje starzenie kalendarzowe: w Dubaju przy ładowaniu do stu procent to 19,8 punktu procentowego. Pętla adaptacyjna zmniejsza je do 11,0. W zimnym klimacie problemem jest litowanie: w Opolu typowy BMS traci 3,8 punktu przez zimowe ładowanie do stu procent. Część cykliczna jest prawie stała, bo zależy głównie od przejechanych kilometrów. Strategia LIFE nie lituje anody w żadnym klimacie.

### Slajd 21. Poziom ochrony λ rośnie tylko wtedy, gdy jest to potrzebne

**Mówi: Paweł Fortuna**

Tak działa pętla adaptacyjna. Lewy wykres to poziom ochrony lambda. W Opolu i Madrycie bateria starzeje się wolniej niż plan, więc lambda spada do zera, a kierowca może ładować do 85 procent. Pętla oddaje nadwyżkę zdrowia jako komfort. W Dubaju uchyb staje się ujemny już w drugim roku, lambda rośnie i po około czterech latach osiąga jeden. To klasyczne nasycenie elementu wykonawczego: regulator robi wszystko, co może, i dlatego cel z zapasem, czyli 82 procent, jest nieosiągalny. Granica 80 procent zostaje jednak dotrzymana.

### Slajd 22. Energia, zasięg i czas ładowania

**Mówi: Paweł Fortuna**

Uczciwy bilans kosztów. Lewy wykres to energia zarządzania termicznego. W Dubaju pętla adaptacyjna zużywa 396 kWh rocznie, głównie na chłodzenie zaparkowanego auta podłączonego do sieci. To około dziesięciu procent energii jazdy. Środkowy wykres pokazuje średni SOC, czyli zapas zasięgu: w Dubaju spada do około sześćdziesięciu procent. Prawy pokazuje średni czas szybkiego ładowania w trasie: 34 minuty, bo pętla obniża prąd. Ten czas zależy też od SOC przy przyjeździe. W klimacie umiarkowanym koszty są pomijalne.

### Slajd 23. Sprzężenie od SOH kompensuje błędy modelu starzenia

**Mówi: Paweł Fortuna**

To najważniejszy wynik z punktu widzenia sterowania odpornego. Model starzenia jest niepewny, więc losujemy pięćdziesiąt pakietów. Zmieniamy współczynniki starzenia, rezystancje, przewodności cieplne i klimat. Losujemy nawet kształt krzywej degradacji. Regulator zna tylko wartości nominalne. Typowy BMS spełnia cel w 72 procentach przypadków, LIFE w 92, a LIFE-ADAPT w 96 procentach. Odchylenie standardowe maleje z 4,1 do 3,0 punktu procentowego, a najgorszy przypadek rośnie z 69,0 do 78,5 procent. Sprzężenie zwrotne od zmierzonego SOH kompensuje błędy modelu.

### Slajd 24. NASA B0005: degradacja bliższa liniowej niż pierwiastkowej

**Mówi: Paweł Fortuna**

Model porównaliśmy z prawdziwymi danymi NASA dla ogniwa B0005. Dopasowujemy model potęgowy na siedemdziesięciu procentach cykli i prognozujemy pozostałe trzydzieści, tak jak przy identyfikacji. Model liniowy ma błąd testowy 32 mAh, pierwiastkowy 81 mAh. Ciekawe, że najlepiej dopasowany wykładnik 1,54 prognozuje najgorzej, z błędem 138 mAh, to klasyczne przeuczenie. Widać też skoki pojemności po przerwach w cyklowaniu. Prawdziwe ogniwo nie musi więc trzymać się założonego kształtu. Dlatego Monte Carlo obejmuje oba warianty, a pętla adaptacyjna reaguje na pomiar, a nie na model.

### Slajd 25. Niezależny model blokowy potwierdza wyniki

**Mówi: Paweł Fortuna**

Wyniki sprawdziliśmy drugą, niezależną implementacją w postaci modelu blokowego w Simulinku. Harmonogram nastaw jest w nim tablicą k od rho, a stany przechowują elementy opóźnienia. Sesja przy zerze stopni trwa w obu implementacjach 1544 kroków, a największa różnica temperatury rdzenia wynosi 5e-7 kelwina. Wynika ona wyłącznie z interpolacji tablicy harmonogramu. Wyniki nie zależą więc od sposobu implementacji algorytmu.

### Slajd 26. Ograniczenia modelu i sposób ich weryfikacji

**Mówi: Paweł Fortuna**

Krytyczna ocena. Współczynniki starzenia pochodzą z literatury, a nie z badań tego konkretnego ogniwa. Pakiet modelujemy jako jedno uśrednione ogniwo, bez rozrzutu parametrów. Litowanie opisujemy modelem progowym, a nie pełnym modelem elektrochemicznym. Klimat to sinusoida bez nasłonecznienia. Jak się przed tym bronimy? Model przechodzi weryfikację numeryczną: bilans energii i ładunku, zbieżność względem kroku, ograniczenie napięcia i zbieżność obserwatora. Do tego Monte Carlo z dwoma kształtami degradacji, dane NASA i przede wszystkim pętla reagująca na zmierzone SOH. Liczby służą do porównania strategii, a wartości bezwzględne wymagają kalibracji na konkretnym ogniwie. Oddaję głos Karolowi.

### Slajd 27. Wnioski

**Mówi: Karol Fabianek** (zmiana prowadzącego)

Podsumujmy w sześciu punktach. Po pierwsze, dominujący mechanizm starzenia zależy od klimatu: w gorącym jest to starzenie kalendarzowe, w zimnym litowanie anody. Po drugie, sposób ładowania ma większy wpływ niż samo chłodzenie: niższy docelowy SOC i ładowanie kończone przed wyjazdem podnoszą SOH w Madrycie o ponad sześć punktów procentowych. Po trzecie, temperatura szybkiego ładowania ma optimum, a podgrzanie skraca ładowanie zimą ponad dwukrotnie bez litowania. Po czwarte, gain scheduling utrzymuje stałą dynamikę pętli chłodzenia w całym zakresie pracy. Po piąte, sprzężenie od zmierzonego SOH czyni wynik odpornym na błędy modelu starzenia. Po szóste, w gorącym klimacie pętla osiąga nasycenie, więc wymaganie 80 procent jest spełnione, ale bez zapasu i kosztem energii chłodzenia.

### Slajd 28. Bibliografia

**Mówi: Karol Fabianek**

Na slajdzie jest literatura, na której oparliśmy model i metody. Najważniejsze pozycje to model starzenia Schmalstiega, badania temperaturowe Waldmanna, model anody Doyle'a, a od strony sterowania prace Rugha i Shammy o gain schedulingu oraz podręcznik Åströma i Wittenmarka.

### Slajd 29. Dziękujemy za uwagę

**Mówi: Karol Fabianek**

Dziękujemy za uwagę. Chętnie odpowiemy na pytania.

