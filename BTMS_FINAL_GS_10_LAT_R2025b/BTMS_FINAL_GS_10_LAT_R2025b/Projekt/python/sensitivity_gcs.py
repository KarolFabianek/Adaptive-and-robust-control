"""Sensitivity of the main conclusions to core-surface conductance Gcs (added after review).
Mirrors matlab/btms_sensitivity_gcs.m. Base value is now Gcs=1650 W/K (~2.9 K/W per 18650 cell);
the old 165 W/K (~29 K/W per cell) is kept in the grid to show how the conclusions depended on it.
"""
from __future__ import annotations
import csv
from dataclasses import replace
from pathlib import Path
from run_reference import Config, run_session
ROOT=Path(__file__).resolve().parents[1]

def main(Ta=35.):
    c0=Config(); ncell=c0.ns*c0.np; rows=[]
    for G in (165.,330.,660.,1650.,2600.):
        c=replace(c0,Gcs=G)
        for st in ('CC','PI','GS','GS_SAFE','GS_LIFE'):
            d=run_session(c,st,Ta,False)
            rows.append([G,ncell/G,st,Ta,d['Tmax_C'],d['time_min'],d['energy_aux_kWh'],d['sat_fraction'],d['Tmax_C']<c.Tlim])
    f=ROOT/'results'/'gcs_sensitivity_python.csv'
    with f.open('w',newline='',encoding='utf-8') as fd:
        w=csv.writer(fd); w.writerow(['Gcs_W_per_K','Rth_cell_K_per_W','strategy','ambient_C','Tmax_C','time_min','energy_aux_kWh','sat_fraction','below_40C']); w.writerows(rows)
    print(f"{'Gcs':>6} {'K/W/ogn':>8}  " + '  '.join(f'{s:>14}' for s in ('CC','PI','GS','GS_SAFE','GS_LIFE')))
    for i in range(0,len(rows),5):
        g=rows[i]; print(f"{g[0]:6.0f} {g[1]:8.2f}  " + '  '.join(f"{r[4]:6.2f}C/{r[5]:5.1f}m" for r in rows[i:i+5]))
    print('Gcs=165 W/K (stara wartosc): PI 47 C, potrzebne ograniczanie pradu. Gcs=1650 W/K (baza): PI ~38 C.')
    return rows

if __name__=='__main__':main()
