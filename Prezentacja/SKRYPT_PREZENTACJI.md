# Skrypt wystąpień. Karol Fabianek, Paweł Fortuna

Tekst do wygłoszenia slajd po slajdzie, z podziałem na osoby. Liczby pochodzą z plików `Projekt/results/*.csv`, więc są zgodne ze slajdami i z projektem. Ten sam tekst jest w notatkach prelegenta w plikach .pptx.

- Część 1. Wykład, plik `BTMS_WYKLAD_FABIANEK_FORTUNA.pptx`
- Część 2. Projekt, plik `BTMS_PROJEKT_FABIANEK_FORTUNA.pptx`

## Część 1. Wykład: zarządzanie termiczne baterią z zastosowaniem Gain Scheduling

Plik `Prezentacja/BTMS_WYKLAD_FABIANEK_FORTUNA.pptx`, 27 slajdów. Tekst każdego slajdu jest też w notatkach prelegenta w pliku .pptx.

| Osoba | Slajdy | Liczba slajdów | Czas mówienia |
|---|---|---:|---:|
| Karol Fabianek | 1-10, 19-22 | 14 | około 8 min |
| Paweł Fortuna | 11-18, 23-27 | 13 | około 7 min |

### Slajd 1. Zarządzanie termiczne baterią pojazdu elektrycznego z zastosowaniem Gain Scheduling

**Karol Fabianek:** Dzień dobry. Nazywam się Karol Fabianek, a to Paweł Fortuna. Tematem wykładu jest zarządzanie termiczne baterią pojazdu elektrycznego z zastosowaniem gain schedulingu, czyli harmonogramowania nastaw regulatora. Pokażemy, dlaczego bateria potrzebuje aktywnego układu termicznego, jak wygląda jej model i jak zbudować regulator, którego nastawy zmieniają się wraz z punktem pracy. Na końcu pokażemy, jak te mechanizmy wpływają na trwałość baterii w horyzoncie dziesięciu lat.

### Slajd 2. Gain Scheduling w zarządzaniu temperaturą baterii EV

**Karol Fabianek:** Plan ma pięć części. Najpierw problem: po co sterować temperaturą baterii. Potem obiekt: pakiet i jego model elektryczny, cieplny oraz model anody. W trzeciej części Paweł omówi regulator z harmonogramem nastaw, anti-windup i nadzór prądu. Następnie pokażę przykłady symulacyjne przy 25 i 35 stopniach. Na końcu Paweł przedstawi ograniczenia modelu i wyniki długoterminowe.

### Slajd 3. Dlaczego bateria EV potrzebuje BTMS?

**Karol Fabianek:** Dlaczego bateria potrzebuje układu BTMS? Szybkie ładowanie to duży prąd, a straty Joule'a rosną z kwadratem prądu. Temperatura decyduje o bezpieczeństwie i o tempie starzenia. Chłodzenie nie jest darmowe, bo pompa i sprężarka pobierają energię. Ograniczenie prądu zmniejsza ciepło, ale wydłuża ładowanie. Schemat pokazuje dwa kanały sterowania: sterownik zmienia prąd ładowarki i wydajność chłodzenia. Sterownik szuka więc kompromisu między czasem ładowania, temperaturą, energią chłodzenia i trwałością.

### Slajd 4. Pakiet referencyjny Li-ion 96s50p

**Karol Fabianek:** Obiektem jest referencyjny pakiet 96s50p. Pięćdziesiąt ogniw łączymy równolegle w sekcję, a dziewięćdziesiąt sześć sekcji szeregowo, razem 4800 ogniw typu 18650. Daje to 345,6 V, 175 Ah, 60,48 kWh i rezystancję 53,76 miliomów. Zasada jest prosta: połączenie szeregowe zwiększa napięcie i rezystancję, a równoległe pojemność i zmniejsza rezystancję. Parametry ogniwa są założeniem projektowym, a nie danymi konkretnego producenta. Rezystancję ogniwa, 28 miliomów, dzielimy na część omową, 18 miliomów, i polaryzacyjną z gałęzią RC o stałej czasowej 40 sekund.

### Slajd 5. Model dwuwęzłowy: rdzeń i powierzchnia

**Karol Fabianek:** Model cieplny ma dwa węzły: rdzeń i powierzchnię. Ciepło powstaje w rdzeniu jako straty I kwadrat R. Przez przewodność między rdzeniem a powierzchnią płynie do powierzchni, a tam odbiera je otoczenie i układ chłodzenia. Pojemność cieplną pakietu dzielimy: 76 procent na rdzeń i 24 procent na powierzchnię. To ważne dla sterowania, bo chłodzenie działa na powierzchnię, a ciepło powstaje w rdzeniu. Przy 300 amperach rdzeń jest około 3 kelwiny cieplejszy od powierzchni. Równania całkujemy niejawną metodą Eulera, która jest stabilna przy każdym kroku.

### Slajd 6. Straty rosną z kwadratem prądu, rezystancja rośnie w zimnie

**Karol Fabianek:** Źródłem ciepła są straty. Lewy wykres pokazuje, że rosną z kwadratem prądu: dwa razy większy prąd to około cztery razy więcej ciepła. Przy 300 amperach to około 4,8 kilowata. Jeśli ograniczymy prąd do 210 amperów, ciepła jest o około 51 procent mniej. Prawy wykres pokazuje rezystancję w funkcji temperatury. Opisujemy ją prawem Arrheniusa, więc w zerze stopni jest ponad dwukrotnie większa niż w 25 stopniach. Linia przerywana to prosty model liniowy, który w zimnie wyraźnie ją zaniża.

### Slajd 7. Anoda pracuje tylko około 100 mV nad potencjałem litu

**Karol Fabianek:** Pierwsza ciekawostka. Anoda grafitowa przy wysokim stanie naładowania pracuje tylko około stu miliwoltów nad potencjałem metalicznego litu. Podczas ładowania spadek napięcia na rezystancji anody obniża ten potencjał. Gdy zejdzie poniżej zera, lit osadza się na powierzchni grafitu zamiast w nim. Część tego litu traci się bezpowrotnie, a w skrajnych przypadkach rosną dendryty. Mapa pokazuje największy bezpieczny prąd: przy 80 procent SOC to 1,85C w 25 stopniach i tylko 0,29C w zerze. Wniosek: temperatura decyduje nie tylko o bezpieczeństwie, ale też o dopuszczalnym prądzie, więc BTMS musi umieć grzać.

### Slajd 8. Ograniczona moc chłodzenia i nasycenie

**Karol Fabianek:** Elementem wykonawczym jest układ chłodzenia cieczą z chillerem oraz grzałka. Sygnał sterujący przyjmuje wartości od minus jeden do jeden: ujemne oznaczają grzanie, dodatnie chłodzenie. Odbiór ciepła wynosi Gcool razy u razy różnica temperatur powierzchni i cieczy, ale nie więcej niż 6,5 kilowata. Wykres pokazuje to nasycenie dla trzech wartości sterowania. Kluczowa obserwacja dla sterowania: pochodna odbioru ciepła po sterowaniu zależy od temperatury powierzchni. Wzmocnienie obiektu zmienia się więc z punktem pracy, a różnica Ts minus temperatura cieczy staje się zmienną harmonogramu.

### Slajd 9. Ładowanie CC-CV od 20 do 80% SOC

**Karol Fabianek:** Ładowanie modelujemy w pełnym schemacie CC-CV. Najpierw ładujemy stałym prądem do 300 amperów, czyli około 1,7C. Gdy napięcie ogniwa dojdzie do 4,2 V, przechodzimy na stałe napięcie, a ładowanie kończy się przy prądzie spadającym poniżej C/20. Lewy wykres to krzywa napięcia obwodu otwartego, prawy to potencjał anody. Ten sam stan naładowania zmienia więc napięcie i bezpieczny prąd. Czas ładowania od 20 do 80 procent jest jednym z mierników jakości strategii.

### Slajd 10. Cztery konkurujące kryteria

**Karol Fabianek:** Mamy cztery konkurujące kryteria. Temperatura rdzenia ma być niższa niż 40 stopni. Czas ładowania od 20 do 80 procent ma być możliwie krótki. Energia chłodzenia na sesję ma być możliwie mała. Stan zdrowia baterii po dziesięciu latach ma wynosić co najmniej 80 procent. Porównujemy strategie w dwóch skalach: w pojedynczej sesji ładowania i w dziesięcioletniej eksploatacji w trzech klimatach. Nie ma strategii najlepszej we wszystkim, więc oceniamy kompromisy. Teraz Paweł omówi regulator.

### Slajd 11. Nastawy PI zależne od punktu pracy

**Paweł Fortuna:** Dziękuję. Jak już powiedział Karol, wzmocnienie chłodzenia maleje, gdy powierzchnia stygnie, bo maleje różnica temperatur rho. Regulator o stałych nastawach dobrany dla gorącego dnia będzie więc zbyt wolny w chłodny dzień. Gain scheduling rozwiązuje to w prosty sposób. Nastawy PI mnożymy przez współczynnik k równy 17 przez rho, ograniczony do przedziału od 1 do 3. Wykresy pokazują Kp i Ki w funkcji rho. To adaptacja w torze otwartym: nie identyfikujemy modelu online, tylko korzystamy ze znanej fizyki chłodzenia i mierzalnej temperatury powierzchni.

### Slajd 12. Dobór nastaw i weryfikacja harmonogramu

**Paweł Fortuna:** Jak dobraliśmy nastawy? Regulator PI dostroiliśmy w punkcie projektowym: rho równe 17 kelwinów, czyli 35 stopni powierzchni przy 18 stopniach cieczy. Harmonogram utrzymuje stały iloczyn Kp razy Gcool razy rho, czyli stałe wzmocnienie pętli otwartej. Trzy karty pokazują nastawy w trzech punktach pracy. Co potwierdziła analiza? Pulsacja odcięcia GS pozostaje stała, 2,61 miliradiana na sekundę, a PI przy 6 kelwinach spada do 0,88. We wszystkich 33 punktach pracy bieguny są stabilne. Uczciwie zaznaczamy, czego nie mamy: formalnego dowodu stabilności LPV. Analiza jest lokalna, co jest uzasadnione, bo rho zmienia się wolno w porównaniu z dynamiką pętli.

### Slajd 13. Regulator PI z anti-windupem i sprzężeniem w przód

**Paweł Fortuna:** Struktura regulatora. Mierzymy temperaturę powierzchni i prąd. Temperaturę rdzenia, której nie da się zmierzyć, estymuje obserwator. Harmonogram wylicza nastawy, regulator PI liczy sterowanie, a chłodzenie oddziałuje na pakiet. Mamy działanie odwrotne: gdy temperatura rośnie, uchyb jest dodatni i chłodzenia jest więcej. Anti-windup zatrzymuje całkowanie, gdy pogłębiałoby nasycenie, czyli gdy chłodzenie pracuje już na sto procent. Feedforward reaguje na obliczone straty I kwadrat R, zanim temperatura w ogóle wzrośnie. To trzy różne mechanizmy, więc nie przypisujemy ich efektów samemu gain schedulingowi.

### Slajd 14. Nadzór prądu jako drugi kanał sterowania

**Paweł Fortuna:** Temperaturą możemy sterować na dwa sposoby. Chłodzenie zwiększa odbiór ciepła, a redukcja prądu zmniejsza jego wytwarzanie. Oba kanały mają inne koszty: chłodzenie kosztuje energię, a redukcja prądu, czas kierowcy. Nadzór termiczny włącza się dopiero przy 36,5 stopnia i liniowo redukuje prąd do 110 amperów przy 39,5 stopnia. Typowy BMS ma dodatkowo statyczną tablicę prądów dla niskich temperatur. W naszej strategii LIFE dochodzi limit z potencjału anody, który sam maleje w zimnie i przy wysokim SOC.

### Slajd 15. Sześć warstw ograniczenia prądu ładowania

**Paweł Fortuna:** Wszystkie te ograniczenia łączymy w jeden wzór: zadany prąd to minimum sześciu limitów. Pierwszy to profil SOC z redukcją po 70 procentach. Drugi to nadzór termiczny. Trzeci to tablica typowego BMS. Czwarty to limit anody wyliczany z modelu, a nie z tablicy. Piąty to faza CV. Szósty to poziom ochrony z nadrzędnej pętli zdrowia baterii, który działa w skali miesięcy. Ograniczenie prądu jest niezależne od gain schedulingu, a każda warstwa chroni przed innym mechanizmem.

### Slajd 16. Zużycie baterii ma minimum w funkcji temperatury ładowania

**Paweł Fortuna:** Druga ciekawostka: zużycie baterii na jedno ładowanie ma minimum w funkcji temperatury. To tak zwany kształt V. Lewe ramię to litowanie anody w zimnie, prawe to wzrost warstwy SEI w cieple. Optimum przesuwa się z prądem: dla 0,5C to około 5 stopni, dla 1C około 14, dla 1,71C około 22 stopni. Taki przebieg potwierdzają badania post-mortem Waldmanna z 2014 roku. Wniosek dla układu sterowania: BTMS nie tylko chłodzi, ale przed szybkim ładowaniem zimą powinien baterię podgrzać.

### Slajd 17. Każda strategia dodaje jeden mechanizm

**Paweł Fortuna:** Porównujemy warianty, z których każdy dodaje jeden mechanizm. Punktem odniesienia jest CC, czyli stałe chłodzenie bez regulatora. Następnie regulator PI o stałych nastawach i GS z harmonogramem. GS-SAFE dodaje feedforward i nadzór prądu. STD to typowy BMS z tablicą prądów, który w domu ładuje od razu do 90 lub 100 procent. LIFE i LIFE-ADAPT to proponowane strategie ochrony baterii. Pierwsze cztery warianty porównują regulatory chłodzenia, a dwa ostatnie politykę ładowania.

### Slajd 18. Dwie skale badań: sesja ładowania i 10 lat

**Paweł Fortuna:** Eksperyment ma dwie skale. Pierwsza to pojedyncza sesja szybkiego ładowania: sześć strategii w sześciu temperaturach od minus dziesięciu do czterdziestu stopni, z krokiem jednej sekundy. Druga to dziesięć lat eksploatacji: cztery strategie w trzech klimatach, Opole, Madryt i Dubaj. Klimaty modelujemy jako sinusoidę roczną i dobową. To kontrolowane scenariusze porównawcze, a nie rzeczywiste dane pogodowe. Mierzymy maksymalną temperaturę rdzenia, czas ładowania, energię chłodzenia i stan zdrowia po dziesięciu latach. Wyniki pokaże Karol.

### Slajd 19. Temperatura rdzenia i prąd ładowania przy 35°C

**Karol Fabianek:** Sesja ładowania przy 35 stopniach. Bez regulatora rdzeń osiąga 43,7 stopnia i przekracza kryterium czterdziestu stopni po kilku minutach. Regulator PI trzyma 36,2, GS 35,9, a GS z feedforwardem 35,1 stopnia. Wszystkie te warianty nie wydłużają ładowania. Prawy wykres pokazuje prąd. Warianty z profilem SOC zaczynają redukować prąd po 70 procentach. Strategia LIFE nie ma sztywnego profilu i ładuje pełnym prądem do końca, bo potencjał anody w tej temperaturze na to pozwala.

### Slajd 20. Temperatura i czas ładowania przy 35°C

**Karol Fabianek:** Ten slajd zestawia maksymalne temperatury przy 35 stopniach i ładowaniu od 20 do 80 procent. Strategie z regulatorem mieszczą się w okolicy 36 stopni. Kryterium czterdziestu stopni przekracza tylko wariant bez regulatora: 45,1 stopnia. Typowy BMS ładuje się 22,7 minuty. LIFE jest najchłodniejszy, 32,3 stopnia, bo chłodzi pakiet już w drodze do ładowarki, i najszybszy: 21,0 minuty. To wyniki modelu, a nie pomiary pojazdu.

### Slajd 21. PI i GS bez nadzoru prądu przy 25°C

**Karol Fabianek:** Uczciwe porównanie PI i GS bez nadzoru prądu i bez feedforwardu. Przy 25 stopniach PI osiąga 35,29, a GS 34,71 stopnia przy tym samym czasie ładowania. Wykres pokazuje sygnał chłodzenia: GS reaguje wcześniej i mocniej, bo w chłodniejszym punkcie pracy ma większe nastawy. Przy 15 stopniach różnica wynosi −0,37 kelwina. W punkcie projektowym, przy 35 stopniach, oba regulatory są praktycznie równe. Dokładnie tego oczekujemy od harmonogramu nastaw.

### Slajd 22. Bateria starzeje się także na postoju

**Karol Fabianek:** Ostatnia ciekawostka: bateria starzeje się także wtedy, gdy auto stoi. Mapa pokazuje utratę pojemności po dziesięciu latach samego postoju w stałych warunkach. Postój przy stu procentach SOC przyspiesza starzenie około 2,2 raza w porównaniu z pięćdziesięcioma procentami. Każde dziesięć stopni przyspiesza je mniej więcej dwukrotnie. W Dubaju przy codziennym ładowaniu do stu procent sam postój zabiera 19,8 procent pojemności w dziesięć lat. O trwałości decyduje więc także sposób postoju baterii. Teraz Paweł przedstawi ograniczenia modelu i wyniki długoterminowe.

### Slajd 23. Ograniczenia modelu

**Paweł Fortuna:** Krytyczna ocena modelu. W części elektryczno-cieplnej pakiet to jedno uśrednione ogniwo, bez rozrzutu parametrów. Zamiast modelu elektrochemicznego używamy obwodu zastępczego, a litowanie opisujemy modelem progowym. Przewodności cieplne pochodzą z literatury, a klimat to sinusoida bez nasłonecznienia. W modelu starzenia współczynniki są literaturowe, a składowe sumujemy, co też jest założeniem. Kształt degradacji jest niepewny, bo dane NASA wskazują raczej na przebieg liniowy. Dlatego stosujemy analizę Monte Carlo i pętlę sprzężenia od zmierzonego SOH. Model nadaje się do porównywania strategii, ale nie do prognozy dla konkretnego pakietu.

### Slajd 24. Trwałość baterii w horyzoncie 10 lat

**Paweł Fortuna:** Wyniki w horyzoncie dziesięciu lat. W Dubaju typowy BMS kończy z 69,2 procent SOH, a strategia z pętlą adaptacyjną z 80,8 procent. W analizie odporności losujemy pięćdziesiąt pakietów o różnych parametrach starzenia, rezystancji i klimatu. Wymaganie spełnia 72 procent pakietów z typowym BMS i 96 procent z pętlą adaptacyjną, a rozrzut SOH maleje. Dane NASA wskazują, że rzeczywista degradacja jest bliższa liniowej, a niezależny model blokowy potwierdza wyniki. Sprzężenie od zmierzonego SOH kompensuje więc błędy modelu, co jest istotą sterowania odpornego.

### Slajd 25. Wnioski

**Paweł Fortuna:** Wnioski z wykładu. Po pierwsze: regulator jest konieczny, bez niego rdzeń przy 35 stopniach przekracza 43 stopnie. Po drugie: gain scheduling według różnicy Ts minus temperatura cieczy kompensuje zmienne wzmocnienie chłodzenia i daje przy 25 stopniach około 0,6 kelwina zysku. Po trzecie: temperatura to nie tylko chłodzenie, zimą BTMS musi grzać, bo litowanie ogranicza bezpieczny prąd ponad sześciokrotnie. Po czwarte: trwałość zależy też od postoju, czyli od okna SOC i temperatury, w której bateria stoi.

### Slajd 26. Bibliografia

**Paweł Fortuna:** Na slajdzie jest literatura, na której oparliśmy wykład. Teoria gain schedulingu pochodzi z pracy Rugha i Shammy oraz podręczników Åströma. Model baterii i jej zarządzania opieramy na monografii Pletta. Modele starzenia i litowania pochodzą z prac Schmalstiega, Waldmanna i Doyle'a. Parametry cieplne ogniwa pochodzą z pracy Lina i raportu Bhundiyi.

### Slajd 27. Dziękujemy za uwagę

**Paweł Fortuna:** Dziękujemy za uwagę. Zapraszamy do pytań.

## Część 2. Projekt: sterowanie ładowaniem i temperaturą baterii z ograniczeniem starzenia

Plik `Prezentacja/BTMS_PROJEKT_FABIANEK_FORTUNA.pptx`, 29 slajdów. Tekst każdego slajdu jest też w notatkach prelegenta w pliku .pptx.

| Osoba | Slajdy | Liczba slajdów | Czas mówienia |
|---|---|---:|---:|
| Karol Fabianek | 1-14, 27-29 | 17 | około 10 min |
| Paweł Fortuna | 15-26 | 12 | około 7 min |

### Slajd 1. Sterowanie ładowaniem i temperaturą baterii pojazdu elektrycznego z ograniczeniem starzenia

**Karol Fabianek:** Dzień dobry. Nazywam się Karol Fabianek, a to Paweł Fortuna. Przedstawiamy sterowanie ładowaniem i temperaturą baterii pojazdu elektrycznego z ograniczeniem starzenia. Postawiliśmy pytanie: jak sterować prądem, napięciem, stanem naładowania i temperaturą pakietu, aby po dziesięciu latach eksploatacji bateria zachowała co najmniej osiemdziesiąt procent pojemności? Odpowiedź opiera się na modelu elektryczno-cieplnym pakietu, modelu starzenia i trzech pętlach sterowania. Ja omówię cel, model i szybkie ładowanie, a Paweł regulator, wyniki dziesięcioletnie i odporność.

### Slajd 2. Wymagania projektowe

**Karol Fabianek:** Założenia są cztery. Pierwsze: SOH, czyli pojemność względna, ma po dziesięciu latach wynosić co najmniej osiemdziesiąt procent. To ostrzejsze niż typowa gwarancja producentów, która mówi o siedemdziesięciu procentach po ośmiu latach. Drugie: walczymy o pojemność, więc rozbijamy jej utratę na trzy mechanizmy. Trzecie: sterujemy parametrami ładowania, prądem, napięciem fazy CV, oknem SOC, momentem ładowania i temperaturą przy ładowaniu. Czwarte: pilnujemy nominalnej temperatury, czyli rdzeń poniżej czterdziestu stopni. Obiektem jest pakiet 96s50p, 345,6 V, 175 Ah, około 60 kWh.

### Slajd 3. Najważniejsze wyniki

**Karol Fabianek:** Zacznę od wyników. W gorącym klimacie, czyli w Dubaju, typowy BMS ładujący do stu procent kończy dziesięć lat z 69,2 procent SOH. Nasza strategia z pętlą adaptacyjną osiąga 80,8 procent. W Madrycie sama zmiana sposobu ładowania podnosi wynik z 79,1 do 85,2 procent. Przy zerze stopni szybkie ładowanie skraca się z 47 do 21 minut i jest bezpieczne dla anody. W analizie odporności cel spełnia 72 procent losowych pakietów z typowym BMS i 96 procent z naszą pętlą. Najważniejszy wniosek: o trwałości bardziej niż prąd szybkiego ładowania decyduje to, jak długo i w jakiej temperaturze bateria stoi naładowana.

### Slajd 4. Zjawiska uwzględnione w modelu

**Karol Fabianek:** Ten slajd zestawia zjawiska, które uwzględnia model. Dynamikę elektryczną opisuje krzywa napięcia obwodu otwartego i obwód RC, dzięki czemu można modelować pełne ładowanie CC-CV z ograniczeniem 4,2 V na ogniwo. Rezystancja zależy od temperatury według prawa Arrheniusa, a jej parametry można identyfikować na bieżąco metodą RLS. Temperatury rdzenia nie da się zmierzyć, więc estymuje ją obserwator. Stan zdrowia zmienia pojemność i rezystancję, a samo starzenie opisuje model półempiryczny z trzema składowymi.

### Slajd 5. Trzy pętle sterowania w trzech skalach czasu

**Karol Fabianek:** Sterowanie ma trzy warstwy o różnych skalach czasu. Pętla szybka działa co sekundę: regulator PI chłodzenia z harmonogramem nastaw, feedforward od strat cieplnych, anti-windup, warstwowy limit prądu i obserwator. Pętla średnia działa na poziomie sesji i doby: ustala okno SOC, moment ładowania w domu i podgrzewanie przed szybkim ładowaniem. Pętla wolna działa raz w miesiącu: estymator RLS ocenia stan zdrowia, a regulator PI porównuje go z planem i ustawia jeden parametr, poziom ochrony lambda. Rozdzielenie skal czasu upraszcza syntezę, bo każda pętla widzi szybsze jako już ustalone.

### Slajd 6. Model elektryczny 1RC i dwuwęzłowy model cieplny

**Karol Fabianek:** Model pakietu to obwód zastępczy z jedną gałęzią RC i dwuwęzłowy model cieplny: rdzeń i powierzchnia. Gałąź RC dyskretyzujemy dokładnie, a równania cieplne całkujemy niejawną metodą Eulera. To ważny szczegół numeryczny: metoda niejawna jest stabilna przy każdym kroku, więc postój liczymy z krokiem sześćdziesięciu sekund, a dziesięć lat eksploatacji w kilka sekund. Wykres pokazuje rezystancję w funkcji temperatury. W zerze stopni rezystancja ogniwa rośnie ponad dwukrotnie, a rezystancja anody, która decyduje o litowaniu, około pięciokrotnie. Linia przerywana to uproszczony model liniowy, który w zimnie mocno zaniżał rezystancję.

### Slajd 7. Anoda pracuje tylko około 100 mV nad potencjałem litu

**Karol Fabianek:** To pierwsza ciekawostka. Anoda grafitowa przy wysokim SOC pracuje tylko około stu miliwoltów nad potencjałem metalicznego litu. Podczas ładowania spadek napięcia na rezystancji anody obniża ten potencjał. Gdy zejdzie poniżej zera, lit zamiast wnikać w grafit osadza się na jego powierzchni. Część tego litu traci się bezpowrotnie, a w skrajnych przypadkach rosną dendryty. Mapa pokazuje największy bezpieczny prąd. Przy 25 stopniach to 1,85C, a przy zerze tylko 0,29C. Wniosek praktyczny: zimą nawet wolne ładowanie z wallboxa do stu procent może litować anodę.

### Slajd 8. Postój naładowanej baterii zużywa ją bardziej niż jazda

**Karol Fabianek:** Model starzenia ma trzy składowe. Kalendarzowa rośnie jak czas do potęgi 0,75 i zależy od temperatury oraz napięcia, czyli SOC. Cykliczna rośnie jak pierwiastek z liczby cykli i zależy od temperatury, prądu i zakresu SOC. Trzecia to litowanie. Różne warunki sumujemy metodą czasu zastępczego, która poprawnie łączy lato z zimą i postój z jazdą. Mapa pokazuje samo starzenie kalendarzowe. Ciekawostka: bateria stojąca przy stu procentach SOC starzeje się około 2,2 raza szybciej niż przy pięćdziesięciu, a każde dziesięć stopni podwaja tempo. To najtańsze pokrętła trwałości, bo nie wymagają mocniejszego chłodzenia.

### Slajd 9. Zużycie baterii ma minimum w funkcji temperatury ładowania

**Karol Fabianek:** Druga ciekawostka z modelu: istnieje optymalna temperatura szybkiego ładowania. Wykres pokazuje zużycie baterii na jedno ładowanie w funkcji temperatury ogniwa. Lewe ramię tworzy litowanie, które rośnie w zimnie. Prawe ramię to wzrost warstwy SEI, który przyspiesza w cieple. Optimum przesuwa się z prądem: dla 0,5C to około 5 stopni, dla 1C 14, a dla 1,71C 22 stopni. Ten kształt V jakościowo potwierdzają badania post-mortem Waldmanna z 2014 roku. Wniosek: im szybciej ładujemy, tym cieplejsza powinna być bateria.

### Slajd 10. Warstwowe ograniczenie prądu ładowania

**Karol Fabianek:** Prąd ładowania wybieramy jako minimum sześciu limitów. Limit bazowy to możliwości stacji lub wallboxa. Profil SOC redukuje prąd powyżej 70 procent. Nadzór termiczny redukuje prąd między 36,5 a 39,5 stopnia. Tablica typowego BMS ogranicza prąd na zimno. Faza CV pilnuje napięcia 4,2 V. Nowością jest limit anody: największy prąd, przy którym potencjał anody zostaje co najmniej piętnaście miliwoltów nad zerem. Nie pochodzi on z tablicy, tylko z modelu, więc sam maleje w zimnie, przy wysokim SOC i gdy bateria się starzeje.

### Slajd 11. Podgrzewanie w drodze skraca ładowanie ponad dwukrotnie

**Karol Fabianek:** Pierwszy scenariusz: zero stopni, kierowca jedzie autostradą do szybkiej ładowarki. Typowy BMS ładuje zimną baterię według tablicy, więc trwa to 46,7 minuty. Przy wysokim SOC anoda i tak lekko się lituje, 47 ppm. Strategia LIFE wie z nawigacji, że zbliża się ładowarka, i przez ostatnie dwadzieścia minut jazdy grzeje pakiet. Zużywa na to 1,27 kWh, czyli około dwóch procent pojemności. Potem ładuje się w 21,0 minut bez litowania. Dla porównania: ładowanie bez żadnej ochrony anody zużywa baterię około 38 razy bardziej.

### Slajd 12. Chłodzenie wstępne i regulator GS-PI ze sprzężeniem w przód

**Karol Fabianek:** Drugi scenariusz to upał, 35 stopni. Bez regulatora rdzeń osiąga 45,1 stopnia, czyli przekracza kryterium. Typowy BMS z regulatorem PI dochodzi do 36,3. LIFE chłodzi pakiet już w trasie, dojeżdża z 28,1 stopniami i kończy ładowanie na 32,3. Ładuje się przy tym szybciej, 21,0 zamiast 22,7 minuty. Powodem jest brak sztywnego profilu SOC: limit anody pokazuje, że w tej temperaturze pełny prąd jest bezpieczny aż do końca.

### Slajd 13. Czas ładowania i zużycie baterii dla 6 strategii

**Karol Fabianek:** Ten slajd zestawia sześć strategii w sześciu temperaturach otoczenia. Po lewej czas ładowania, po prawej zużycie baterii na sesję w skali logarytmicznej. Bez ochrony anody zużycie w zimnie rośnie o dwa rzędy wielkości. Typowa tablica BMS chroni, ale kosztem czasu. Przy minus dziesięciu stopniach nie kończy ładowania nawet w ciągu dwóch godzin, dlatego jej punkt jest obcięty na wartości 120 minut. Strategia LIFE utrzymuje około 21 minut w całym zakresie od minus dziesięciu do czterdziestu stopni.

### Slajd 14. Zimna bateria nagrzewa się sama, ale wymaga limitu anody

**Karol Fabianek:** Ostatni slajd mojej części odpowiada na pytanie, co się dzieje, gdy nie zdążymy podgrzać baterii. Jeśli ma ona 5 stopni, ładowanie bez limitu anody kosztuje 2247 ppm pojemności, a z limitem tylko 36 ppm. Ładowanie trwa wtedy o 8,4 minuty dłużej. Ciekawostka: zimna bateria grzeje się sama prądem ładowania, około półtora stopnia na minutę, więc limit działa głównie przez pierwsze minuty. Powyżej 33 stopni hamuje z kolei nadzór termiczny. Oddaję głos Pawłowi.

### Slajd 15. GS utrzymuje stałą pulsację odcięcia pętli chłodzenia

**Paweł Fortuna:** Dziękuję. Zacznę od analizy regulatora chłodzenia, czyli serca układu. Wzmocnienie obiektu, ile ciepła odbiera chłodzenie na jednostkę sterowania, jest proporcjonalne do różnicy temperatur rho między powierzchnią a cieczą. Zlinearyzowaliśmy pętlę w 33 punktach pracy i policzyliśmy charakterystyki częstotliwościowe bez Control System Toolbox. Przy stałych nastawach pulsacja odcięcia spada razem z rho: przy 6 kelwinach PI ma 0,88 miliradiana na sekundę, czyli trzy razy mniej niż w punkcie projektowym. GS utrzymuje 2,61, tyle samo co przy 17 kelwinach. Zapas fazy wynosi około 90 stopni w całym zakresie.

### Slajd 16. Odpowiedź na zakłócenie i symulacja nieliniowa

**Paweł Fortuna:** Ten sam efekt widać w dziedzinie czasu. Po lewej odpowiedź temperatury rdzenia na skok strat cieplnych o jeden kilowat. W chłodnym punkcie pracy, przy rho równym 5 kelwinów, PI pozwala na prawie dwa i pół kelwina przyrostu, a GS na około 1,3. Po prawej czas powrotu: dla PI rośnie do ponad dwóch godzin, dla GS zostaje około 80 minut. W tabeli wynik symulacji nieliniowej. Przy 25 stopniach GS trzyma rdzeń o 0,58 kelwina chłodniej. W punkcie projektowym, przy 35 stopniach, różnica wynosi tylko 0,25 kelwina. Tak właśnie powinien zachowywać się harmonogram nastaw.

### Slajd 17. Estymator RLS śledzi parametry ogniwa

**Paweł Fortuna:** Gain scheduling to adaptacja w torze otwartym. Drugą formą adaptacji jest identyfikacja online. Model ARX z trzema parametrami jest dokładny dla obwodu RC, a estymator RLS liczy je w każdej sekundzie z prądu i napięcia. W trzydziestej minucie testu rezystancje rosną skokowo o trzydzieści procent, co odpowiada spadkowi temperatury albo starzeniu. Estymator z zapominaniem dochodzi do 23,2 miliomów przy prawdziwej wartości 23,3. Bez zapominania zostaje na 19,9, bo uśrednia całą historię. Wniosek: estymator bez zapominania nigdy nie zauważy starzenia baterii.

### Slajd 18. Metoda wieloskalowa: dwa dni reprezentują miesiąc

**Paweł Fortuna:** Przechodzę do symulacji dziesięciu lat. Nie da się liczyć dziesięciu lat z krokiem jednej sekundy, dlatego stosujemy metodę wieloskalową. W każdym miesiącu symulujemy dwa reprezentatywne dni. Pierwszy to dzień roboczy: dwa dojazdy po pół godziny, praca bez ładowarki i wieczór w domu z wallboxem. Drugi to dzień w trasie: 150 kilometrów autostradą, szybkie ładowanie i powrót. Stres starzenia mnożymy przez liczbę dni w miesiącu, aktualizujemy SOH, a nowe SOH zmienia pojemność i rezystancję w kolejnym miesiącu. Każda strategia przejeżdża dokładnie ten sam dystans. Porównujemy trzy klimaty: Opole, Madryt i Dubaj.

### Slajd 19. Stan zdrowia baterii: 4 strategie w 3 klimatach

**Paweł Fortuna:** Oto główny wynik projektu. W Opolu cel spełnia każda strategia, bo chłodny klimat sam chroni baterię. W Madrycie odpada ładowanie do stu procent: 79,1 procent. Już ograniczenie do dziewięćdziesięciu daje 82,3, a LIFE 85,2 procent. W Dubaju typowy BMS kończy z 69,2 procent, wersja z limitem dziewięćdziesięciu procent z 72,5, LIFE z 78,3. Dopiero pętla adaptacyjna utrzymuje 80,8 procent. Linia kropkowana to trajektoria odniesienia, którą śledzi regulator nadrzędny.

### Slajd 20. Składniki utraty pojemności po 10 latach

**Paweł Fortuna:** Skąd się bierze utrata pojemności? Pomarańczowa część to starzenie kalendarzowe, niebieska cykliczne, czerwona litowanie. W gorącym klimacie dominuje starzenie kalendarzowe: w Dubaju przy ładowaniu do stu procent to 19,8 punktu procentowego. Pętla adaptacyjna zmniejsza je do 11,0. W zimnym klimacie problemem jest litowanie: w Opolu typowy BMS traci 3,8 punktu przez zimowe ładowanie do stu procent. Część cykliczna jest prawie stała, bo zależy głównie od przejechanych kilometrów. Strategia LIFE nie lituje anody w żadnym klimacie.

### Slajd 21. Poziom ochrony λ rośnie tylko wtedy, gdy jest to potrzebne

**Paweł Fortuna:** Tak działa pętla adaptacyjna. Lewy wykres to poziom ochrony lambda. W Opolu i Madrycie bateria starzeje się wolniej niż plan, więc lambda spada do zera, a kierowca może ładować do 85 procent. Pętla oddaje nadwyżkę zdrowia jako komfort. W Dubaju uchyb staje się ujemny już w drugim roku, lambda rośnie i po około czterech latach osiąga jeden. To klasyczne nasycenie elementu wykonawczego: regulator robi wszystko, co może, i dlatego cel z zapasem, czyli 82 procent, jest nieosiągalny. Granica 80 procent zostaje jednak dotrzymana.

### Slajd 22. Energia, zasięg i czas ładowania

**Paweł Fortuna:** Uczciwy bilans kosztów. Lewy wykres to energia zarządzania termicznego. W Dubaju pętla adaptacyjna zużywa 396 kWh rocznie, głównie na chłodzenie zaparkowanego auta podłączonego do sieci. To około dziesięciu procent energii jazdy. Środkowy wykres pokazuje średni SOC, czyli zapas zasięgu: w Dubaju spada do około sześćdziesięciu procent. Prawy pokazuje średni czas szybkiego ładowania w trasie: 34 minuty, bo pętla obniża prąd. Ten czas zależy też od SOC przy przyjeździe. W klimacie umiarkowanym koszty są pomijalne.

### Slajd 23. Sprzężenie od SOH kompensuje błędy modelu starzenia

**Paweł Fortuna:** To najważniejszy wynik z punktu widzenia sterowania odpornego. Model starzenia jest niepewny, więc losujemy pięćdziesiąt pakietów. Zmieniamy współczynniki starzenia, rezystancje, przewodności cieplne i klimat. Losujemy nawet kształt krzywej degradacji. Regulator zna tylko wartości nominalne. Typowy BMS spełnia cel w 72 procentach przypadków, LIFE w 92, a LIFE-ADAPT w 96 procentach. Odchylenie standardowe maleje z 4,1 do 3,0 punktu procentowego, a najgorszy przypadek rośnie z 69,0 do 78,5 procent. Sprzężenie zwrotne od zmierzonego SOH kompensuje błędy modelu.

### Slajd 24. NASA B0005: degradacja bliższa liniowej niż pierwiastkowej

**Paweł Fortuna:** Model porównaliśmy z prawdziwymi danymi NASA dla ogniwa B0005. Dopasowujemy model potęgowy na siedemdziesięciu procentach cykli i prognozujemy pozostałe trzydzieści, tak jak przy identyfikacji. Model liniowy ma błąd testowy 32 mAh, pierwiastkowy 81 mAh. Ciekawe, że najlepiej dopasowany wykładnik 1,54 prognozuje najgorzej, z błędem 138 mAh, to klasyczne przeuczenie. Widać też skoki pojemności po przerwach w cyklowaniu. Prawdziwe ogniwo nie musi więc trzymać się założonego kształtu. Dlatego Monte Carlo obejmuje oba warianty, a pętla adaptacyjna reaguje na pomiar, a nie na model.

### Slajd 25. Niezależny model blokowy potwierdza wyniki

**Paweł Fortuna:** Wyniki sprawdziliśmy drugą, niezależną implementacją w postaci modelu blokowego w Simulinku. Harmonogram nastaw jest w nim tablicą k od rho, a stany przechowują elementy opóźnienia. Sesja przy zerze stopni trwa w obu implementacjach 1544 kroków, a największa różnica temperatury rdzenia wynosi 5e-7 kelwina. Wynika ona wyłącznie z interpolacji tablicy harmonogramu. Wyniki nie zależą więc od sposobu implementacji algorytmu.

### Slajd 26. Ograniczenia modelu i sposób ich weryfikacji

**Paweł Fortuna:** Krytyczna ocena. Współczynniki starzenia pochodzą z literatury, a nie z badań tego konkretnego ogniwa. Pakiet modelujemy jako jedno uśrednione ogniwo, bez rozrzutu parametrów. Litowanie opisujemy modelem progowym, a nie pełnym modelem elektrochemicznym. Klimat to sinusoida bez nasłonecznienia. Jak się przed tym bronimy? Model przechodzi weryfikację numeryczną: bilans energii i ładunku, zbieżność względem kroku, ograniczenie napięcia i zbieżność obserwatora. Do tego Monte Carlo z dwoma kształtami degradacji, dane NASA i przede wszystkim pętla reagująca na zmierzone SOH. Liczby służą do porównania strategii, a wartości bezwzględne wymagają kalibracji na konkretnym ogniwie. Oddaję głos Karolowi.

### Slajd 27. Wnioski

**Karol Fabianek:** Podsumujmy w sześciu punktach. Po pierwsze, dominujący mechanizm starzenia zależy od klimatu: w gorącym jest to starzenie kalendarzowe, w zimnym litowanie anody. Po drugie, sposób ładowania ma większy wpływ niż samo chłodzenie: niższy docelowy SOC i ładowanie kończone przed wyjazdem podnoszą SOH w Madrycie o ponad sześć punktów procentowych. Po trzecie, temperatura szybkiego ładowania ma optimum, a podgrzanie skraca ładowanie zimą ponad dwukrotnie bez litowania. Po czwarte, gain scheduling utrzymuje stałą dynamikę pętli chłodzenia w całym zakresie pracy. Po piąte, sprzężenie od zmierzonego SOH czyni wynik odpornym na błędy modelu starzenia. Po szóste, w gorącym klimacie pętla osiąga nasycenie, więc wymaganie 80 procent jest spełnione, ale bez zapasu i kosztem energii chłodzenia.

### Slajd 28. Bibliografia

**Karol Fabianek:** Na slajdzie jest literatura, na której oparliśmy model i metody. Najważniejsze pozycje to model starzenia Schmalstiega, badania temperaturowe Waldmanna, model anody Doyle'a, a od strony sterowania prace Rugha i Shammy o gain schedulingu oraz podręcznik Åströma i Wittenmarka.

### Slajd 29. Dziękujemy za uwagę

**Karol Fabianek:** Dziękujemy za uwagę. Chętnie odpowiemy na pytania.

