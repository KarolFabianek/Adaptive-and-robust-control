"""Run after python/run_reference.py; invariant-based regression tests."""
import csv, sys
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'python'))
from run_reference import Config,run_session,life_model,STRATS

def run():
 c=Config(); assert c.Qah==175 and abs(c.Rn-.05376)<1e-12 and abs(c.En_kWh-60.48)<1e-12
 for st in STRATS:
  for Ta in [15.,25.,35.]:
   d=run_session(c,st,Ta)
   t=d['trace']
   assert d['status']=='DONE' and abs(d['SOC_end']-.8)<1e-9,(st,Ta)
   assert np.all((t[:,5]>=0)&(t[:,5]<=1)),(st,Ta)
   assert np.all(t[:,7]>=0),(st,Ta)
   assert np.all(np.diff(t[:,3])>=-1e-12),(st,Ta)
   assert d['energy_balance_residual_J']<1e-7,(st,Ta)
   l=life_model(c,d['mean_Tc_C'] if 'mean_Tc_C' in d else float(t[:,1].mean()),float(t[:,4].max()),Ta,.5)
   assert np.all(np.diff(l[:,1])<=1e-8),(st,Ta)
 assert all(run_session(c,st,35.,False)['Tmax_C']<40 for st in ['PI_SAFE','GS_SAFE','GS_LIFE'])
 print('OK: 24 sessions, energy balance, bounds, monotone SOH, safe nominal 35°C cases.')

if __name__=='__main__':run()
