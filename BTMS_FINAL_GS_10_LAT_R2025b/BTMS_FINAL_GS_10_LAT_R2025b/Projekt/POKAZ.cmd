@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul 2>nul
pushd "%~dp0" || (echo BLAD: nie mozna otworzyc folderu projektu. & exit /b 1)
set "MODE=%~1"
if /i "%MODE%"=="setup" goto :setup
if /i "%MODE%"=="matlab-run" goto :matlab
if /i "%MODE%"=="simulink-run" goto :simulink
if /i "%MODE%"=="matlab-nasa" goto :nasa_matlab
if /i "%MODE%"=="matlab-results" goto :results_matlab
if /i "%MODE%"=="help" (
    type KOMENDY.txt
    popd
    exit /b 0
)
if /i "%MODE%"=="pomoc" (
    type KOMENDY.txt
    popd
    exit /b 0
)
if exist ".venv\Scripts\python.exe" (
    ".venv\Scripts\python.exe" "CLI_BTMS.py" %*
    if errorlevel 1 (set "RET=1") else (set "RET=0")
    goto :end
)
where py.exe >nul 2>nul
if not errorlevel 1 (
    py -3 "CLI_BTMS.py" %*
    if errorlevel 1 (set "RET=1") else (set "RET=0")
    goto :end
)
where python.exe >nul 2>nul
if not errorlevel 1 (
    python "CLI_BTMS.py" %*
    if errorlevel 1 (set "RET=1") else (set "RET=0")
    goto :end
)
echo BLAD: Python nie jest dostepny.
echo Lista komend ponizej; do obliczen zainstaluj Python 3.10+.
type KOMENDY.txt
set "RET=1"
goto :end

:setup
if exist ".venv\Scripts\python.exe" (
   echo Lokalny Python juz istnieje: Projekt\.venv
   ".venv\Scripts\python.exe" -m pip install --no-cache-dir --disable-pip-version-check --no-input -r "requirements.txt"
   if errorlevel 1 (set "RET=1") else (set "RET=0")
   goto :end
)
where py.exe >nul 2>nul
if not errorlevel 1 (
    py -3 -m venv ".venv"
) else (
    where python.exe >nul 2>nul
    if errorlevel 1 (
        echo BLAD: zainstaluj Python 3.10+ z oficjalnej strony.
        set "RET=1"
        goto :end
    )
    python -m venv ".venv"
)
if errorlevel 1 (
    echo BLAD: nie udalo sie utworzyc lokalnego srodowiska Python.
    set "RET=1"
    goto :end
)
".venv\Scripts\python.exe" -m pip install --no-cache-dir --disable-pip-version-check --no-input -r "requirements.txt"
set "RET=%errorlevel%"
if "%RET%"=="0" echo GOTOWE: biblioteki sa tylko w tym projekcie w .venv
if not "%RET%"=="0" echo BLAD: instalacja nie powiodla sie. Internet jest potrzebny do pobrania bibliotek.
goto :end

:matlab
set "SCRIPT=URUCHOM_MATLAB.m"
goto :matlab_call
:simulink
set "SCRIPT=URUCHOM_SIMULINK.m"
goto :matlab_call
:nasa_matlab
set "SCRIPT=URUCHOM_NASA_MATLAB.m"
goto :matlab_call
:results_matlab
set "SCRIPT=POKAZ_WYNIKI_MATLAB.m"
goto :matlab_call
:matlab_call
set "MATLAB_EXE="
where matlab.exe >nul 2>nul
if not errorlevel 1 set "MATLAB_EXE=matlab.exe"
if not defined MATLAB_EXE (
    for /d %%V in ("%ProgramFiles%\MATLAB\R*") do (
        if exist "%%~fV\bin\matlab.exe" set "MATLAB_EXE=%%~fV\bin\matlab.exe"
    )
)
if not defined MATLAB_EXE (
    echo NIE ZNALEZIONO MATLAB w PATH ani w Program Files\MATLAB.
    echo Mozesz otworzyc MATLAB recznie: Home - Open - wybierz Projekt\%SCRIPT% - Run.
    echo Nie trzeba wtedy wpisywac ani zmieniac zadnej sciezki.
    set "RET=2"
    goto :end
)
echo Uruchamiam "%SCRIPT%" w MATLAB. Nie zmieniam globalnej zmiennej PATH.
"%MATLAB_EXE%" -batch "run('%SCRIPT%')"
set "RET=%errorlevel%"
goto :end

:end
popd
exit /b %RET%
