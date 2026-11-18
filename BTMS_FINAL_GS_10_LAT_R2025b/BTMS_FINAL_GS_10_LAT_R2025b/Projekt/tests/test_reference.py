"""Run after python/run_reference.py; invariant-based regression tests (NOT empirical validation)."""
import csv, sys
from dataclasses import replace
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'python'))
from run_reference import Config,run_session,life_model,STRATS,local_equilibrium_jacobian
from life_goal80 import life_goal

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
   # Algebraic identity of the Euler update: guards code consistency only.
   assert d['energy_balance_residual_J']<1e-7,(st,Ta)
   l=life_model(c,d['mean_Tc_C'] if 'mean_Tc_C' in d else float(t[:,1].mean()),float(t[:,4].max()),Ta,.5)
   assert np.all(np.diff(l[:,1])<=1e-8),(st,Ta)
 assert all(run_session(c,st,35.,False)['Tmax_C']<40 for st in ['PI','GS','PI_SAFE','GS_SAFE','GS_LIFE'])
 # Numerical convergence of explicit Euler: dt=5 s vs dt=1 s.
 c1=replace(c,dt=1.)
 for st in ['PI','GS_SAFE','GS_LIFE']:
  a=run_session(c,st,35.,False); b=run_session(c1,st,35.,False)
  assert abs(a['Tmax_C']-b['Tmax_C'])<0.1 and abs(a['time_min']-b['time_min'])<0.2,(st,a['Tmax_C'],b['Tmax_C'])
 # The two life implementations (life_model / life_goal) must agree when storage = charging ambient.
 d=run_session(c,'GS_LIFE',35.); t=d['trace']
 l1=life_model(c,float(t[:,1].mean()),float(t[:,4].max()),35.,.5)
 l2=life_goal(c,float(t[:,1].mean()),float(t[:,4].max()),35.,.5,c.days_per_year)
 assert abs(l1[-1,1]-l2['SOH_10y_pct'])<1e-9
 # Equilibrium linearization: every feasible point is locally stable; 120 A is feasible in every climate.
 J=local_equilibrium_jacobian(c)
 assert all(r[7]<1 for r in J if r[6])
 assert all(r[6] for r in J if r[2]==120.)
 # GS (Ts-Tcool schedule) equals PI at the design point rho0 and never goes below PI gains.
 from run_reference import gains
 assert gains(c,'GS',c.Tcool+c.gs_rho0)==gains(c,'PI',c.Tcool+c.gs_rho0)
 assert all(gains(c,'GS',T)[0]>=c.Kp_const for T in (10.,20.,30.,40.,50.))
 print('OK: 24 sessions, bounds, monotone SOH, safe nominal 35°C cases, dt convergence, life consistency, equilibrium.')

if __name__=='__main__':run()
