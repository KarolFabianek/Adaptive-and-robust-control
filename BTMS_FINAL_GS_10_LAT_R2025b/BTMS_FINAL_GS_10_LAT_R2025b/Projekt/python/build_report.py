"""Create project report DOCX (LEGACY generator of an older report version).
Aktualny raport: Dokumentacja/RAPORT_TECHNICZNY.pdf. Fragmenty o NASA zaktualizowano po przegladzie;
pozostale teksty opisowe sa NIEAKTUALNE po rundzie 2 (Gcs=1650 W/K, GS po Ts-Tcool) - nie uzywac do prezentacji wynikow."""
from pathlib import Path
import pandas as pd
from docx import Document
from docx.shared import Cm,Pt,RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT,WD_CELL_VERTICAL_ALIGNMENT
from docx.enum.text import WD_BREAK
from docx.enum.style import WD_STYLE_TYPE
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
ROOT=Path(__file__).resolve().parents[1]; RESULTS=ROOT/'results'; FIG=ROOT/'figures';OUT=ROOT/'report'
OUT.mkdir(exist_ok=True)
s=pd.read_csv(RESULTS/'sessions_summary.csv'); life=pd.read_csv(RESULTS/'life_summary.csv');rob=pd.read_csv(RESULTS/'robustness_35C.csv')
C_DARK=RGBColor(13,29,45);C_TEAL=RGBColor(0,131,119);C_MUTED=RGBColor(93,112,127)
d=Document();sec=d.sections[0];sec.top_margin=Cm(2.1);sec.bottom_margin=Cm(1.8);sec.left_margin=Cm(2.35);sec.right_margin=Cm(2.25)
styles=d.styles;norm=styles['Normal'];norm.font.name='Aptos';norm.font.size=Pt(10);norm.font.color.rgb=C_DARK;norm.paragraph_format.space_after=Pt(7)
for name,size,bold,color in [('Title',28,True,C_DARK),('Heading 1',17,True,C_DARK),('Heading 2',12.5,True,C_TEAL),('Subtitle',12,False,C_MUTED)]:
 st=styles[name];st.font.name='Aptos Display';st.font.size=Pt(size);st.font.bold=bold;st.font.color.rgb=color;st.paragraph_format.space_before=Pt(12 if name.startswith('Heading') else 4);st.paragraph_format.space_after=Pt(6)
if 'SmallLabel' not in styles:
 st=styles.add_style('SmallLabel',WD_STYLE_TYPE.PARAGRAPH);st.font.name='Aptos';st.font.size=Pt(8);st.font.bold=True;st.font.color.rgb=C_TEAL
# Running header/footer
h=sec.header.paragraphs[0];h.text='BTMS   /   STEROWANIE ADAPTACYJNE I ODPORNE';h.style='SmallLabel'
f=sec.footer.paragraphs[0];f.text='POLITECHNIKA OPOLSKA   •   PROJEKT MODELOWY   •   2026';f.style='SmallLabel';f.alignment=WD_ALIGN_PARAGRAPH.CENTER

def p(x='',style=None):return d.add_paragraph(x,style)
def H(x):d.add_heading(x,level=1)
def h2(x):d.add_heading(x,level=2)
def bullets(items):
 for x in items: d.add_paragraph(x,'List Bullet')
def fig(file,caption,width=15.7):
 d.add_picture(str(FIG/file),width=Cm(width)); pp=d.add_paragraph(caption);pp.style='Caption';pp.alignment=WD_ALIGN_PARAGRAPH.CENTER

def tab(headers,rows,widths=None):
 t=d.add_table(rows=1,cols=len(headers));t.style='Light Shading Accent 1';t.alignment=WD_TABLE_ALIGNMENT.CENTER
 for i,x in enumerate(headers):t.rows[0].cells[i].text=str(x)
 for row in rows:
  c=t.add_row().cells
  for i,x in enumerate(row):c[i].text=str(x)
 for row in t.rows:
  for c in row.cells:
   c.vertical_alignment=WD_CELL_VERTICAL_ALIGNMENT.CENTER
   for pp in c.paragraphs:
    pp.paragraph_format.space_after=Pt(2)
    for run in pp.runs:run.font.size=Pt(8.8)
 return t

def newpage():d.add_page_break()

# cover
p('RAPORT PROJEKTOWY  /  WERSJA REPRODUKOWALNA','SmallLabel')
p('Zarządzanie termiczne\nbaterią pojazdu elektrycznego','Title')
p('Sterowanie PI i Gain Scheduling, nadzór prądu, ocena trwałości oraz analiza danych NASA PCoE','Subtitle')
p('')
p('Autorzy: inż. Karol Fabianek, inż. Paweł Fortuna')
p('Przedmiot: Sterowanie adaptacyjne i odporne')
p('Politechnika Opolska · Wydział Elektrotechniki, Automatyki i Informatyki')
p('Data opracowania: 15 listopada 2026')
p('')
p('STATUS NAUKOWY','SmallLabel')
p('Model dydaktyczny i wyniki jego nowej, jawnej implementacji. Nie są to pomiary baterii EV. Moduł NASA analizuje oryginalny plik B0005.mat (pojemności ogniwa 18650), co nie jest walidacją pakietu EV ani modelu termicznego.')
fig('01_temperature_35C.png','Rys. 1. Przebieg temperatury w symulacji dla temperatury otoczenia 35°C.',14.5)
newpage();H('Streszczenie i najważniejszy wynik')
p('Opracowano replikowalny model dwuwęzłowy baterii 96s50p (60,48 kWh nominalnie), regulator chłodzenia PI, wariant Gain Scheduling (GS) z nastawami jako funkcjami SOC, anti-windup, feedforward od I²R oraz nadrzędny ogranicznik prądu. Dla ośmiu strategii i trzech warunków otoczenia uruchomiono 24 sesje ładowania oraz scenariuszową ocenę SOH po dziesięciu latach. Przeprowadzono również 162 testy niepewności dla wersji SAFE i prostą analizę jakobianów zamrożonego modelu.')
v=lambda st: s[(s.strategy==st)&(s.ambient_C==35)].iloc[0]
PI=v('PI');GS=v('GS');SAFE=v('GS_SAFE');LIFE=v('GS_LIFE')
ls=life[life.strategy=='GS_LIFE'].sort_values('ambient_C')
tab(['Wskaźnik · 35°C','PI','GS','GS_SAFE','GS_LIFE'],[
 ['Czas [min]',f'{PI.time_min:.1f}',f'{GS.time_min:.1f}',f'{SAFE.time_min:.1f}',f'{LIFE.time_min:.1f}'],
 ['Tc,max [°C]',f'{PI.Tmax_C:.1f}',f'{GS.Tmax_C:.1f}',f'{SAFE.Tmax_C:.1f}',f'{LIFE.Tmax_C:.1f}'],
 ['Energia chłodzenia [kWh]',f'{PI.energy_aux_kWh:.2f}',f'{GS.energy_aux_kWh:.2f}',f'{SAFE.energy_aux_kWh:.2f}',f'{LIFE.energy_aux_kWh:.2f}']])
p('W najgorętszym rozważanym wariancie zmiana PI → GS bez nadzoru prądu nie utrzymuje temperatury poniżej 40°C. Nadzór termiczny zmniejsza maksimum do około 38°C kosztem dłuższego ładowania. W modelowej prognozie GS_LIFE uzyskuje po 10 latach: '+', '.join(f'{r.ambient_C:.0f}°C → {r.SOH_10y_pct:.1f}%' for _,r in ls.iterrows())+'. Te wartości są wyłącznie funkcją przyjętego modelu starzenia i harmonogramu użytkowania.')
h2('Jak czytać ten projekt?')
bullets(['Kod MATLAB jest podstawowym, edytowalnym artefaktem projektu; Python stanowi niezależny skrypt referencyjny do wygenerowania wyników oraz wykresów.','Wyniki nowej implementacji nie muszą pokrywać się ze starszą prezentacją BTMS, ponieważ wcześniejsze pliki implementacji nie były dostępne.','Nie wykonano rzeczywistej walidacji pakietu EV; porównanie NASA, jeśli zostanie uruchomione, dotyczy wyłącznie krzywej pojemności małych ogniw.'])

H('1. Cel i kryteria jakości')
p('Zaprojektować układ chłodzenia i ochrony termicznej, który w trakcie ładowania od SOC 25% do 80% zarządza kompromisem między temperaturą rdzenia, czasem ładowania, energią pomocniczą i scenariuszową trwałością.')
tab(['Kryterium','Definicja','Interpretacja'],[
 ['Temperatura','Tc,max ≤ 40°C','Granica projektowa, nie uniwersalna norma ogniw'],
 ['Czas','min t(25→80% SOC)','Podany w minutach, funkcja profilu prądu'],
 ['Chłodzenie','min ∫Paux dt [kWh]','Pompa + sprężarka/chiller'],
 ['Trwałość','SOH ≥ 80% po 10 latach','Umowna granica projektu, wynik scenariuszowy']])
H('2. Model baterii i uproszczenia')
tab(['Wielkość','Wartość','Pochodzenie'],[
 ['Konfiguracja','96s50p = 4800 ogniw','Założenie projektowe'],
 ['Napięcie','345,6 V','96 × 3,6 V'],['Pojemność','175 Ah','50 × 3,5 Ah'],
 ['Energia','60,48 kWh','Un × Qn'],['Rezystancja nominalna','53,76 mΩ','96 × 28 mΩ / 50'],
 ['Pojemności cieplne','Cc = 157,6 kJ/K, Cs = 49,8 kJ/K','Masa × cp, podział 76/24%'],
 ['Wymiana ciepła','Gcs = 165 W/K; Gamb = 25 W/K','Założone wartości zastępcze']])
p('Równania stanu: Cc · dTc/dt = I²R(SOC,Tc) − Gcs(Tc−Ts);  Cs · dTs/dt = Gcs(Tc−Ts) − Gamb(Ts−Ta) − Qcool. Przyjęto R = Rn·clip[1 + 0,2(0,5−SOC) + 0,002(25−Tc), 0,7, 1,4].')
p('Nie ma modelu OCV, dynamiki obwodów RC ani kontroli napięcia ogniw. Ograniczenie prądu powyżej 70% SOC nie jest obliczoną fazą CV. Przyjęto jawny Euler, dt=5 s, oraz identyczne ogniwa. Nie należy używać modelu do sterowania rzeczywistą ładowarką bez osobnej walidacji i warstw bezpieczeństwa.')

H('3. Układ chłodzenia i regulator')
p('Sterowanie u ∈ [0;1]. Qcool = max(0, min[6500u, Gcool·u·(Ts−18°C)]) [W]. Moc pomocnicza Paux = 400u³ + Qcool/2,6 [W]. Przy nasyceniu u = 1 wzrost wzmocnienia PI nie zwiększa wydajności chłodzenia.')
p('Uchyb e = Tc − 30°C (temperatura zadana 30°C, granica termiczna 40°C). Prawo regulacji: u = sat(Kp(SOC)e + z + uFF), gdzie uFF = 0,70·I²R/6500. Anti-windup: integrator z jest zamrażany tylko wtedy, gdy uchyb zwiększa nasycenie; w pozostałych przypadkach z(k+1)=z(k)+Ki·dt·e(k).')
h2('Harmonogram nastaw')
p('α = clip[(SOC−0,2)/0,6; 0; 1]; Kp = 0,055+0,035α [K⁻¹]; Ki=(35+25α)·10⁻⁶ [K⁻¹s⁻¹]. Baseline PI: Kp=0,0725 [K⁻¹], Ki=47,5·10⁻⁶ [K⁻¹s⁻¹]. Wartości są założeniami heurystycznymi, nie efektem optymalizacji.')
tab(['SOC','Kp [K⁻¹]','Ki [K⁻¹s⁻¹]'],[['20%','0,055','35·10⁻⁶'],['50%','0,0725','47,5·10⁻⁶'],['80%','0,090','60·10⁻⁶']])
h2('Nadrzędny nadzór prądu')
p('Iprof(SOC): 300 A do 70% SOC, potem liniowo do 130 A przy 80% SOC. Itherm(Tc): 300 A dla Tc ≤ 36,5°C, spadek liniowy do 110 A przy Tc = 39,5°C, dalej 110 A. I = min[Iprof, Itherm, Ilimit, I nieprzekraczający końcowego SOC]. W GS_LIFE Ilimit = 210 A, w pozostałych strategiach 300 A. Wszystkie progi są jawnie zadeklarowane i wymagają weryfikacji doświadczalnej.')
fig('02_current_35C.png','Rys. 2. Porównanie prądów; ogranicznik jest niezależny od harmonogramowania nastaw.',14.5)

H('4. Macierz doświadczeń i metryki')
p('Osiem wariantów: CC (chłodzenie u=0,20), PI, GS, PI_FF, GS_FF, PI_SAFE, GS_SAFE, GS_LIFE. Wersje FF dodają składnik wyprzedzający; SAFE dodają FF oraz ograniczanie prądu; LIFE dodatkowo zmienia limit prądu i przyjęty SOC postoju. Dla każdego z trzech klimatów (15, 25, 35°C) symulowano identyczny zakres SOC, temperaturę początkową równą temperaturze otoczenia i ten sam model baterii.')
p('Mierzono: maksymalną temperaturę rdzenia, czas ładowania, energię pomocniczą, RMSE(Tc−Tref), procent próbek z nasyceniem oraz bilans energii. Zgodność ograniczenia termicznego sprawdzano jako warunek, nie gwarancję dla wszystkich możliwych zaburzeń.')
fig('03_tradeoff.png','Rys. 3. Czas versus maksimum temperatury dla ośmiu strategii, Ta=35°C.',14.5)
fig('04_aux_energy.png','Rys. 4. Koszt chłodzenia w kWh na sesję, Ta=35°C.',14.5)

H('5. Czy samo GS poprawia sterowanie?')
p(f'Dla warunków 35°C i bez warstwy SAFE: PI osiągnął Tc,max={PI.Tmax_C:.2f}°C, GS={GS.Tmax_C:.2f}°C. RMSE temperatury względem 30°C wynosi {PI.RMSE_error_K:.2f} K dla PI i {GS.RMSE_error_K:.2f} K dla GS. W tej konkretnej implementacji nie ma empirycznego potwierdzenia przewagi GS: różnica jest niewielka i zależy od strojenia oraz ograniczeń siłownika.')
fig('06_PI_vs_GS_u.png','Rys. 5. Sygnały chłodzenia PI i GS przy tych samych warunkach.',14.5)
p('Nie należy utożsamiać poprawy uzyskanej dzięki ograniczeniu prądu lub zmianie SOC postoju z poprawą wynikającą z samego harmonogramowania wzmocnień. Kluczowe jest porównanie kontrolowane PI ↔ GS oraz PI_FF ↔ GS_FF.')

H('6. Test niepewności i analiza liniowa')
p('Wykonano deterministyczną siatkę 3×3×3×3 wartości: R/Rnom ∈ {0,85;1;1,15}, Gcs/Gcs,nom ∈ {0,8;1;1,2}, Gcool/Gcool,nom ∈ {0,8;1;1,2} oraz Ta = 35°C + {−3;0;3}. Daje to 81 kombinacji dla PI_SAFE i 81 dla GS_SAFE, razem 162 sesje.')
rr=[]
for st in ['PI_SAFE','GS_SAFE']:
 sub=rob[rob.strategy==st];rr.append([st,f'{sub.Tmax_C.min():.2f}',f'{sub.Tmax_C.median():.2f}',f'{sub.Tmax_C.max():.2f}',f'{(sub.Tmax_C>40).sum()} / {len(sub)}'])
tab(['Strategia','Min Tc,max','Mediana','Max Tc,max','Przekroczeń 40°C'],rr)
p('Żadna z badanych 162 kombinacji nie przekroczyła temperatury 40°C. Wynik obejmuje wyłącznie zadeklarowany zakres i algorytm; nie stanowi dowodu odporności poza siatką ani dowodu stabilności globalnej.')
p('Dodatkowo policzono wartości własne lokalnej macierzy wrażliwości dla pięciu zamrożonych SOC przy założonym aktywnym (nienasyconym) układzie. Punkty nie są niezależnie rozwiązanymi stanami równowagi, dlatego nie traktujemy modułów wartości własnych poniżej 1 jako formalnego dowodu stabilności w pełnym zakresie pracy. Dla udokumentowania stabilności LPV potrzebna byłaby analiza wspólnej funkcji Lapunowa/LMI i uwzględnienie nasycenia oraz przełączania.')

H('7. Model starzenia i horyzont 10 lat')
p('SOH jest pojemnościowym stanem zdrowia: SOH = 1 − Dcal − Dcyc. Model zawiera dwa niezależnie przyjęte człony: kalendarzowy z przyrostami proporcjonalnymi do zmian sqrt(t), k_cal=0,025, oraz cykliczny ze współczynnikiem k_cyc=5×10⁻⁵ na EFC, 300 dni ładowania w roku i 0,55 EFC na sesję. Wpływ temperatury ujęto wykładniczo, a wpływ SOC postoju mnożnikiem wykładniczym; temperatura otoczenia zmienia się sezonowo o ±7°C.')
p('Kalendarzowy ubytek jest aktualizowany przyrostowo i nie maleje w trakcie sezonowych spadków temperatury. Model nie ma sprzężenia SOH → rezystancja → temperatura. Współczynniki nie są zidentyfikowane dla użytych ogniw; dlatego 10-letni SOH jest jedynie scenariuszem.')
fig('05_soh_scenarios.png','Rys. 6. SOH według modelu dla wariantu GS_LIFE i trzech klimatów.',14.5)

H('8. NASA PCoE: pomiary a nasze założenia')
p('Oficjalny zbiór NASA Ames PCoE „Li-ion Battery Aging Datasets” gromadzi dane z testów ogniw 18650: ładowanie, rozładowanie i elektrochemiczną spektroskopię impedancyjną. W dokumentacji NASA opisano kryterium końca życia jako spadek pojemności z 2,0 do 1,4 Ah (70% wartości znamionowej). Nie jest to ten sam próg co przyjęte w naszym projekcie 80% i nie jest to pomiar baterii EV 96s50p.')
p('Na podstawie opublikowanej wtórnej tabeli cykli można przedstawić skrajne pojemności kilku ogniw. Te liczby nie są wynikiem dopasowania w naszym projekcie: B0005 1,857→1,325 Ah, B0006 2,035→1,186 Ah, B0007 1,891→1,433 Ah, B0018 1,855→1,341 Ah. Opracowanie wtórne: Lemonergy, NASA PCoE battery ageing, dostęp 15.11.2026. Pochodzenie pierwotne: NASA Ames PCoE.')
fig('07_nasa_published_endpoints.png','Rys. 7. Wyłącznie opublikowane wartości skrajne, a nie przebieg modelu ani wykonana walidacja.',14.5)
h2('Plan niezależnego testu NASA (kod gotowy, test warunkowy)')
p('W katalogu nasa_data/ należy umieścić B0005.mat z oryginalnego zbioru NASA lub przygotowany CSV z kolumnami cycle, capacity_Ah. Funkcja btms_nasa_validate.m wykorzysta wyłącznie rozładowania, podzieli cykle chronologicznie 70%/30%, dopasuje Q(N)=a+b√N oraz Q(N)=a+b·N na pierwszych 70% i obliczy RMSE [Ah] dla części testowej. Nie da to jeszcze dopasowania modelu termicznego pakietu ani kalibracji członu kalendarzowego w 10 latach.')
nv=RESULTS/'nasa_validation_python.csv'
if nv.is_file():
 nvd=pd.read_csv(nv).iloc[0]
 p(f'Stan wykonania: przeanalizowano {int(nvd.n_cycles)} cykli rozładowania B0005. RMSE testu: model √N {nvd.RMSE_test_Ah:.3f} Ah'+(f', model liniowy {nvd.RMSE_test_lin_Ah:.3f} Ah, persystencja {nvd.RMSE_test_persistence_Ah:.3f} Ah.' if 'RMSE_test_lin_Ah' in nvd else '.'))
else:
 p('Stan wykonania: brak pliku wyników NASA; uruchom python/nasa_validate.py nasa_data/B0005.mat.')

H('9. Weryfikacja, odtwarzalność i zakres zastosowań')
bullets(['Przetestowano 24 symulacje i 162 warianty niepewności w niezależnej implementacji Python; wszystkie sesje osiągnęły 80% SOC.','Maksymalna bezwzględna reszta bilansu energetycznego w kroku dyskretnym wyniosła około 1,1×10⁻¹¹ J (obliczenia zmiennoprzecinkowe).','Sprawdzono monotoniczność SOH, nieujemność Qcool i ograniczenie 0≤u≤1 w testach referencyjnych.','Kod MATLAB przygotowano jako edytowalną implementację porównawczą; nie uruchamiano go w tym środowisku (brak instalacji MATLAB/Simulink).','Niezależna walidacja na danych termicznych rzeczywistego pakietu i formalna analiza odporności LPV pozostają do wykonania.'])
h2('Uruchomienie')
p('Python 3: pip install -r requirements.txt, następnie python python/run_reference.py. Wyniki trafią do katalogów results/ i figures/. MATLAB: uruchomić matlab/main_btms.m (jako funkcję main_btms) i matlab/quality_tests.m po dodaniu katalogu matlab do path. Analiza NASA jest opcjonalna po umieszczeniu prawdziwego zbioru B0005.mat w nasa_data/.')

H('10. Wnioski')
bullets(['Ograniczenie prądu może być skuteczniejsze od zwiększania wzmocnień regulatora chłodzenia, szczególnie przy nasyceniu i ograniczeniu przewodności cieplnej między rdzeniem a powierzchnią.','Dobór heurystyczny GS nie gwarantuje lepszego wyniku niż stały PI. W badanym scenariuszu PI i GS mają zbliżone charakterystyki, dlatego konieczny jest kontrolowany test i formalny dobór nastaw.','Prognoza 10-letniego SOH silnie zależy od założonego klimatu, sposobu użytkowania i kalibracji modelu. Nie jest ona dowodem trwałości konkretnej baterii.','Dane NASA są właściwym materiałem do sprawdzenia trendu starzenia ogniwa, nie do bezpośredniej walidacji wielowęzłowego pakietu bez odpowiedniego skalowania i pomiarów termicznych.'])

H('11. Źródła i identyfikowalność danych')
for x in [
 'NASA Ames / Data.gov, „Li-ion Battery Aging Datasets”, https://catalog.data.gov/dataset/li-ion-battery-aging-datasets',
 'NASA Prognostics Center of Excellence Data Repository, https://www.nasa.gov/intelligent-systems-division/discovery-and-systems-health/pcoe/pcoe-data-set-repository/',
 'B. Saha, K. Goebel (2007), „Battery Data Set”, NASA Prognostics Data Repository, NASA Ames Research Center.',
 'Lemonergy, „NASA PCoE battery ageing data: 34 18650 cells, cycle by cycle”, https://lemonergy.com/data/ageing/nasa-pcoe/ (wtórne przeliczenia i zestawienie).',
 'W. J. Rugh, J. S. Shamma (2000), „Research on gain scheduling”, Automatica 36(10), 1401–1425, DOI: 10.1016/S0005-1098(00)00058-3.',
 'K. J. Åström, T. Hägglund, Advanced PID Control, ISA, 2006.',
 'MathWorks: „Gain-Scheduled Control Systems”, dokumentacja sterowania.',
 'Materiały źródłowe użytkownika: BTMS_EV_GAIN_SCHEDULING_FABIANEK_FORTUNA_V5(1).pptx i BTMS_Gain_Scheduling_PREZENTACJA_POPRAWIONA.pptx.',
 ]:p(x)


out=OUT/'BTMS_RAPORT_KOMPLETNY.docx';d.save(out);print(out)
