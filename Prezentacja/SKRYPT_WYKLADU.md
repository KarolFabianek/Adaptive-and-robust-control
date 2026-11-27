# Skrypt wykładu

**Zarządzanie termiczne baterią pojazdu elektrycznego z zastosowaniem Gain Scheduling**

Karol Fabianek, Paweł Fortuna. Sterowanie adaptacyjne i odporne, Politechnika Opolska, WEAiI.

Prezentacja: `BTMS_WYKLAD_FABIANEK_FORTUNA.pptx`, 46 slajdów. Mowa trwa około 30 min przy tempie 130 słów na minutę, 4 pokazy w MATLAB-ie około 10 min, razem z przejściami między slajdami około 45 min. Ten sam tekst jest w notatkach prelegenta w pliku .pptx.

## Podział na osoby

| Osoba | Slajdy | Liczba slajdów | Czas mówienia |
|---|---|---:|---:|
| Karol Fabianek | 1-14, 25-31, 40-43, 46 | 26 | około 16 min |
| Paweł Fortuna | 15-24, 32-39, 44-45 | 20 | około 14 min |

## Przebieg wykładu

| Slajdy | Część | Prowadzi | Pokaz w MATLAB-ie |
|---|---|---|---|
| 1-4 | Wprowadzenie | Karol Fabianek | nie |
| 5-14 | Model obiektu | Karol Fabianek | nie |
| 15-24 | Sterowanie | Paweł Fortuna | po slajdzie 20 |
| 25-31 | Szybkie ładowanie | Karol Fabianek | po slajdzie 29 |
| 32-39 | Adaptacja i trwałość | Paweł Fortuna | po slajdzie 38 |
| 40-43 | Odporność i walidacja | Karol Fabianek | po slajdzie 42 |
| 44-45 | Podsumowanie | Paweł Fortuna | nie |
| 46 | Podsumowanie | Karol Fabianek | nie |

## Tekst slajd po slajdzie

## Część: Wprowadzenie

### Slajd 1. Zarządzanie termiczne baterią pojazdu elektrycznego z zastosowaniem Gain Scheduling

**Mówi: Karol Fabianek**

Dzień dobry. Nazywam się Karol Fabianek, a to Paweł Fortuna. Tematem wykładu jest zarządzanie termiczne baterią pojazdu elektrycznego z zastosowaniem gain schedulingu, czyli harmonogramowania nastaw regulatora. Rozszerzamy go o sterowanie ładowaniem z ograniczeniem starzenia. Pytanie przewodnie brzmi: jak sterować prądem, napięciem, stanem naładowania i temperaturą pakietu, aby po dziesięciu latach eksploatacji bateria zachowała co najmniej osiemdziesiąt procent pojemności? Teorię ilustrujemy wynikami symulacji i krótkimi pokazami w MATLAB-ie.

### Slajd 2. Od modelu pakietu do trwałości w horyzoncie 10 lat

**Mówi: Karol Fabianek**

Wykład ma sześć części. Najpierw problem i cel. Potem model obiektu: elektryczny, cieplny, model anody i model starzenia. W trzeciej części Paweł omówi regulator z harmonogramem nastaw. Następnie pokażę, jak strategie ładowania zachowują się przy niskiej i wysokiej temperaturze. Piąta część to adaptacja: identyfikacja parametrów i nadrzędna pętla stanu zdrowia. Na końcu sprawdzimy odporność wyników na niepewność modelu i sformułujemy wnioski.

### Slajd 3. Dlaczego bateria EV potrzebuje BTMS?

**Mówi: Karol Fabianek**

Dlaczego bateria potrzebuje układu BTMS? Szybkie ładowanie to duży prąd, a straty Joule'a rosną z kwadratem prądu. Temperatura decyduje o bezpieczeństwie i o tempie starzenia. Chłodzenie nie jest darmowe, bo pompa i sprężarka pobierają energię. Ograniczenie prądu zmniejsza ciepło, ale wydłuża ładowanie. Schemat pokazuje dwa kanały sterowania: sterownik zmienia prąd ładowarki i wydajność chłodzenia. Sterownik szuka więc kompromisu między czasem ładowania, temperaturą, energią chłodzenia i trwałością.

### Slajd 4. Wymagania dla układu sterowania

**Mówi: Karol Fabianek**

Założenia są cztery. Pierwsze: SOH, czyli pojemność względna, ma po dziesięciu latach wynosić co najmniej osiemdziesiąt procent. To ostrzejsze niż typowa gwarancja producentów, która mówi o siedemdziesięciu procentach po ośmiu latach. Drugie: walczymy o pojemność, więc rozbijamy jej utratę na trzy mechanizmy. Trzecie: sterujemy parametrami ładowania, prądem, napięciem fazy CV, oknem SOC, momentem ładowania i temperaturą przy ładowaniu. Czwarte: pilnujemy nominalnej temperatury, czyli rdzeń poniżej czterdziestu stopni. Obiektem jest pakiet 96s50p, 345,6 V, 175 Ah, około 60 kWh.

## Część: Model obiektu

### Slajd 5. Pakiet referencyjny Li-ion 96s50p

**Mówi: Karol Fabianek**

Obiektem jest referencyjny pakiet 96s50p. Pięćdziesiąt ogniw łączymy równolegle w sekcję, a dziewięćdziesiąt sześć sekcji szeregowo, razem 4800 ogniw typu 18650. Daje to 345,6 V, 175 Ah, 60,48 kWh i rezystancję 53,76 miliomów. Zasada jest prosta: połączenie szeregowe zwiększa napięcie i rezystancję, a równoległe pojemność i zmniejsza rezystancję. Parametry ogniwa są założeniem projektowym, a nie danymi konkretnego producenta. Rezystancję ogniwa, 28 miliomów, dzielimy na część omową, 18 miliomów, i polaryzacyjną z gałęzią RC o stałej czasowej 40 sekund. Model pakietu traktujemy jak jedno zastępcze ogniwo, którego parametry przeskalowano przez liczbę gałęzi szeregowych i równoległych. To uproszczenie omówimy przy ograniczeniach modelu.

### Slajd 6. Zjawiska uwzględnione w modelu

**Mówi: Karol Fabianek**

Ten slajd zestawia zjawiska, które uwzględnia model. Dynamikę elektryczną opisuje krzywa napięcia obwodu otwartego i obwód RC, dzięki czemu można modelować pełne ładowanie CC-CV z ograniczeniem 4,2 V na ogniwo. Rezystancja zależy od temperatury według prawa Arrheniusa, a jej parametry można identyfikować na bieżąco metodą RLS. Temperatury rdzenia nie da się zmierzyć, więc estymuje ją obserwator. Stan zdrowia zmienia pojemność i rezystancję, a samo starzenie opisuje model półempiryczny z trzema składowymi.

### Slajd 7. Model 1RC, krzywa OCV i ładowanie CC-CV

**Mówi: Karol Fabianek**

Model elektryczny to obwód zastępczy z jedną gałęzią RC. Napięcie na zaciskach to suma napięcia obwodu otwartego, napięcia na gałęzi RC i spadku na rezystancji omowej. Gałąź RC dyskretyzujemy dokładnie, a stan naładowania liczymy z całki prądu odniesionej do aktualnej pojemności, która maleje wraz ze starzeniem. Ładowanie odbywa się w schemacie CC-CV: najpierw stałym prądem do 300 amperów, czyli około 1,7C, a po osiągnięciu 4,2 V na ogniwo stałym napięciem, aż prąd spadnie do C/20. Wykresy pokazują krzywą napięcia obwodu otwartego i potencjał anody. Ten sam stan naładowania wyznacza więc napięcie ogniwa i bezpieczny prąd ładowania.

### Slajd 8. Model dwuwęzłowy: rdzeń i powierzchnia

**Mówi: Karol Fabianek**

Model cieplny ma dwa węzły: rdzeń i powierzchnię. Ciepło powstaje w rdzeniu jako straty I kwadrat R. Przez przewodność między rdzeniem a powierzchnią płynie do powierzchni, a tam odbiera je otoczenie i układ chłodzenia. Pojemność cieplną pakietu dzielimy: 76 procent na rdzeń i 24 procent na powierzchnię. To ważne dla sterowania, bo chłodzenie działa na powierzchnię, a ciepło powstaje w rdzeniu. Przy 300 amperach rdzeń jest około 3 kelwiny cieplejszy od powierzchni. Równania całkujemy niejawną metodą Eulera, która jest stabilna przy każdym kroku. Z punktu widzenia sterowania jest to obiekt drugiego rzędu z dwoma biegunami: szybkim, o stałej czasowej około 23 sekund, związanym z wymianą ciepła między rdzeniem a powierzchnią, i wolnym, rzędu dwóch godzin, związanym ze stygnięciem pakietu do otoczenia.

### Slajd 9. Straty rosną z kwadratem prądu, rezystancja rośnie w zimnie

**Mówi: Karol Fabianek**

Źródłem ciepła są straty. Lewy wykres pokazuje, że rosną z kwadratem prądu: dwa razy większy prąd to około cztery razy więcej ciepła. Przy 300 amperach to około 4,8 kilowata. Jeśli ograniczymy prąd do 210 amperów, ciepła jest o około 51 procent mniej. Prawy wykres pokazuje rezystancję w funkcji temperatury. Opisujemy ją prawem Arrheniusa, więc w zerze stopni jest ponad dwukrotnie większa niż w 25 stopniach. Linia przerywana to prosty model liniowy, który w zimnie wyraźnie ją zaniża.

### Slajd 10. Ograniczona moc chłodzenia i nasycenie

**Mówi: Karol Fabianek**

Elementem wykonawczym jest układ chłodzenia cieczą z chillerem oraz grzałka. Sygnał sterujący przyjmuje wartości od minus jeden do jeden: ujemne oznaczają grzanie, dodatnie chłodzenie. Odbiór ciepła wynosi Gcool razy u razy różnica temperatur powierzchni i cieczy, ale nie więcej niż 6,5 kilowata. Wykres pokazuje to nasycenie dla trzech wartości sterowania. Kluczowa obserwacja dla sterowania: pochodna odbioru ciepła po sterowaniu zależy od temperatury powierzchni. Wzmocnienie obiektu zmienia się więc z punktem pracy, a różnica Ts minus temperatura cieczy staje się zmienną harmonogramu. Ta nieliniowość jest podstawą całego podejścia. Zamiast jednego modelu liniowego mamy rodzinę modeli sparametryzowaną przez rho, a regulator dobiera nastawy do aktualnego punktu pracy.

### Slajd 11. Anoda pracuje tylko około 100 mV nad potencjałem litu

**Mówi: Karol Fabianek**

To pierwsza ciekawostka. Anoda grafitowa przy wysokim SOC pracuje tylko około stu miliwoltów nad potencjałem metalicznego litu. Podczas ładowania spadek napięcia na rezystancji anody obniża ten potencjał. Gdy zejdzie poniżej zera, lit zamiast wnikać w grafit osadza się na jego powierzchni. Część tego litu traci się bezpowrotnie, a w skrajnych przypadkach rosną dendryty. Mapa pokazuje największy bezpieczny prąd. Przy 25 stopniach to 1,85C, a przy zerze tylko 0,29C. Wniosek praktyczny: zimą nawet wolne ładowanie z wallboxa do stu procent może litować anodę.

### Slajd 12. Postój naładowanej baterii zużywa ją bardziej niż jazda

**Mówi: Karol Fabianek**

Model starzenia ma trzy składowe. Kalendarzowa rośnie jak czas do potęgi 0,75 i zależy od temperatury oraz napięcia, czyli SOC. Cykliczna rośnie jak pierwiastek z liczby cykli i zależy od temperatury, prądu i zakresu SOC. Trzecia to litowanie. Różne warunki sumujemy metodą czasu zastępczego, która poprawnie łączy lato z zimą i postój z jazdą. Mapa pokazuje samo starzenie kalendarzowe. Ciekawostka: bateria stojąca przy stu procentach SOC starzeje się około 2,2 raza szybciej niż przy pięćdziesięciu, a każde dziesięć stopni podwaja tempo. To najtańsze pokrętła trwałości, bo nie wymagają mocniejszego chłodzenia.

### Slajd 13. Czynniki przyspieszenia starzenia

**Mówi: Karol Fabianek**

Model starzenia opiera się na metodzie czasu zastępczego. Każdą minutę eksploatacji przeliczamy na czas, jaki dałby to samo zużycie w warunkach odniesienia: 25 stopni i 50 procent SOC. Temperatura działa przez prawo Arrheniusa z energią aktywacji 55 kilodżuli na mol, co oznacza mniej więcej podwojenie tempa na każde 10 kelwinów. Napięcie, czyli SOC, działa wykładniczo: przy stu procentach starzenie jest około 2,2 raza szybsze. Starzenie cykliczne liczymy w cyklach zastępczych, ważonych temperaturą, prądem i zakresem SOC. Dopiero zsumowany czas zastępczy wstawiamy do prawa potęgowego. Dzięki temu można poprawnie łączyć lato z zimą i postój z jazdą. Model skalibrowaliśmy tak, aby dawał 9 procent utraty po dziesięciu latach w 25 stopniach i 12 procent po tysiącu cykli.

### Slajd 14. Zużycie baterii ma minimum w funkcji temperatury ładowania

**Mówi: Karol Fabianek**

Druga ciekawostka z modelu: istnieje optymalna temperatura szybkiego ładowania. Wykres pokazuje zużycie baterii na jedno ładowanie w funkcji temperatury ogniwa. Lewe ramię tworzy litowanie, które rośnie w zimnie. Prawe ramię to wzrost warstwy SEI, który przyspiesza w cieple. Optimum przesuwa się z prądem: dla 0,5C to około 5 stopni, dla 1C 14, a dla 1,71C 22 stopni. Ten kształt V jakościowo potwierdzają badania post-mortem Waldmanna z 2014 roku. Wniosek: im szybciej ładujemy, tym cieplejsza powinna być bateria. Oddaję głos Pawłowi.

## Część: Sterowanie

### Slajd 15. Trzy pętle sterowania w trzech skalach czasu

**Mówi: Paweł Fortuna** (zmiana prowadzącego)

Sterowanie ma trzy warstwy o różnych skalach czasu. Pętla szybka działa co sekundę: regulator PI chłodzenia z harmonogramem nastaw, feedforward od strat cieplnych, anti-windup, warstwowy limit prądu i obserwator. Pętla średnia działa na poziomie sesji i doby: ustala okno SOC, moment ładowania w domu i podgrzewanie przed szybkim ładowaniem. Pętla wolna działa raz w miesiącu: estymator RLS ocenia stan zdrowia, a regulator PI porównuje go z planem i ustawia jeden parametr, poziom ochrony lambda. Rozdzielenie skal czasu upraszcza syntezę, bo każda pętla widzi szybsze jako już ustalone.

### Slajd 16. Nastawy PI zależne od punktu pracy

**Mówi: Paweł Fortuna**

Jak już powiedział Karol, wzmocnienie chłodzenia maleje, gdy powierzchnia stygnie, bo maleje różnica temperatur rho. Regulator o stałych nastawach dobrany dla gorącego dnia będzie więc zbyt wolny w chłodny dzień. Gain scheduling rozwiązuje to w prosty sposób. Nastawy PI mnożymy przez współczynnik k równy 17 przez rho, ograniczony do przedziału od 1 do 3. Wykresy pokazują Kp i Ki w funkcji rho. To adaptacja w torze otwartym: nie identyfikujemy modelu online, tylko korzystamy ze znanej fizyki chłodzenia i mierzalnej temperatury powierzchni.

### Slajd 17. Dobór nastaw i weryfikacja harmonogramu

**Mówi: Paweł Fortuna**

Jak dobraliśmy nastawy? Regulator PI dostroiliśmy w punkcie projektowym: rho równe 17 kelwinów, czyli 35 stopni powierzchni przy 18 stopniach cieczy. Harmonogram utrzymuje stały iloczyn Kp razy Gcool razy rho, czyli stałe wzmocnienie pętli otwartej. Trzy karty pokazują nastawy w trzech punktach pracy. Co potwierdziła analiza? Pulsacja odcięcia GS pozostaje stała, 2,61 miliradiana na sekundę, a PI przy 6 kelwinach spada do 0,88. We wszystkich 33 punktach pracy bieguny są stabilne. Uczciwie zaznaczamy, czego nie mamy: formalnego dowodu stabilności LPV. Analiza jest lokalna, co jest uzasadnione, bo rho zmienia się wolno w porównaniu z dynamiką pętli.

### Slajd 18. GS utrzymuje stałą pulsację odcięcia pętli chłodzenia

**Mówi: Paweł Fortuna**

Przejdźmy do analizy częstotliwościowej regulatora chłodzenia. Wzmocnienie obiektu, ile ciepła odbiera chłodzenie na jednostkę sterowania, jest proporcjonalne do różnicy temperatur rho między powierzchnią a cieczą. Zlinearyzowaliśmy pętlę w 33 punktach pracy i policzyliśmy charakterystyki częstotliwościowe bez Control System Toolbox. Przy stałych nastawach pulsacja odcięcia spada razem z rho: przy 6 kelwinach PI ma 0,88 miliradiana na sekundę, czyli trzy razy mniej niż w punkcie projektowym. GS utrzymuje 2,61, tyle samo co przy 17 kelwinach. Zapas fazy wynosi około 90 stopni w całym zakresie. Analizę prowadzimy na modelu zlinearyzowanym w punkcie pracy, z transmitancją od sterowania chłodzeniem do temperatury rdzenia.

### Slajd 19. Odpowiedź na zakłócenie i symulacja nieliniowa

**Mówi: Paweł Fortuna**

Ten sam efekt widać w dziedzinie czasu. Po lewej odpowiedź temperatury rdzenia na skok strat cieplnych o jeden kilowat. W chłodnym punkcie pracy, przy rho równym 5 kelwinów, PI pozwala na prawie dwa i pół kelwina przyrostu, a GS na około 1,3. Po prawej czas powrotu: dla PI rośnie do ponad dwóch godzin, dla GS zostaje około 80 minut. W tabeli wynik symulacji nieliniowej. Przy 25 stopniach GS trzyma rdzeń o 0,58 kelwina chłodniej. W punkcie projektowym, przy 35 stopniach, różnica wynosi tylko 0,25 kelwina. Tak właśnie powinien zachowywać się harmonogram nastaw.

### Slajd 20. PI i GS bez nadzoru prądu przy 25°C

**Mówi: Paweł Fortuna**

Uczciwe porównanie PI i GS bez nadzoru prądu i bez feedforwardu. Przy 25 stopniach PI osiąga 35,29, a GS 34,71 stopnia przy tym samym czasie ładowania. Wykres pokazuje sygnał chłodzenia: GS reaguje wcześniej i mocniej, bo w chłodniejszym punkcie pracy ma większe nastawy. Przy 15 stopniach różnica wynosi −0,37 kelwina. W punkcie projektowym, przy 35 stopniach, oba regulatory są praktycznie równe. Dokładnie tego oczekujemy od harmonogramu nastaw.

> **Pokaz w MATLAB, około 2,5 min.** Skrypt lab2_regulator_pi_gs: sekcja 2 rysuje harmonogram Kp(ρ) i Ki(ρ), sekcja 5 wypisuje pulsację odcięcia PI i GS dla ρ = 6, 10 i 17 K. Pokazujemy, że GS zachowuje 2,67 mrad/s, a PI przy 6 K spada do 0,88 mrad/s.

### Slajd 21. Regulator PI z anti-windupem i sprzężeniem w przód

**Mówi: Paweł Fortuna**

Struktura regulatora. Mierzymy temperaturę powierzchni i prąd. Temperaturę rdzenia, której nie da się zmierzyć, estymuje obserwator. Harmonogram wylicza nastawy, regulator PI liczy sterowanie, a chłodzenie oddziałuje na pakiet. Mamy działanie odwrotne: gdy temperatura rośnie, uchyb jest dodatni i chłodzenia jest więcej. Anti-windup zatrzymuje całkowanie, gdy pogłębiałoby nasycenie, czyli gdy chłodzenie pracuje już na sto procent. Feedforward reaguje na obliczone straty I kwadrat R, zanim temperatura w ogóle wzrośnie. To trzy różne mechanizmy, więc nie przypisujemy ich efektów samemu gain schedulingowi.

### Slajd 22. Obserwator temperatury rdzenia

**Mówi: Paweł Fortuna**

Regulator potrzebuje temperatury rdzenia, ale czujniki znajdują się na powierzchni ogniw. Stosujemy obserwator zredukowanego rzędu oparty na bilansie energii rdzenia. Jego wejściami są zmierzona temperatura powierzchni i estymowane straty cieplne. Równanie błędu estymacji jest liniowe i nie zależy od sterowania, a błąd zanika ze stałą czasową równą stosunkowi pojemności cieplnej rdzenia do przewodności między rdzeniem a powierzchnią, czyli około 95 sekund. To wystarczająco szybko w porównaniu z sesją ładowania trwającą około 20 minut. Jeśli straty są oszacowane z błędem, pojawia się błąd ustalony równy temu błędowi podzielonemu przez przewodność. W teście z początkowym błędem 5 kelwinów po dziesięciu minutach błąd spada poniżej 0,1 kelwina.

### Slajd 23. Nadzór prądu jako drugi kanał sterowania

**Mówi: Paweł Fortuna**

Temperaturą możemy sterować na dwa sposoby. Chłodzenie zwiększa odbiór ciepła, a redukcja prądu zmniejsza jego wytwarzanie. Oba kanały mają inne koszty: chłodzenie kosztuje energię, a redukcja prądu, czas kierowcy. Nadzór termiczny włącza się dopiero przy 36,5 stopnia i liniowo redukuje prąd do 110 amperów przy 39,5 stopnia. Typowy BMS ma dodatkowo statyczną tablicę prądów dla niskich temperatur. W naszej strategii LIFE dochodzi limit z potencjału anody, który sam maleje w zimnie i przy wysokim SOC.

### Slajd 24. Warstwowe ograniczenie prądu ładowania

**Mówi: Paweł Fortuna**

Prąd ładowania wybieramy jako minimum sześciu limitów. Limit bazowy to możliwości stacji lub wallboxa. Profil SOC redukuje prąd powyżej 70 procent. Nadzór termiczny redukuje prąd między 36,5 a 39,5 stopnia. Tablica typowego BMS ogranicza prąd na zimno. Faza CV pilnuje napięcia 4,2 V. Nowością jest limit anody: największy prąd, przy którym potencjał anody zostaje co najmniej piętnaście miliwoltów nad zerem. Nie pochodzi on z tablicy, tylko z modelu, więc sam maleje w zimnie, przy wysokim SOC i gdy bateria się starzeje. Formalnie jest to sterowanie z ograniczeniami realizowane operatorem minimum. Każde ograniczenie jest niezależnym zabezpieczeniem, a zadany prąd jest największą wartością dopuszczalną jednocześnie dla wszystkich. Oddaję głos Karolowi.

## Część: Szybkie ładowanie

### Slajd 25. Każda strategia dodaje jeden mechanizm

**Mówi: Karol Fabianek** (zmiana prowadzącego)

Porównujemy warianty, z których każdy dodaje jeden mechanizm. Punktem odniesienia jest CC, czyli stałe chłodzenie bez regulatora. Następnie regulator PI o stałych nastawach i GS z harmonogramem. GS-SAFE dodaje feedforward i nadzór prądu. STD to typowy BMS z tablicą prądów, który w domu ładuje od razu do 90 lub 100 procent. LIFE i LIFE-ADAPT to proponowane strategie ochrony baterii. Pierwsze cztery warianty porównują regulatory chłodzenia, a dwa ostatnie politykę ładowania.

### Slajd 26. Dwie skale badań: sesja ładowania i 10 lat

**Mówi: Karol Fabianek**

Eksperyment ma dwie skale. Pierwsza to pojedyncza sesja szybkiego ładowania: sześć strategii w sześciu temperaturach od minus dziesięciu do czterdziestu stopni, z krokiem jednej sekundy. Druga to dziesięć lat eksploatacji: cztery strategie w trzech klimatach, Opole, Madryt i Dubaj. Klimaty modelujemy jako sinusoidę roczną i dobową. To kontrolowane scenariusze porównawcze, a nie rzeczywiste dane pogodowe. Mierzymy maksymalną temperaturę rdzenia, czas ładowania, energię chłodzenia i stan zdrowia po dziesięciu latach.

### Slajd 27. Temperatura rdzenia i prąd ładowania przy 35°C

**Mówi: Karol Fabianek**

Sesja ładowania przy 35 stopniach. Bez regulatora rdzeń osiąga 43,7 stopnia i przekracza kryterium czterdziestu stopni po kilku minutach. Regulator PI trzyma 36,2, GS 35,9, a GS z feedforwardem 35,1 stopnia. Wszystkie te warianty nie wydłużają ładowania. Prawy wykres pokazuje prąd. Warianty z profilem SOC zaczynają redukować prąd po 70 procentach. Strategia LIFE nie ma sztywnego profilu i ładuje pełnym prądem do końca, bo potencjał anody w tej temperaturze na to pozwala.

### Slajd 28. Temperatura i czas ładowania przy 35°C

**Mówi: Karol Fabianek**

Ten slajd zestawia maksymalne temperatury przy 35 stopniach i ładowaniu od 20 do 80 procent. Strategie z regulatorem mieszczą się w okolicy 36 stopni. Kryterium czterdziestu stopni przekracza tylko wariant bez regulatora: 45,1 stopnia. Typowy BMS ładuje się 22,7 minuty. LIFE jest najchłodniejszy, 32,3 stopnia, bo chłodzi pakiet już w drodze do ładowarki, i najszybszy: 21,0 minuty. To wyniki modelu, a nie pomiary pojazdu.

### Slajd 29. Podgrzewanie w drodze skraca ładowanie ponad dwukrotnie

**Mówi: Karol Fabianek**

Pierwszy scenariusz: zero stopni, kierowca jedzie autostradą do szybkiej ładowarki. Typowy BMS ładuje zimną baterię według tablicy, więc trwa to 46,7 minuty. Przy wysokim SOC anoda i tak lekko się lituje, 47 ppm. Strategia LIFE wie z nawigacji, że zbliża się ładowarka, i przez ostatnie dwadzieścia minut jazdy grzeje pakiet. Zużywa na to 1,27 kWh, czyli około dwóch procent pojemności. Potem ładuje się w 21,0 minut bez litowania. Dla porównania: ładowanie bez żadnej ochrony anody zużywa baterię około 38 razy bardziej. Warto spojrzeć na przebieg potencjału anody. Dla typowego BMS spada on poniżej zera pod koniec ładowania, czyli wtedy, gdy SOC jest już wysoki, a bateria wciąż chłodna.

> **Pokaz w MATLAB, około 2,5 min.** Skrypt lab3_ladowanie_i_anoda: sekcja 2 wypisuje bezpieczny prąd w funkcji temperatury, sekcja 3 porównuje STD-90 i LIFE przy 0°C. Na wykresie widać spadek potencjału anody poniżej zera dla STD-90.

### Slajd 30. Zimna bateria nagrzewa się sama, ale wymaga limitu anody

**Mówi: Karol Fabianek**

Ten slajd odpowiada na pytanie, co się dzieje, gdy nie zdążymy podgrzać baterii. Jeśli ma ona 5 stopni, ładowanie bez limitu anody kosztuje 2247 ppm pojemności, a z limitem tylko 36 ppm. Ładowanie trwa wtedy o 8,4 minuty dłużej. Ciekawostka: zimna bateria grzeje się sama prądem ładowania, około półtora stopnia na minutę, więc limit działa głównie przez pierwsze minuty. Powyżej 33 stopni hamuje z kolei nadzór termiczny.

### Slajd 31. Czas ładowania i zużycie baterii dla 6 strategii

**Mówi: Karol Fabianek**

Ten slajd zestawia sześć strategii w sześciu temperaturach otoczenia. Po lewej czas ładowania, po prawej zużycie baterii na sesję w skali logarytmicznej. Bez ochrony anody zużycie w zimnie rośnie o dwa rzędy wielkości. Typowa tablica BMS chroni, ale kosztem czasu. Przy minus dziesięciu stopniach nie kończy ładowania nawet w ciągu dwóch godzin, dlatego jej punkt jest obcięty na wartości 120 minut. Strategia LIFE utrzymuje około 21 minut w całym zakresie od minus dziesięciu do czterdziestu stopni. Oddaję głos Pawłowi.

## Część: Adaptacja i trwałość

### Slajd 32. Rekurencyjna metoda najmniejszych kwadratów

**Mówi: Paweł Fortuna** (zmiana prowadzącego)

Gain scheduling to adaptacja w torze otwartym, bo korzysta ze znanej zależności wzmocnienia od punktu pracy. Gdy parametry zmieniają się w nieznany sposób, potrzebna jest identyfikacja. Stosujemy rekurencyjną metodę najmniejszych kwadratów z zapominaniem. W każdym kroku estymata parametrów jest korygowana o błąd predykcji pomnożony przez wzmocnienie, które zależy od macierzy kowariancji. Współczynnik zapominania lambda mniejszy od jedności sprawia, że stare pomiary tracą wagę, a pamięć estymatora wynosi około jeden przez jeden minus lambda próbek. Używamy tego algorytmu dwukrotnie: do parametrów ogniwa z krokiem jednej sekundy i do stanu zdrowia baterii z krokiem jednego miesiąca.

### Slajd 33. Estymator RLS śledzi parametry ogniwa

**Mówi: Paweł Fortuna**

Gain scheduling to adaptacja w torze otwartym. Drugą formą adaptacji jest identyfikacja online. Model ARX z trzema parametrami jest dokładny dla obwodu RC, a estymator RLS liczy je w każdej sekundzie z prądu i napięcia. W trzydziestej minucie testu rezystancje rosną skokowo o trzydzieści procent, co odpowiada spadkowi temperatury albo starzeniu. Estymator z zapominaniem dochodzi do 23,2 miliomów przy prawdziwej wartości 23,3. Bez zapominania zostaje na 19,9, bo uśrednia całą historię. Wniosek: estymator bez zapominania nigdy nie zauważy starzenia baterii.

### Slajd 34. Metoda wieloskalowa: dwa dni reprezentują miesiąc

**Mówi: Paweł Fortuna**

Przechodzę do symulacji dziesięciu lat. Nie da się liczyć dziesięciu lat z krokiem jednej sekundy, dlatego stosujemy metodę wieloskalową. W każdym miesiącu symulujemy dwa reprezentatywne dni. Pierwszy to dzień roboczy: dwa dojazdy po pół godziny, praca bez ładowarki i wieczór w domu z wallboxem. Drugi to dzień w trasie: 150 kilometrów autostradą, szybkie ładowanie i powrót. Stres starzenia mnożymy przez liczbę dni w miesiącu, aktualizujemy SOH, a nowe SOH zmienia pojemność i rezystancję w kolejnym miesiącu. Każda strategia przejeżdża dokładnie ten sam dystans. Porównujemy trzy klimaty: Opole, Madryt i Dubaj.

### Slajd 35. Nadrzędna pętla stanu zdrowia baterii

**Mówi: Paweł Fortuna**

Teraz nadrzędna pętla stanu zdrowia. Raz w miesiącu system zarządzania baterią mierzy pojemność, ale ten pomiar jest zaszumiony. Estymator RLS z zapominaniem 0,85 wyznacza poziom i trend stanu zdrowia. Wartość zadaną tworzy trajektoria odniesienia, która po dziesięciu latach kończy się na 82 procentach, czyli z dwoma punktami zapasu. Jej wykładnik 0,65 odpowiada naturalnemu kształtowi starzenia, więc regulator nie reaguje nerwowo na szybszy spadek w pierwszym roku. Regulator PI przelicza uchyb na jeden parametr: poziom ochrony lambda od zera do jednego. Lambda równa zero oznacza komfort, czyli ładowanie do 85 procent i pełny prąd. Lambda równa jeden to pełna ochrona: ładowanie do 65 procent, prąd szybkiego ładowania 165 amperów i chłodzenie postoju od 22 stopni.

### Slajd 36. Stan zdrowia baterii: 4 strategie w 3 klimatach

**Mówi: Paweł Fortuna**

Oto główny wynik dla trwałości. W Opolu cel spełnia każda strategia, bo chłodny klimat sam chroni baterię. W Madrycie odpada ładowanie do stu procent: 79,1 procent. Już ograniczenie do dziewięćdziesięciu daje 82,3, a LIFE 85,2 procent. W Dubaju typowy BMS kończy z 69,2 procent, wersja z limitem dziewięćdziesięciu procent z 72,5, LIFE z 78,3. Dopiero pętla adaptacyjna utrzymuje 80,8 procent. Linia kropkowana to trajektoria odniesienia, którą śledzi regulator nadrzędny. Różnice między klimatami wynikają głównie z temperatury postoju, bo przez większość doby samochód stoi, a starzenie kalendarzowe rośnie wykładniczo z temperaturą.

### Slajd 37. Składniki utraty pojemności po 10 latach

**Mówi: Paweł Fortuna**

Skąd się bierze utrata pojemności? Pomarańczowa część to starzenie kalendarzowe, niebieska cykliczne, czerwona litowanie. W gorącym klimacie dominuje starzenie kalendarzowe: w Dubaju przy ładowaniu do stu procent to 19,8 punktu procentowego. Pętla adaptacyjna zmniejsza je do 11,0. W zimnym klimacie problemem jest litowanie: w Opolu typowy BMS traci 3,8 punktu przez zimowe ładowanie do stu procent. Część cykliczna jest prawie stała, bo zależy głównie od przejechanych kilometrów. Strategia LIFE nie lituje anody w żadnym klimacie.

### Slajd 38. Poziom ochrony λ rośnie tylko wtedy, gdy jest to potrzebne

**Mówi: Paweł Fortuna**

Tak działa pętla adaptacyjna. Lewy wykres to poziom ochrony lambda. W Opolu i Madrycie bateria starzeje się wolniej niż plan, więc lambda spada do zera, a kierowca może ładować do 85 procent. Pętla oddaje nadwyżkę zdrowia jako komfort. W Dubaju uchyb staje się ujemny już w drugim roku, lambda rośnie i po około czterech latach osiąga jeden. To klasyczne nasycenie elementu wykonawczego: regulator robi wszystko, co może, i dlatego cel z zapasem, czyli 82 procent, jest nieosiągalny. Granica 80 procent zostaje jednak dotrzymana.

> **Pokaz w MATLAB, około 2,5 min.** Skrypt lab4_trwalosc_10_lat dla klimatu Dubaj: sekcja 2 liczy 10 lat dla czterech strategii, sekcja 3 pokazuje przebieg λ, docelowego SOC i SOH na tle trajektorii odniesienia.

### Slajd 39. Energia, zasięg i czas ładowania

**Mówi: Paweł Fortuna**

Uczciwy bilans kosztów. Lewy wykres to energia zarządzania termicznego. W Dubaju pętla adaptacyjna zużywa 396 kWh rocznie, głównie na chłodzenie zaparkowanego auta podłączonego do sieci. To około dziesięciu procent energii jazdy. Środkowy wykres pokazuje średni SOC, czyli zapas zasięgu: w Dubaju spada do około sześćdziesięciu procent. Prawy pokazuje średni czas szybkiego ładowania w trasie: 34 minuty, bo pętla obniża prąd. Ten czas zależy też od SOC przy przyjeździe. W klimacie umiarkowanym koszty są pomijalne. Oddaję głos Karolowi.

## Część: Odporność i walidacja

### Slajd 40. Sprzężenie od SOH kompensuje błędy modelu starzenia

**Mówi: Karol Fabianek** (zmiana prowadzącego)

To najważniejszy wynik z punktu widzenia sterowania odpornego. Model starzenia jest niepewny, więc losujemy pięćdziesiąt pakietów. Zmieniamy współczynniki starzenia, rezystancje, przewodności cieplne i klimat. Losujemy nawet kształt krzywej degradacji. Regulator zna tylko wartości nominalne. Typowy BMS spełnia cel w 72 procentach przypadków, LIFE w 92, a LIFE-ADAPT w 96 procentach. Odchylenie standardowe maleje z 4,1 do 3,0 punktu procentowego, a najgorszy przypadek rośnie z 69,0 do 78,5 procent. Sprzężenie zwrotne od zmierzonego SOH kompensuje błędy modelu. Istotne jest to, że regulator zna tylko wartości nominalne. Analiza sprawdza więc, czy strategia zaprojektowana dla modelu nominalnego spełnia wymaganie dla obiektu, który od tego modelu odbiega.

### Slajd 41. NASA B0005: degradacja bliższa liniowej niż pierwiastkowej

**Mówi: Karol Fabianek**

Model porównaliśmy z prawdziwymi danymi NASA dla ogniwa B0005. Dopasowujemy model potęgowy na siedemdziesięciu procentach cykli i prognozujemy pozostałe trzydzieści, tak jak przy identyfikacji. Model liniowy ma błąd testowy 32 mAh, pierwiastkowy 81 mAh. Ciekawe, że najlepiej dopasowany wykładnik 1,54 prognozuje najgorzej, z błędem 138 mAh, to klasyczne przeuczenie. Widać też skoki pojemności po przerwach w cyklowaniu. Prawdziwe ogniwo nie musi więc trzymać się założonego kształtu. Dlatego Monte Carlo obejmuje oba warianty, a pętla adaptacyjna reaguje na pomiar, a nie na model.

### Slajd 42. Niezależny model blokowy potwierdza wyniki

**Mówi: Karol Fabianek**

Wyniki sprawdziliśmy drugą, niezależną implementacją w postaci modelu blokowego w Simulinku. Harmonogram nastaw jest w nim tablicą k od rho, a stany przechowują elementy opóźnienia. Sesja przy zerze stopni trwa w obu implementacjach 1544 kroków, a największa różnica temperatury rdzenia wynosi 5e-7 kelwina. Wynika ona wyłącznie z interpolacji tablicy harmonogramu. Wyniki nie zależą więc od sposobu implementacji algorytmu.

> **Pokaz w MATLAB, około 2,5 min.** Skrypt lab5_simulink: otwarcie modelu blokowego, przycisk Run, podgląd bloku Scope z temperaturami i SOC, porównanie ze skryptem w Command Window.

### Slajd 43. Ograniczenia modelu i sposób ich weryfikacji

**Mówi: Karol Fabianek**

Krytyczna ocena. Współczynniki starzenia pochodzą z literatury, a nie z badań tego konkretnego ogniwa. Pakiet modelujemy jako jedno uśrednione ogniwo, bez rozrzutu parametrów. Litowanie opisujemy modelem progowym, a nie pełnym modelem elektrochemicznym. Klimat to sinusoida bez nasłonecznienia. Jak się przed tym bronimy? Model przechodzi weryfikację numeryczną: bilans energii i ładunku, zbieżność względem kroku, ograniczenie napięcia i zbieżność obserwatora. Do tego Monte Carlo z dwoma kształtami degradacji, dane NASA i przede wszystkim pętla reagująca na zmierzone SOH. Liczby służą do porównania strategii, a wartości bezwzględne wymagają kalibracji na konkretnym ogniwie. Oddaję głos Pawłowi.

## Część: Podsumowanie

### Slajd 44. Wnioski

**Mówi: Paweł Fortuna** (zmiana prowadzącego)

Podsumujmy w sześciu punktach. Po pierwsze, dominujący mechanizm starzenia zależy od klimatu: w gorącym jest to starzenie kalendarzowe, w zimnym litowanie anody. Po drugie, sposób ładowania ma większy wpływ niż samo chłodzenie: niższy docelowy SOC i ładowanie kończone przed wyjazdem podnoszą SOH w Madrycie o ponad sześć punktów procentowych. Po trzecie, temperatura szybkiego ładowania ma optimum, a podgrzanie skraca ładowanie zimą ponad dwukrotnie bez litowania. Po czwarte, gain scheduling utrzymuje stałą dynamikę pętli chłodzenia w całym zakresie pracy. Po piąte, sprzężenie od zmierzonego SOH czyni wynik odpornym na błędy modelu starzenia. Po szóste, w gorącym klimacie pętla osiąga nasycenie, więc wymaganie 80 procent jest spełnione, ale bez zapasu i kosztem energii chłodzenia.

### Slajd 45. Bibliografia

**Mówi: Paweł Fortuna**

Na slajdzie jest literatura, na której oparliśmy wykład. Teoria gain schedulingu pochodzi z pracy Rugha i Shammy oraz podręczników Åströma. Model baterii i jej zarządzania opieramy na monografii Pletta. Modele starzenia i litowania pochodzą z prac Schmalstiega, Waldmanna, Wanga i Doyle'a, parametry cieplne ogniwa z pracy Lina i raportu Bhundiyi, a dane do walidacji z repozytorium NASA. Oddaję głos Karolowi.

### Slajd 46. Dziękujemy za uwagę

**Mówi: Karol Fabianek** (zmiana prowadzącego)

Dziękujemy za uwagę. Chętnie odpowiemy na pytania.

