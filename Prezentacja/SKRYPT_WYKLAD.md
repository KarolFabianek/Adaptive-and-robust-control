# Skrypt wystąpienia: wykład

**Zarządzanie termiczne baterią pojazdu elektrycznego z zastosowaniem Gain Scheduling**

Karol Fabianek, Paweł Fortuna. Sterowanie adaptacyjne i odporne, Politechnika Opolska, WEAiI.

Plik prezentacji: `BTMS_WYKLAD_FABIANEK_FORTUNA.pptx`, 27 slajdów, czas wystąpienia około 15 min przy tempie 130 słów na minutę. Ten sam tekst jest w notatkach prelegenta w pliku .pptx (widok prezentera).

## Podział na osoby

| Osoba | Slajdy | Liczba slajdów | Czas mówienia |
|---|---|---:|---:|
| Karol Fabianek | 1-10, 19-22 | 14 | około 8 min |
| Paweł Fortuna | 11-18, 23-27 | 13 | około 7 min |

## Kolejność wystąpienia

- slajdy 1-10: Karol Fabianek
- slajdy 11-18: Paweł Fortuna
- slajdy 19-22: Karol Fabianek
- slajdy 23-27: Paweł Fortuna

## Tekst slajd po slajdzie

### Slajd 1. Zarządzanie termiczne baterią pojazdu elektrycznego z zastosowaniem Gain Scheduling

**Mówi: Karol Fabianek**

Dzień dobry. Nazywam się Karol Fabianek, a to Paweł Fortuna. Tematem wykładu jest zarządzanie termiczne baterią pojazdu elektrycznego z zastosowaniem gain schedulingu, czyli harmonogramowania nastaw regulatora. Pokażemy, dlaczego bateria potrzebuje aktywnego układu termicznego, jak wygląda jej model i jak zbudować regulator, którego nastawy zmieniają się wraz z punktem pracy. Na końcu pokażemy, jak te mechanizmy wpływają na trwałość baterii w horyzoncie dziesięciu lat.

### Slajd 2. Gain Scheduling w zarządzaniu temperaturą baterii EV

**Mówi: Karol Fabianek**

Plan ma pięć części. Najpierw problem: po co sterować temperaturą baterii. Potem obiekt: pakiet i jego model elektryczny, cieplny oraz model anody. W trzeciej części Paweł omówi regulator z harmonogramem nastaw, anti-windup i nadzór prądu. Następnie pokażę przykłady symulacyjne przy 25 i 35 stopniach. Na końcu Paweł przedstawi ograniczenia modelu i wyniki długoterminowe.

### Slajd 3. Dlaczego bateria EV potrzebuje BTMS?

**Mówi: Karol Fabianek**

Dlaczego bateria potrzebuje układu BTMS? Szybkie ładowanie to duży prąd, a straty Joule'a rosną z kwadratem prądu. Temperatura decyduje o bezpieczeństwie i o tempie starzenia. Chłodzenie nie jest darmowe, bo pompa i sprężarka pobierają energię. Ograniczenie prądu zmniejsza ciepło, ale wydłuża ładowanie. Schemat pokazuje dwa kanały sterowania: sterownik zmienia prąd ładowarki i wydajność chłodzenia. Sterownik szuka więc kompromisu między czasem ładowania, temperaturą, energią chłodzenia i trwałością.

### Slajd 4. Pakiet referencyjny Li-ion 96s50p

**Mówi: Karol Fabianek**

Obiektem jest referencyjny pakiet 96s50p. Pięćdziesiąt ogniw łączymy równolegle w sekcję, a dziewięćdziesiąt sześć sekcji szeregowo, razem 4800 ogniw typu 18650. Daje to 345,6 V, 175 Ah, 60,48 kWh i rezystancję 53,76 miliomów. Zasada jest prosta: połączenie szeregowe zwiększa napięcie i rezystancję, a równoległe pojemność i zmniejsza rezystancję. Parametry ogniwa są założeniem projektowym, a nie danymi konkretnego producenta. Rezystancję ogniwa, 28 miliomów, dzielimy na część omową, 18 miliomów, i polaryzacyjną z gałęzią RC o stałej czasowej 40 sekund.

### Slajd 5. Model dwuwęzłowy: rdzeń i powierzchnia

**Mówi: Karol Fabianek**

Model cieplny ma dwa węzły: rdzeń i powierzchnię. Ciepło powstaje w rdzeniu jako straty I kwadrat R. Przez przewodność między rdzeniem a powierzchnią płynie do powierzchni, a tam odbiera je otoczenie i układ chłodzenia. Pojemność cieplną pakietu dzielimy: 76 procent na rdzeń i 24 procent na powierzchnię. To ważne dla sterowania, bo chłodzenie działa na powierzchnię, a ciepło powstaje w rdzeniu. Przy 300 amperach rdzeń jest około 3 kelwiny cieplejszy od powierzchni. Równania całkujemy niejawną metodą Eulera, która jest stabilna przy każdym kroku.

### Slajd 6. Straty rosną z kwadratem prądu, rezystancja rośnie w zimnie

**Mówi: Karol Fabianek**

Źródłem ciepła są straty. Lewy wykres pokazuje, że rosną z kwadratem prądu: dwa razy większy prąd to około cztery razy więcej ciepła. Przy 300 amperach to około 4,8 kilowata. Jeśli ograniczymy prąd do 210 amperów, ciepła jest o około 51 procent mniej. Prawy wykres pokazuje rezystancję w funkcji temperatury. Opisujemy ją prawem Arrheniusa, więc w zerze stopni jest ponad dwukrotnie większa niż w 25 stopniach. Linia przerywana to prosty model liniowy, który w zimnie wyraźnie ją zaniża.

### Slajd 7. Anoda pracuje tylko około 100 mV nad potencjałem litu

**Mówi: Karol Fabianek**

Pierwsza ciekawostka. Anoda grafitowa przy wysokim stanie naładowania pracuje tylko około stu miliwoltów nad potencjałem metalicznego litu. Podczas ładowania spadek napięcia na rezystancji anody obniża ten potencjał. Gdy zejdzie poniżej zera, lit osadza się na powierzchni grafitu zamiast w nim. Część tego litu traci się bezpowrotnie, a w skrajnych przypadkach rosną dendryty. Mapa pokazuje największy bezpieczny prąd: przy 80 procent SOC to 1,85C w 25 stopniach i tylko 0,29C w zerze. Wniosek: temperatura decyduje nie tylko o bezpieczeństwie, ale też o dopuszczalnym prądzie, więc BTMS musi umieć grzać.

### Slajd 8. Ograniczona moc chłodzenia i nasycenie

**Mówi: Karol Fabianek**

Elementem wykonawczym jest układ chłodzenia cieczą z chillerem oraz grzałka. Sygnał sterujący przyjmuje wartości od minus jeden do jeden: ujemne oznaczają grzanie, dodatnie chłodzenie. Odbiór ciepła wynosi Gcool razy u razy różnica temperatur powierzchni i cieczy, ale nie więcej niż 6,5 kilowata. Wykres pokazuje to nasycenie dla trzech wartości sterowania. Kluczowa obserwacja dla sterowania: pochodna odbioru ciepła po sterowaniu zależy od temperatury powierzchni. Wzmocnienie obiektu zmienia się więc z punktem pracy, a różnica Ts minus temperatura cieczy staje się zmienną harmonogramu.

### Slajd 9. Ładowanie CC-CV od 20 do 80% SOC

**Mówi: Karol Fabianek**

Ładowanie modelujemy w pełnym schemacie CC-CV. Najpierw ładujemy stałym prądem do 300 amperów, czyli około 1,7C. Gdy napięcie ogniwa dojdzie do 4,2 V, przechodzimy na stałe napięcie, a ładowanie kończy się przy prądzie spadającym poniżej C/20. Lewy wykres to krzywa napięcia obwodu otwartego, prawy to potencjał anody. Ten sam stan naładowania zmienia więc napięcie i bezpieczny prąd. Czas ładowania od 20 do 80 procent jest jednym z mierników jakości strategii.

### Slajd 10. Cztery konkurujące kryteria

**Mówi: Karol Fabianek**

Mamy cztery konkurujące kryteria. Temperatura rdzenia ma być niższa niż 40 stopni. Czas ładowania od 20 do 80 procent ma być możliwie krótki. Energia chłodzenia na sesję ma być możliwie mała. Stan zdrowia baterii po dziesięciu latach ma wynosić co najmniej 80 procent. Porównujemy strategie w dwóch skalach: w pojedynczej sesji ładowania i w dziesięcioletniej eksploatacji w trzech klimatach. Nie ma strategii najlepszej we wszystkim, więc oceniamy kompromisy. Teraz Paweł omówi regulator.

### Slajd 11. Nastawy PI zależne od punktu pracy

**Mówi: Paweł Fortuna** (zmiana prowadzącego)

Dziękuję. Jak już powiedział Karol, wzmocnienie chłodzenia maleje, gdy powierzchnia stygnie, bo maleje różnica temperatur rho. Regulator o stałych nastawach dobrany dla gorącego dnia będzie więc zbyt wolny w chłodny dzień. Gain scheduling rozwiązuje to w prosty sposób. Nastawy PI mnożymy przez współczynnik k równy 17 przez rho, ograniczony do przedziału od 1 do 3. Wykresy pokazują Kp i Ki w funkcji rho. To adaptacja w torze otwartym: nie identyfikujemy modelu online, tylko korzystamy ze znanej fizyki chłodzenia i mierzalnej temperatury powierzchni.

### Slajd 12. Dobór nastaw i weryfikacja harmonogramu

**Mówi: Paweł Fortuna**

Jak dobraliśmy nastawy? Regulator PI dostroiliśmy w punkcie projektowym: rho równe 17 kelwinów, czyli 35 stopni powierzchni przy 18 stopniach cieczy. Harmonogram utrzymuje stały iloczyn Kp razy Gcool razy rho, czyli stałe wzmocnienie pętli otwartej. Trzy karty pokazują nastawy w trzech punktach pracy. Co potwierdziła analiza? Pulsacja odcięcia GS pozostaje stała, 2,61 miliradiana na sekundę, a PI przy 6 kelwinach spada do 0,88. We wszystkich 33 punktach pracy bieguny są stabilne. Uczciwie zaznaczamy, czego nie mamy: formalnego dowodu stabilności LPV. Analiza jest lokalna, co jest uzasadnione, bo rho zmienia się wolno w porównaniu z dynamiką pętli.

### Slajd 13. Regulator PI z anti-windupem i sprzężeniem w przód

**Mówi: Paweł Fortuna**

Struktura regulatora. Mierzymy temperaturę powierzchni i prąd. Temperaturę rdzenia, której nie da się zmierzyć, estymuje obserwator. Harmonogram wylicza nastawy, regulator PI liczy sterowanie, a chłodzenie oddziałuje na pakiet. Mamy działanie odwrotne: gdy temperatura rośnie, uchyb jest dodatni i chłodzenia jest więcej. Anti-windup zatrzymuje całkowanie, gdy pogłębiałoby nasycenie, czyli gdy chłodzenie pracuje już na sto procent. Feedforward reaguje na obliczone straty I kwadrat R, zanim temperatura w ogóle wzrośnie. To trzy różne mechanizmy, więc nie przypisujemy ich efektów samemu gain schedulingowi.

### Slajd 14. Nadzór prądu jako drugi kanał sterowania

**Mówi: Paweł Fortuna**

Temperaturą możemy sterować na dwa sposoby. Chłodzenie zwiększa odbiór ciepła, a redukcja prądu zmniejsza jego wytwarzanie. Oba kanały mają inne koszty: chłodzenie kosztuje energię, a redukcja prądu, czas kierowcy. Nadzór termiczny włącza się dopiero przy 36,5 stopnia i liniowo redukuje prąd do 110 amperów przy 39,5 stopnia. Typowy BMS ma dodatkowo statyczną tablicę prądów dla niskich temperatur. W naszej strategii LIFE dochodzi limit z potencjału anody, który sam maleje w zimnie i przy wysokim SOC.

### Slajd 15. Sześć warstw ograniczenia prądu ładowania

**Mówi: Paweł Fortuna**

Wszystkie te ograniczenia łączymy w jeden wzór: zadany prąd to minimum sześciu limitów. Pierwszy to profil SOC z redukcją po 70 procentach. Drugi to nadzór termiczny. Trzeci to tablica typowego BMS. Czwarty to limit anody wyliczany z modelu, a nie z tablicy. Piąty to faza CV. Szósty to poziom ochrony z nadrzędnej pętli zdrowia baterii, który działa w skali miesięcy. Ograniczenie prądu jest niezależne od gain schedulingu, a każda warstwa chroni przed innym mechanizmem.

### Slajd 16. Zużycie baterii ma minimum w funkcji temperatury ładowania

**Mówi: Paweł Fortuna**

Druga ciekawostka: zużycie baterii na jedno ładowanie ma minimum w funkcji temperatury. To tak zwany kształt V. Lewe ramię to litowanie anody w zimnie, prawe to wzrost warstwy SEI w cieple. Optimum przesuwa się z prądem: dla 0,5C to około 5 stopni, dla 1C około 14, dla 1,71C około 22 stopni. Taki przebieg potwierdzają badania post-mortem Waldmanna z 2014 roku. Wniosek dla układu sterowania: BTMS nie tylko chłodzi, ale przed szybkim ładowaniem zimą powinien baterię podgrzać.

### Slajd 17. Każda strategia dodaje jeden mechanizm

**Mówi: Paweł Fortuna**

Porównujemy warianty, z których każdy dodaje jeden mechanizm. Punktem odniesienia jest CC, czyli stałe chłodzenie bez regulatora. Następnie regulator PI o stałych nastawach i GS z harmonogramem. GS-SAFE dodaje feedforward i nadzór prądu. STD to typowy BMS z tablicą prądów, który w domu ładuje od razu do 90 lub 100 procent. LIFE i LIFE-ADAPT to proponowane strategie ochrony baterii. Pierwsze cztery warianty porównują regulatory chłodzenia, a dwa ostatnie politykę ładowania.

### Slajd 18. Dwie skale badań: sesja ładowania i 10 lat

**Mówi: Paweł Fortuna**

Eksperyment ma dwie skale. Pierwsza to pojedyncza sesja szybkiego ładowania: sześć strategii w sześciu temperaturach od minus dziesięciu do czterdziestu stopni, z krokiem jednej sekundy. Druga to dziesięć lat eksploatacji: cztery strategie w trzech klimatach, Opole, Madryt i Dubaj. Klimaty modelujemy jako sinusoidę roczną i dobową. To kontrolowane scenariusze porównawcze, a nie rzeczywiste dane pogodowe. Mierzymy maksymalną temperaturę rdzenia, czas ładowania, energię chłodzenia i stan zdrowia po dziesięciu latach. Wyniki pokaże Karol.

### Slajd 19. Temperatura rdzenia i prąd ładowania przy 35°C

**Mówi: Karol Fabianek** (zmiana prowadzącego)

Sesja ładowania przy 35 stopniach. Bez regulatora rdzeń osiąga 43,7 stopnia i przekracza kryterium czterdziestu stopni po kilku minutach. Regulator PI trzyma 36,2, GS 35,9, a GS z feedforwardem 35,1 stopnia. Wszystkie te warianty nie wydłużają ładowania. Prawy wykres pokazuje prąd. Warianty z profilem SOC zaczynają redukować prąd po 70 procentach. Strategia LIFE nie ma sztywnego profilu i ładuje pełnym prądem do końca, bo potencjał anody w tej temperaturze na to pozwala.

### Slajd 20. Temperatura i czas ładowania przy 35°C

**Mówi: Karol Fabianek**

Ten slajd zestawia maksymalne temperatury przy 35 stopniach i ładowaniu od 20 do 80 procent. Strategie z regulatorem mieszczą się w okolicy 36 stopni. Kryterium czterdziestu stopni przekracza tylko wariant bez regulatora: 45,1 stopnia. Typowy BMS ładuje się 22,7 minuty. LIFE jest najchłodniejszy, 32,3 stopnia, bo chłodzi pakiet już w drodze do ładowarki, i najszybszy: 21,0 minuty. To wyniki modelu, a nie pomiary pojazdu.

### Slajd 21. PI i GS bez nadzoru prądu przy 25°C

**Mówi: Karol Fabianek**

Uczciwe porównanie PI i GS bez nadzoru prądu i bez feedforwardu. Przy 25 stopniach PI osiąga 35,29, a GS 34,71 stopnia przy tym samym czasie ładowania. Wykres pokazuje sygnał chłodzenia: GS reaguje wcześniej i mocniej, bo w chłodniejszym punkcie pracy ma większe nastawy. Przy 15 stopniach różnica wynosi −0,37 kelwina. W punkcie projektowym, przy 35 stopniach, oba regulatory są praktycznie równe. Dokładnie tego oczekujemy od harmonogramu nastaw.

### Slajd 22. Bateria starzeje się także na postoju

**Mówi: Karol Fabianek**

Ostatnia ciekawostka: bateria starzeje się także wtedy, gdy auto stoi. Mapa pokazuje utratę pojemności po dziesięciu latach samego postoju w stałych warunkach. Postój przy stu procentach SOC przyspiesza starzenie około 2,2 raza w porównaniu z pięćdziesięcioma procentami. Każde dziesięć stopni przyspiesza je mniej więcej dwukrotnie. W Dubaju przy codziennym ładowaniu do stu procent sam postój zabiera 19,8 procent pojemności w dziesięć lat. O trwałości decyduje więc także sposób postoju baterii. Teraz Paweł przedstawi ograniczenia modelu i wyniki długoterminowe.

### Slajd 23. Ograniczenia modelu

**Mówi: Paweł Fortuna** (zmiana prowadzącego)

Krytyczna ocena modelu. W części elektryczno-cieplnej pakiet to jedno uśrednione ogniwo, bez rozrzutu parametrów. Zamiast modelu elektrochemicznego używamy obwodu zastępczego, a litowanie opisujemy modelem progowym. Przewodności cieplne pochodzą z literatury, a klimat to sinusoida bez nasłonecznienia. W modelu starzenia współczynniki są literaturowe, a składowe sumujemy, co też jest założeniem. Kształt degradacji jest niepewny, bo dane NASA wskazują raczej na przebieg liniowy. Dlatego stosujemy analizę Monte Carlo i pętlę sprzężenia od zmierzonego SOH. Model nadaje się do porównywania strategii, ale nie do prognozy dla konkretnego pakietu.

### Slajd 24. Trwałość baterii w horyzoncie 10 lat

**Mówi: Paweł Fortuna**

Wyniki w horyzoncie dziesięciu lat. W Dubaju typowy BMS kończy z 69,2 procent SOH, a strategia z pętlą adaptacyjną z 80,8 procent. W analizie odporności losujemy pięćdziesiąt pakietów o różnych parametrach starzenia, rezystancji i klimatu. Wymaganie spełnia 72 procent pakietów z typowym BMS i 96 procent z pętlą adaptacyjną, a rozrzut SOH maleje. Dane NASA wskazują, że rzeczywista degradacja jest bliższa liniowej, a niezależny model blokowy potwierdza wyniki. Sprzężenie od zmierzonego SOH kompensuje więc błędy modelu, co jest istotą sterowania odpornego.

### Slajd 25. Wnioski

**Mówi: Paweł Fortuna**

Wnioski z wykładu. Po pierwsze: regulator jest konieczny, bez niego rdzeń przy 35 stopniach przekracza 43 stopnie. Po drugie: gain scheduling według różnicy Ts minus temperatura cieczy kompensuje zmienne wzmocnienie chłodzenia i daje przy 25 stopniach około 0,6 kelwina zysku. Po trzecie: temperatura to nie tylko chłodzenie, zimą BTMS musi grzać, bo litowanie ogranicza bezpieczny prąd ponad sześciokrotnie. Po czwarte: trwałość zależy też od postoju, czyli od okna SOC i temperatury, w której bateria stoi.

### Slajd 26. Bibliografia

**Mówi: Paweł Fortuna**

Na slajdzie jest literatura, na której oparliśmy wykład. Teoria gain schedulingu pochodzi z pracy Rugha i Shammy oraz podręczników Åströma. Model baterii i jej zarządzania opieramy na monografii Pletta. Modele starzenia i litowania pochodzą z prac Schmalstiega, Waldmanna i Doyle'a. Parametry cieplne ogniwa pochodzą z pracy Lina i raportu Bhundiyi.

### Slajd 27. Dziękujemy za uwagę

**Mówi: Paweł Fortuna**

Dziękujemy za uwagę. Zapraszamy do pytań.

