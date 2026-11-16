"""Conditional 10-year feasibility study. Not a validated aging forecast.

This splits fast-charge temperature from storage temperature. The latter
requires an unmodeled thermal management system; its electricity is NOT
included, and the 80% result is explicitly conditional on that constraint.
"""
from __future__ import annotations
import csv, math
from pathlib import Path
from run_reference import Config,run_session
ROOT=Path(__file__).resolve().parents[1]


def life_goal(cfg,mean_tc,peak_i,Tstorage,storage_soc,annual_sessions=300):
    Dcal=Dcyc=0.0
    points=[]
    cfac=1+0.2*max(0,peak_i/cfg.Qah-1)
    for m in range(1,121):
        season=7*math.sin(2*math.pi*((m-0.5)%12)/12)
        droot=math.sqrt(m/12)-math.sqrt((m-1)/12)
        Dcal+=cfg.k_cal*droot*math.exp(0.04*(Tstorage+season-25))*math.exp(1.1*(storage_soc-0.5))
        Dcyc+=(annual_sessions/12)*cfg.EFC_per_session*cfg.k_cyc*math.exp(0.03*(mean_tc+season-25))*cfac
        points.append((m/12,100*max(0,1-Dcal-Dcyc)))
    return {'SOH_10y_pct':points[-1][1], 'Dcal_pp':Dcal*100,'Dcyc_pp':Dcyc*100,'trajectory':points}


def main():
    cfg=Config(); s=run_session(cfg,'GS_LIFE',35)
    assert s['status']=='DONE'
    mean_tc=s['trace'][:,1].mean(); peak_i=s['trace'][:,4].max()
    rows=[]
    for temp in [35,30,27,25,23,20]:
        for soc in [.5,.4]:
            L=life_goal(cfg,mean_tc,peak_i,temp,soc)
            rows.append({'charging_ambient_C':35, 'storage_temperature_C':temp,
            'storage_SOC':soc, 'sessions_per_year':300,
            'SOH_10y_pct':L['SOH_10y_pct'], 'Dcal_pp':L['Dcal_pp'], 'Dcyc_pp':L['Dcyc_pp'],
            'meets_80':L['SOH_10y_pct']>=80, 'Tc_charge_max_C':s['Tmax_C'],
            'charge_time_min':s['time_min'], 'temp_below_40':s['Tmax_C']<40})
    f=ROOT/'results'/'goal80_feasibility_python.csv'
    with f.open('w',newline='',encoding='utf-8') as fd:
        writer=csv.DictWriter(fd,fieldnames=list(rows[0])); writer.writeheader(); writer.writerows(rows)
    base=life_goal(cfg,mean_tc,peak_i,35,.5)
    cond=life_goal(cfg,mean_tc,peak_i,23,.4)
    assert base['SOH_10y_pct']<80<cond['SOH_10y_pct']
    assert s['Tmax_C']<40
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    plt.rcParams['font.family']='DejaVu Sans'
    fig,ax=plt.subplots(figsize=(11.5,5.5),facecolor='white')
    ax.plot([t for t,v in base['trajectory']],[v for t,v in base['trajectory']],lw=2.6,label='Postój 35°C / 50% SOC')
    ax.plot([t for t,v in cond['trajectory']],[v for t,v in cond['trajectory']],lw=2.8,label='Warunkowo: postój 23°C / 40% SOC')
    ax.axhline(80,ls='--',color='#b45309',lw=1.5,label='Wymóg: SOH ≥ 80%')
    ax.set(xlabel='Czas eksploatacji [lata]',ylabel='SOH pojemnościowy [%]',title='Projektowy cel trwałości: 80% po 10 latach · scenariusz modelowy',ylim=(72,101))
    ax.grid(alpha=.2)
    ax.legend(loc='upper right',frameon=False)
    ax.text(.02,.02,'Założenie: 300 sesji/rok; T otoczenia podczas ładowania 35°C.\nEnergia chłodzenia podczas parkowania nie jest uwzględniona.',transform=ax.transAxes,fontsize=9,color='#475569',va='bottom')
    fig.tight_layout()
    fig.savefig(ROOT/'figures'/'09_goal80_feasibility.png',dpi=180)
    plt.close(fig)
    print('WERYFIKACJA MODELOWA: maks Tc = %.3f°C, czas ładowania = %.3f min' % (s['Tmax_C'],s['time_min']))
    print('35°C / 50%% SOC parkowanie: SOH10 = %.3f%% -> FAIL' % base['SOH_10y_pct'])
    print('23°C / 40%% SOC parkowanie: SOH10 = %.3f%% -> CONDITIONAL PASS' % cond['SOH_10y_pct'])
    print('WARUNEK: zewnętrzny układ BTMS podczas postoju, brak modelu energii tego układu.')
    return rows

if __name__=='__main__':main()
