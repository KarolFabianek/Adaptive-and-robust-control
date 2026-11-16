#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
MODE="${1:-menu}"
if [[ "$MODE" == "setup" ]]; then
  python3 -m venv .venv
  .venv/bin/python -m pip install --no-cache-dir --disable-pip-version-check --no-input -r requirements.txt
  echo 'Gotowe: biblioteki w Projekt/.venv'
  exit 0
fi
if [[ "$MODE" == "matlab-run" || "$MODE" == "simulink-run" || "$MODE" == "matlab-nasa" || "$MODE" == "matlab-results" ]]; then
  case "$MODE" in
    matlab-run) f='URUCHOM_MATLAB.m';;
    simulink-run) f='URUCHOM_SIMULINK.m';;
    matlab-nasa) f='URUCHOM_NASA_MATLAB.m';;
    matlab-results) f='POKAZ_WYNIKI_MATLAB.m';;
  esac
  if ! command -v matlab >/dev/null 2>&1; then
    echo "MATLAB nie jest dostepny z terminala. Otworz Projekt/$f przez MATLAB i kliknij Run."
    exit 2
  fi
  exec matlab -batch "run('$f')"
fi
if [[ -x .venv/bin/python ]]; then
  exec .venv/bin/python CLI_BTMS.py "$@"
else
  exec python3 CLI_BTMS.py "$@"
fi
