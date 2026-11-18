#!/usr/bin/env python3
"""Bezpieczny pokaz konsolowy BTMS, stdlib-only warstwa prezentacyjna.
Nie zmienia PATH, nie pobiera danych i nie modyfikuje parametrów modelu.
Komendy 'full' i 'tests' uruchamiają dokładnie skrypty referencyjne z pakietu.
"""
from __future__ import annotations
import csv
import importlib.util
import json
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
RESULTS = ROOT / 'results'
FIGURES = ROOT / 'figures'
STRATS = ('CC', 'PI', 'GS', 'PI_FF', 'GS_FF', 'PI_SAFE', 'GS_SAFE', 'GS_LIFE')
STRATS_GROUP = ('PI', 'GS', 'PI_SAFE', 'GS_SAFE', 'GS_LIFE')

COMMANDS = [
    ('help',       'wszystkie komendy i ich znaczenie'),
    ('status',     'kontrola plikow, Pythona, wynikow i NASA'),
    ('demo',       'pelna DEMONSTRACJA: symulacje + testy + wyniki'),
    ('full',       'przelicz 24 sesje, SOH, 162 testy i wykresy'),
    ('tests',      'uruchom testy fizycznych niezmiennikow'),
    ('summary',    '24 sesje i 3 temperatury otoczenia'),
    ('compare',    'bezposrednie porownanie PI / GS / GS_SAFE'),
    ('life',       'prognoza SOH po 10 latach (modelowa)'),
    ('robustness', '162 przypadki niepewnosci w 35C'),
    ('stability',  'lokalna analiza zamrozonych punktow pracy'),
    ('quality',    'testy spelnienia granic i bilansu energii'),
    ('charts',     'lista wszystkich wykresow PNG'),
    ('opencharts', 'otworz katalog wykresow w eksploratorze'),
    ('results',    'lista tabel i plikow wynikowych'),
    ('params',     'skad pobierane sa parametry modelu'),
    ('gains',      'harmonogram nastaw Kp, Ki w funkcji Ts-Tcool'),
    ('trace',      'przebieg Tc / Ts / SOC / I / u dla GS_SAFE w 35C'),
    ('energy',     'cieplo i energia chlodziarki w sesji 35C'),
    ('nasa',       'walidacja rzeczywistych danych NASA, o ile sa'),
    ('gcs',        'wrazliwosc wynikow na przewodnosc rdzen-powierzchnia Gcs'),
    ('goal80',     'warunki spelnienia SOH>=80% po 10 latach (Python)'),
    ('presentation','otworz prezentacje na wyklad'),
    ('report',     'otworz raport projektu'),
    ('sources',    'lista kodu MATLAB/Python i funkcji'),
    ('matlab',     'jak uruchomic glowny projekt w MATLAB'),
    ('simulink',   'jak uruchomic demonstrator w Simulink'),
]

def title(s: str) -> None:
    print('\n' + '=' * 76)
    print('  ' + s)
    print('=' * 76)

def load_csv(name):
    p = RESULTS / name
    if not p.is_file():
        print(f'BRAK {p.name}; uruchom: POKAZ.cmd full')
        return []
    with p.open(newline='', encoding='utf-8-sig') as f:
        return list(csv.DictReader(f))

def fld(x, name, spec='.2f'):
    try:
        return format(float(x[name]), spec)
    except (KeyError, TypeError, ValueError):
        return '---'

def run_child(*parts):
    cmd = [sys.executable, *map(str, parts)]
    print('URUCHAMIAM:', Path(sys.executable).name, *map(str, parts), flush=True)
    proc = subprocess.run(cmd, cwd=ROOT, check=False)
    if proc.returncode:
        raise RuntimeError(f'Blad kodu wyjscia {proc.returncode}; sprawdz komunikaty powyzej.')

def require_deps():
    required = ['numpy', 'pandas', 'matplotlib', 'scipy']
    missing = [x for x in required if importlib.util.find_spec(x) is None]
    if missing:
        raise RuntimeError('Brakuje bibliotek: ' + ', '.join(missing) +
             '. Najpierw wpisz: POKAZ.cmd setup (tworzy prywatne Projekt\\.venv).')

def status():
    title('STATUS SRODOWISKA I PLIKOW')
    print('Folder projektu  :', ROOT)
    print('Interpreter      :', sys.executable)
    print('Wersja Python    :', sys.version.split()[0])
    print('Lokalny venv     :', 'TAK' if (ROOT/'.venv').is_dir() else 'NIE (opcjonalny)')
    for folder in ('matlab', 'python', 'results', 'figures', 'nasa_data'):
        print(f'Folder {folder:11}:', 'OK' if (ROOT/folder).is_dir() else 'BRAK')
    for f in ('sessions_summary.csv','life_summary.csv','robustness_35C.csv','quality_checks.json'):
        print(f'Plik {f:29}:', 'OK' if (RESULTS/f).is_file() else 'BRAK')
    print('NASA B0005.mat  :', 'DOSTEPNY' if (ROOT/'nasa_data'/'B0005.mat').is_file() else 'BRAK - opcjonalny')
    print('MATLAB/Simulink : nie sa uruchamiane w trybie status; wymagaja instalacji')
    print('Uwaga: wyniki bazowe pochodza z modelu symulacyjnego, a nie z pomiarow.')

def help_page():
    title('BTMS | PELNA LISTA KOMEND (bez wpisywania sciezek)')
    print('Otworz folder Projekt w Eksploratorze, wpisz CMD w pasku adresu, Enter.')
    print('Nastepnie wpisuj np.: POKAZ.cmd status')
    print('W PowerShell uzywaj: .\\POKAZ.cmd status')
    print('\nJEDNORAZOWA INSTALACJA ZALEZNOSCI (lokalnie): POKAZ.cmd setup')
    for cmd, desc in COMMANDS:
        print(f'  POKAZ.cmd {cmd:<13}  {desc}')
    print('  POKAZ.cmd                   menu interaktywne')
    print('\nDodatkowo: POKAZ.cmd matlab-run i POKAZ.cmd simulink-run')
    print('Uruchomienie MATLAB automatycznie zadziala tylko, jesli MATLAB jest wykrywalny.')
    print('Komendy nie edytuja rejestru Windows, zmiennych PATH ani cudzych folderow.')
    print('setup instaluje biblioteki tylko do Projekt/.venv. full nadpisuje wyniki projektu.')

def summary():
    title('24 SESJE: 8 STRATEGII x 3 TEMPERATURY')
    rows = load_csv('sessions_summary.csv')
    if not rows: return
    for temp in (15,25,35):
        print(f'\nTa = {temp} C | dane modelowe')
        print(f"{'Strategia':<11}{'czas [min]':>12}{'Tmax [C]':>12}{'E_chl [kWh]':>14}{'status':>12}")
        print('-'*62)
        group=[r for r in rows if abs(float(r['ambient_C'])-temp)<.01]
        for r in sorted(group,key=lambda r: STRATS.index(r['strategy']) if r['strategy'] in STRATS else 99):
            print(f"{r['strategy']:<11}{fld(r,'time_min'):>12}{fld(r,'Tmax_C'):>12}"
                  f"{fld(r,'energy_aux_kWh','.3f'):>14}{r.get('status','---'):>12}")
    print('\nWniosek: brak przewagi jednej strategii we wszystkich kryteriach.')

def compare():
    title('IZOLOWANE POROWNANIE PI / GS ORAZ NADZORU TERMICZNEGO')
    rows=[r for r in load_csv('sessions_summary.csv') if abs(float(r['ambient_C'])-35)<.01]
    d={r['strategy']:r for r in rows}
    for st in STRATS_GROUP:
        if st in d:
            r=d[st]
            print(f"{st:<9} Tmax={fld(r,'Tmax_C'):>6} C   czas={fld(r,'time_min'):>6} min  "
                  f"E_aux={fld(r,'energy_aux_kWh','.3f')} kWh   "
                  f"RMSE={fld(r,'RMSE_error_K'):>7} K")
    if 'PI' in d and 'GS' in d:
        print('\nGS - PI (35 C): dTmax =',round(float(d['GS']['Tmax_C'])-float(d['PI']['Tmax_C']),3),'C')
        print('Punkt projektowy GS to Ts-Tcool = 17 K (goraca powierzchnia przy 35 C): tam GS ~ PI;')
        print('roznice widac w chlodniejszych warunkach (summary: 15 i 25 C).')
    print('Warianty *_SAFE ograniczaja PRAD tylko powyzej 36,5 C; nominalnie przy Gcs=1650 W/K nie wlaczaja sie.')

def life():
    title('SOH PO 10 LATACH | PROGNOZA SCENARIUSZOWA')
    rows=load_csv('life_summary.csv')
    if not rows:return
    print(f"{'Strategia':<13}{'Ta':>5}{'SOH 10y [%]':>13}{'kalendarz [pp]':>16}{'cykle [pp]':>12}{'postoj 50% [%]':>16}")
    for r in rows:
        print(f"{r['strategy']:<13}{fld(r,'ambient_C','.0f'):>5}{fld(r,'SOH_10y_pct'):>13}"
              f"{fld(r,'Dcal_pp'):>16}{fld(r,'Dcyc_pp'):>12}{fld(r,'SOH_10y_park050_pct'):>16}")
    print('SOH 10y: postoj przy 78% SOC dla wszystkich strategii; ostatnia kolumna = polityka postoju 50% SOC.')
    print('UWAGA: parametry starzenia sa ZALOZENIAMI MODELU; nie ma kalibracji NASA.')

def robustness():
    title('TEST WRAZLIWOSCI: 162 SCENARIUSZE (NIE DOWOD ODPORNOSCI)')
    rows=load_csv('robustness_35C.csv')
    if not rows:return
    for st in ('PI_SAFE','GS_SAFE'):
        g=[r for r in rows if r['strategy']==st]
        if not g:continue
        vals=[float(x['Tmax_C']) for x in g]
        exceed=sum(v>=40 for v in vals)
        complete=sum(x['status']=='DONE' for x in g)
        worst=max(g,key=lambda x:float(x['Tmax_C']))
        print(f'\n{st}: przypadkow {len(g)}, ukonczonych {complete}, Tmax {min(vals):.2f}..{max(vals):.2f} C')
        print(f'  Przekroczenia 40 C: {exceed}/{len(g)}')
        print('  Najgorszy: R x'+worst['R_multiplier']+', Gcs x'+worst['Gcs_multiplier']+
              ', Gcool x'+worst['Gcool_multiplier']+', dTa '+worst['Ta_offset_C']+' C')
    print('To test zadanych perturbacji, NIE formalna gwarancja stabilnosci.')

def stability():
    title('LOKALNE BIEGUNY DYSKRETNE: PUNKTY ROWNOWAGI PI')
    rows=load_csv('local_frozen_jacobian.csv')
    if not rows:return
    print(f"{'Regulator':<11}{'Ta':>5}{'SOC':>7}{'I [A]':>8}{'Ts* [C]':>9}{'u*':>8}{'osiagalny':>11}{'max |lambda|':>15}")
    for r in rows:print(f"{r['strategy']:<11}{fld(r,'Ta_C','.0f'):>5}{fld(r,'SOC','.2f'):>7}{fld(r,'I_A','.0f'):>8}{fld(r,'Ts_eq_C','.1f'):>9}"
                        f"{fld(r,'u_eq','.2f'):>8}{r.get('feasible','---'):>11}{fld(r,'max_abs_lambda','.6f'):>15}")
    print('Punkt pracy = wyznaczona rownowaga PI (Tc=Tref). osiagalny=False: Tref nieosiagalne,')
    print('petla musi sie nasycic i analiza liniowa nie ma zastosowania. To nie jest dowod stabilnosci LPV.')

def quality():
    title('JAKOSC I NIEZMIENNIKI MODELU')
    p=RESULTS/'quality_checks.json'
    if not p.exists():print('Brak quality_checks.json.');return
    j=json.loads(p.read_text(encoding='utf-8'))
    for key,val in j.items():print(f'  {key}: {val}')
    print('Testy numeryczne != walidacja na pomiarach rzeczywistej baterii.')

def charts():
    title('WYKRESY PNG | PROJEKT/figures')
    for p in sorted(FIGURES.glob('*.png')):
        print(f'  {p.name:<43}  {p.stat().st_size//1024} KB')
    print('Aby otworzyc katalog: POKAZ.cmd opencharts')

def results():
    title('TABELE CSV I JSON | PROJEKT/results')
    for p in sorted(RESULTS.iterdir()):
        if p.suffix.lower() in ('.csv','.json'):
            print(f'  {p.name:<45}  {p.stat().st_size//1024} KB')

def params():
    title('PARAMETRY I DOSTEPNE STRATEGIE')
    print('Pakiet: 96s50p, Un=345.6 V, Qn=175 Ah, En=60.48 kWh, Rn=0.05376 ohm, Gcs=1650 W/K (2,9 K/W na ogniwo)')
    print('SOC 25->80%; krok dt=5 s; scenariusze otoczenia 15 / 25 / 35 C')
    print('Strategie:',', '.join(STRATS))
    print('MATLAB konfiguracja:  Projekt/matlab/btms_cfg.m')
    print('Python konfiguracja:  Projekt/python/run_reference.py (klasa Config)')
    print('Zmiana parametrow tylko w jednej implementacji zerwie bezposrednia zgodnosc.')

def gains_schedule():
    title('GAIN SCHEDULING | NASTAWY PI W FUNKCJI Ts - Tcool')
    print('Wzmocnienie chlodzenia dQcool/du = Gcool*(Ts-Tcool): GS utrzymuje Kp*Gcool*(Ts-Tcool) stale.')
    print('Kp,Ki = PI * clip(17/(Ts-Tcool), 1, 3); punkt projektowy Ts-Tcool = 17 K (35-18 C).')
    print(f"{'Ts-Tcool [K]':>13} {'Kp_PI':>9} {'Ki_PI [1/s]':>13} {'Kp_GS':>9} {'Ki_GS [1/s]':>13}")
    for rho in (4, 6, 8, 10, 12, 14, 17, 20):
        k=min(3.,max(1.,17./max(rho,17./3.)))
        print(f'{rho:13.0f} {0.0725:9.4f} {47.5e-6:13.7f} {0.0725*k:9.4f} {47.5e-6*k:13.7f}')
    print('Porownaj rownolegle: matlab/btms_gains.m i python/run_reference.py')

def trace():
    title('PRZEBIEG CZASOWY | GS_SAFE, Ta=35 C (wybrane probki)')
    rows=load_csv('session_35C_GS_SAFE.csv')
    if not rows:return
    print(f"{'czas[min]':>10}{'Tc[C]':>10}{'Ts[C]':>10}{'SOC[%]':>10}{'I[A]':>10}{'u':>9}{'Qgen[W]':>12}{'Qcool[W]':>12}")
    for frac in (0, .2, .4, .6, .8, 1.):
        row=rows[round((len(rows)-1)*frac)]
        print(f"{fld(row,'time_min'):>10}{fld(row,'Tc_C'):>10}{fld(row,'Ts_C'):>10}"
              f"{float(row['SOC'])*100:10.1f}{fld(row,'I_A'):>10}{fld(row,'u','.3f'):>9}"
              f"{fld(row,'Qgen_W','.0f'):>12}{fld(row,'Qcool_W','.0f'):>12}")
    print('Pelna telemetria: results/session_35C_GS_SAFE.csv')

def energy():
    title('CIEPLO / ENERGIA CHLODZENIA | Ta=35 C')
    group=[x for x in load_csv('sessions_summary.csv') if abs(float(x['ambient_C'])-35)<.01]
    if not group:return
    print(f"{'Strategia':<12}{'E_Joule[kWh]':>16}{'E_aux[kWh]':>14}{'czas[min]':>13}")
    for row in group:
        print(f"{row['strategy']:<12}{fld(row,'energy_heat_kWh','.3f'):>16}"
              f"{fld(row,'energy_aux_kWh','.3f'):>14}{fld(row,'time_min'):>13}")
    print('E_aux uwzglednia moc pompy i modelowego chillera; bilans dotyczy obiektu skupionego.')

def nasa():
    title('NASA PCoE | OPCJONALNA ANALIZA PRAWDZIWYCH DANYCH')
    fn=ROOT/'nasa_data'/'B0005.mat'
    if not fn.is_file():
        print('Brak pliku nasa_data/B0005.mat. NICZEGO NIE POBIERAMY automatycznie.')
        print('Zestaw NASA nie jest w tej paczce. Wymagana autentyczna probka .mat.')
        print('Bez tego glowne 24 sesje, SOH i testy niepewnosci dzialaja.')
        return
    require_deps()
    run_child(ROOT/'python'/'nasa_validate.py',fn)

def open_file(path):
    if not path.exists():
        print('Nie znaleziono:', path)
        return
    print('Otwieram:',path)
    if os.name=='nt': os.startfile(path)  # type: ignore[attr-defined]
    elif sys.platform=='darwin': subprocess.Popen(['open',str(path)])
    else: subprocess.Popen(['xdg-open',str(path)])

def sources():
    title('ZRODLA I KOMPONENTY PROJEKTU')
    for f in sorted((ROOT/'matlab').glob('*.m')):print('  MATLAB:',f.name)
    for f in sorted((ROOT/'python').glob('*.py')):print('  Python:',f.name)
    print('  TESTY:  tests/test_reference.py')
    print('  DOKUMENTACJA: Dokumentacja/RAPORT_TECHNICZNY.pdf')

def execute(mode):
    mode=mode.lower().strip()
    if mode in ('help','pomoc','?'): help_page()
    elif mode=='status':status()
    elif mode in ('demo','full','tests'):
        require_deps()
        if mode in ('demo','full'):
            run_child(ROOT/'python'/'run_reference.py')
            run_child(ROOT/'python'/'life_goal80.py')
            run_child(ROOT/'python'/'sensitivity_gcs.py')
        if mode in ('demo','tests'):run_child(ROOT/'tests'/'test_reference.py')
        if mode=='demo':
            summary();compare();gains_schedule();trace();energy();life();robustness();stability();quality();charts();nasa()
        print('\nZAKONCZONO:', mode, '| Pliki wynikowe:',RESULTS)
    elif mode=='summary':summary()
    elif mode=='compare':compare()
    elif mode=='life':life()
    elif mode=='robustness':robustness()
    elif mode=='stability':stability()
    elif mode=='quality':quality()
    elif mode=='charts':charts()
    elif mode=='opencharts':open_file(FIGURES)
    elif mode=='results':results()
    elif mode in ('params','config'):params()
    elif mode=='gains':gains_schedule()
    elif mode in ('trace','telemetry'):trace()
    elif mode=='energy':energy()
    elif mode=='nasa':nasa()
    elif mode=='gcs':require_deps();run_child(ROOT/'python'/'sensitivity_gcs.py')
    elif mode in ('goal80','cel80'):require_deps();run_child(ROOT/'python'/'life_goal80.py')
    elif mode=='presentation':open_file(ROOT.parent/'Prezentacja'/'BTMS_WYKLAD_FABIANEK_FORTUNA.pptx')
    elif mode=='report':open_file(ROOT/'Dokumentacja'/'RAPORT_TECHNICZNY.pdf')
    elif mode=='sources':sources()
    elif mode=='matlab':
        title('MATLAB');print('W CMD: POKAZ.cmd matlab-run')
        print('Alternatywa: w MATLAB przez Home -> Open wybierz URUCHOM_MATLAB.m i Run.')
    elif mode=='simulink':
        title('SIMULINK');print('W CMD: POKAZ.cmd simulink-run')
        print('Wymaga MATLAB+Simulink. Weryfikacja: stany Simulink == sesja MATLAB GS_LIFE (ta sama btms_step).')
    else:
        print('Nieznana komenda:',mode)
        help_page();return False
    return True

def menu():
    help_page()
    print('\nWpisz nazwe wybranej opcji (np. compare), albo q aby zakonczyc.')
    while True:
        try:x=input('\nBTMS> ').strip()
        except (EOFError,KeyboardInterrupt):print('\nKoniec.');return
        if x.lower() in ('q','quit','exit','koniec'):print('Koniec.');return
        if not x:continue
        try:execute(x)
        except Exception as ex:print('BLAD:',ex)

def main():
    try:
        if len(sys.argv)<2:menu()
        else:execute(sys.argv[1])
    except Exception as ex:
        print('BLAD:',ex,file=sys.stderr)
        return 1
    return 0

if __name__=='__main__':raise SystemExit(main())
