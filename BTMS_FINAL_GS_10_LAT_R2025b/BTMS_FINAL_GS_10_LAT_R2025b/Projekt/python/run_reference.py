"""Independent Python reference and reproducible charts for the MATLAB BTMS model.
This is a PROJECT SCENARIO (not an experimentally validated battery pack).
No NASA time-series measurements are simulated or fabricated.
"""
from __future__ import annotations
import csv, itertools, math, json
from dataclasses import dataclass, replace
from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.ticker import MaxNLocator

ROOT=Path(__file__).resolve().parents[1]
RESULT=ROOT/'results'; FIG=ROOT/'figures'
RESULT.mkdir(exist_ok=True); FIG.mkdir(exist_ok=True)
NAVY='#0b1726'; BG='#101e30'; GRID='#2b4357'; LIGHT='#f1f5f9'; MUTED='#9bb0c4'
TEAL='#3ddbc4'; ORANGE='#ffc077'; RED='#f76d78'; BLUE='#78a6ff'; GREEN='#93e8ad'
plt.rcParams.update({'font.family':'DejaVu Sans','font.size':10,'figure.facecolor':NAVY,
 'axes.facecolor':NAVY,'savefig.facecolor':NAVY,'axes.edgecolor':GRID,'axes.labelcolor':LIGHT,
 'text.color':LIGHT,'xtick.color':MUTED,'ytick.color':MUTED,'grid.color':GRID,
 'legend.facecolor':BG,'legend.edgecolor':GRID,'legend.labelcolor':LIGHT,'axes.titleweight':'bold'})

@dataclass(frozen=True)
class Config:
 dt:float=5.0; Tmax:float=7200.0
 ns:int=96; np:int=50; U_cell:float=3.6; Ah_cell:float=3.5; R_cell:float=0.028
 mass_cell:float=0.048; cp:float=900.; Cfrac:float=0.76
 Gcs:float=165.; Gamb:float=25.; Gcool:float=470.
 Tmax_cool:float=6500.; Tcool:float=18.; COP:float=2.6; pump_max:float=400.
 soc0:float=.25; soc_target:float=.80; taper_soc:float=.70; I_max:float=300.; I_taper:float=130.
 Tref:float=30.; Tlim:float=40.; thermal_start:float=36.5; thermal_full:float=39.5; I_min:float=110.
 ff_gain:float=.70; Kp_const:float=.0725; Ki_const:float=47.5e-6
 R_scale:float=1.; Gcs_scale:float=1.; Gcool_scale:float=1.
 k_cal:float=.025; k_cyc:float=5.e-5; socpark_regular:float=.78; socpark_life:float=.50
 days_per_year:float=300.; EFC_per_session:float=.55
 @property
 def Qah(self): return self.np*self.Ah_cell
 @property
 def Rn(self): return self.ns*self.R_cell/self.np
 @property
 def Ctotal(self): return self.ns*self.np*self.mass_cell*self.cp
 @property
 def Cc(self): return self.Cfrac*self.Ctotal
 @property
 def Cs(self): return (1-self.Cfrac)*self.Ctotal
 @property
 def En_kWh(self): return self.ns*self.U_cell*self.Qah/1000.

STRATS=['CC','PI','GS','PI_FF','GS_FF','PI_SAFE','GS_SAFE','GS_LIFE']
PALETTE={'CC':MUTED,'PI':BLUE,'GS':TEAL,'PI_FF':'#a4baff','GS_FF':'#59d8b8','PI_SAFE':ORANGE,'GS_SAFE':RED,'GS_LIFE':GREEN}

def clip(x,lo,hi):return min(max(x,lo),hi)
def rpack(cfg,soc,Tc):
 return cfg.Rn*cfg.R_scale*clip(1+.2*(.5-soc)+.002*(25-Tc),.7,1.4)
def gains(cfg,soc,strategy):
 if strategy in ('CC','PI','PI_FF','PI_SAFE'):
  return cfg.Kp_const,cfg.Ki_const
 a=clip((soc-.2)/.6,0,1)
 return .055+.035*a,(35.+25.*a)*1e-6

def run_session(cfg, strategy, Tamb=35., return_trace=True):
 assert strategy in STRATS
 Tc=Ts=float(Tamb); soc=cfg.soc0; z=0.0; total_aux=0.; total_heat=0.
 data=[]; t=0.; peak=Tc; err_sq=0.; saturation=0; n=0; energy_balance_max=0.
 for step in range(round(cfg.Tmax/cfg.dt)):
  if soc >= cfg.soc_target-1e-10: break
  taper=clip((soc-cfg.taper_soc)/(cfg.soc_target-cfg.taper_soc),0,1)
  iprofile=cfg.I_max*(1-taper)+cfg.I_taper*taper
  # Exactly stated independent safety supervisor. It is not a source-verified copy of the old project.
  if strategy in ('PI_SAFE','GS_SAFE','GS_LIFE'):
   f=clip((Tc-cfg.thermal_start)/(cfg.thermal_full-cfg.thermal_start),0,1)
   itherm=cfg.I_max-(cfg.I_max-cfg.I_min)*f
  else: itherm=cfg.I_max
  ilim=210. if strategy=='GS_LIFE' else cfg.I_max
  I=min(iprofile,itherm,ilim,(cfg.soc_target-soc)*cfg.Qah*3600./cfg.dt)
  I=max(0,I)
  R=rpack(cfg,soc,Tc); qgen=I*I*R
  Kp,Ki=gains(cfg,soc,strategy)
  ff=(cfg.ff_gain*qgen/cfg.Tmax_cool) if strategy in ('PI_FF','GS_FF','PI_SAFE','GS_SAFE','GS_LIFE') else 0.
  e=Tc-cfg.Tref
  if strategy=='CC': u=.2; znew=z; raw=u
  else:
   raw=Kp*e+z+ff
   u=clip(raw,0.,1.)
   # Conditional integration: freeze only if the error pushes farther into saturation.
   if not ((raw>=1 and e>0) or (raw<=0 and e<0)):
    znew=z+Ki*cfg.dt*e
   else: znew=z
  qcool=max(0.,min(cfg.Tmax_cool*u,cfg.Gcool*cfg.Gcool_scale*u*(Ts-cfg.Tcool)))
  qambient=cfg.Gamb*(Ts-Tamb)
  qtransfer=cfg.Gcs*cfg.Gcs_scale*(Tc-Ts)
  dTc=cfg.dt*(qgen-qtransfer)/cfg.Cc
  dTs=cfg.dt*(qtransfer-qambient-qcool)/cfg.Cs
  Paux=cfg.pump_max*u**3+qcool/cfg.COP
  total_aux+=Paux*cfg.dt/3.6e6
  total_heat+=qgen*cfg.dt/3.6e6
  new_soc=min(cfg.soc_target,soc+I*cfg.dt/(3600.*cfg.Qah))
  bal=cfg.Cc*dTc+cfg.Cs*dTs-cfg.dt*(qgen-qambient-qcool)
  energy_balance_max=max(energy_balance_max,abs(bal))
  Tc+=dTc; Ts+=dTs; soc=new_soc;z=znew;t+=cfg.dt
  peak=max(peak,Tc);n+=1; err_sq+=e*e; saturation+=int(u>=.999999)
  if return_trace:
   data.append((t/60.,Tc,Ts,soc,I,u,qgen,qcool,Paux,ff,z,e,itherm))
 status='DONE' if soc>=cfg.soc_target-1e-9 else 'TIMEOUT'
 out={'strategy':strategy,'ambient_C':Tamb,'time_min':t/60.,'Tmax_C':peak,
 'Tend_C':Tc,'energy_aux_kWh':total_aux,'energy_heat_kWh':total_heat,'SOC_end':soc,
 'RMSE_error_K': math.sqrt(err_sq/max(1,n)),'sat_fraction':saturation/max(1,n),
 'energy_balance_residual_J':energy_balance_max,'status':status,'points':n}
 if return_trace:out['trace']=np.array(data)
 return out

def life_model(cfg, meanTc, Ipeak, Tamb, park_soc, months=120):
 # Explicitly assumed scenario model. NOT calibrated to NASA and NOT a 10-year forecast of a real pack.
 # Changing temperatures are seasonal: base +/- 7 C in both calendar and cycling multipliers.
 # Dcal is accumulated from incremental sqrt(t) ageing, modulated by month temperature.
 # Dcyc annualized = EFC * k_cyc * exp(0.03*(Tcycle-25)) * [1+.20*(Cmax-1)+].
 emax=Ipeak/cfg.Qah
 cfac=1+.20*max(0,emax-1.)
 Dcyc=0.; Dcal=0.; points=[]
 for m in range(1,months+1):
  seasonal=7*math.sin(2*math.pi*((m-.5)%12)/12.)
  Tstore=Tamb+seasonal
  Tcyc=meanTc+seasonal
  droot=math.sqrt(m/12.)-math.sqrt((m-1)/12.)
  Dcal+=cfg.k_cal*droot*math.exp(.04*(Tstore-25))*math.exp(1.1*(park_soc-.5))
  Dcyc+=(cfg.days_per_year/12.)*cfg.EFC_per_session*cfg.k_cyc*math.exp(.03*(Tcyc-25))*cfac
  points.append((m/12, 100*max(0,1-Dcal-Dcyc),100*Dcal,100*Dcyc))
 return np.array(points)

def save_csv(file,rows,headers):
 with (RESULT/file).open('w',newline='',encoding='utf-8') as f:
  w=csv.writer(f);w.writerow(headers);w.writerows(rows)

def restyle(ax):
 ax.spines[['top','right']].set_visible(False)
 ax.grid(True,alpha=.45,linewidth=.65)
 ax.set_axisbelow(True)

def make_figures(summary,trace):
 # 01: 35C temp, selected
 fig,ax=plt.subplots(figsize=(12,5.4));
 for st in ['CC','PI','GS','GS_SAFE','GS_LIFE']:
  a=trace[(st,35.)];ax.plot(a[:,0],a[:,1],lw=2.5,c=PALETTE[st],label=st)
 ax.axhline(40,color=RED,linestyle='--',linewidth=1.4,alpha=.85,label='Limit projektu 40°C')
 ax.set(title='Temperatura rdzenia podczas ładowania · Ta = 35°C',xlabel='Czas [min]',ylabel='Tc [°C]');restyle(ax);ax.legend(ncol=3,fontsize=9,loc='upper left');fig.tight_layout();fig.savefig(FIG/'01_temperature_35C.png',dpi=180);plt.close(fig)
 # 02: current
 fig,ax=plt.subplots(figsize=(12,5.2))
 for st in ['PI','GS','GS_SAFE','GS_LIFE']:
  a=trace[(st,35.)];ax.plot(a[:,0],a[:,4],lw=2.6,c=PALETTE[st],label=st)
 ax.set(title='Nadzór termiczny ogranicza prąd · Ta = 35°C',xlabel='Czas [min]',ylabel='Prąd I [A]');restyle(ax);ax.legend(ncol=4,fontsize=10);fig.tight_layout();fig.savefig(FIG/'02_current_35C.png',dpi=180);plt.close(fig)
 # 03: tradeoff
 fig,ax=plt.subplots(figsize=(11.5,5.5))
 for x in summary:
  if x['ambient_C']!=35:continue
  ax.scatter(x['time_min'],x['Tmax_C'],s=145,color=PALETTE[x['strategy']],zorder=4,edgecolors=LIGHT,linewidths=.5)
  offsets={'CC':(9,10),'PI':(9,18),'GS':(9,-12),'PI_FF':(9,-22),'GS_FF':(9,-36),'PI_SAFE':(-88,18),'GS_SAFE':(12,-22),'GS_LIFE':(-80,15)}
  dx,dy=offsets[x['strategy']]
  ax.annotate(x['strategy'],(x['time_min'],x['Tmax_C']),xytext=(dx,dy),textcoords='offset points',fontsize=9,
    arrowprops={'arrowstyle':'-','color':GRID,'lw':.7})
 ax.axhline(40,ls='--',color=RED,lw=1.4);ax.set(title='Kompromis: czas ładowania a temperatura maksymalna',xlabel='Czas 25–80% SOC [min]',ylabel='Tc,max [°C]');restyle(ax);fig.tight_layout();fig.savefig(FIG/'03_tradeoff.png',dpi=180);plt.close(fig)
 # 04: cooling energy
 arr=[x for x in summary if x['ambient_C']==35.];
 fig,ax=plt.subplots(figsize=(11.6,5.0)); xx=np.arange(len(arr));ax.bar(xx,[x['energy_aux_kWh'] for x in arr],color=[PALETTE[x['strategy']] for x in arr],width=.7)
 ax.set_xticks(xx,[x['strategy'] for x in arr],rotation=23,ha='right');ax.set(title='Energia pomocnicza chłodzenia · Ta = 35°C',ylabel='kWh / sesję');restyle(ax);fig.tight_layout();fig.savefig(FIG/'04_aux_energy.png',dpi=180);plt.close(fig)
 # 05: SOH scenarios (modeled, not NASA)
 fig,ax=plt.subplots(figsize=(11.6,5.5));
 for Ta,c in [(15,BLUE),(25,TEAL),(35,ORANGE)]:
  vals=[x for x in summary if x['ambient_C']==Ta and x['strategy']=='GS_LIFE'][0]
  l=life_model(Config(),vals['mean_Tc_C'],vals['Ipeak_A'],Ta,.50)
  ax.plot(l[:,0],l[:,1],color=c,linewidth=3,label=f'klimat {Ta}°C · {l[-1,1]:.1f}%')
 ax.axhline(80,ls='--',c=RED,lw=1.6,label='Próg projektu 80%')
 ax.set(title='Scenariuszowy SOH dla GS_LIFE · model niezwalidowany',xlabel='Czas [lata]',ylabel='SOH [%]',ylim=(60,103));restyle(ax);ax.legend(loc='lower left');fig.tight_layout();fig.savefig(FIG/'05_soh_scenarios.png',dpi=180);plt.close(fig)
 # 06: PI vs GS, direct isolates schedule, at 35 C
 fig,ax=plt.subplots(figsize=(11.6,5.2));
 for st in ['PI','GS']:
  a=trace[(st,35.)];ax.plot(a[:,0],a[:,5],color=PALETTE[st],linewidth=2.8,label=st)
 ax.set(title='Izolowany test harmonogramu: sygnał chłodzenia PI vs GS',xlabel='Czas [min]',ylabel='Sterowanie u [0–1]');restyle(ax);ax.legend();fig.tight_layout();fig.savefig(FIG/'06_PI_vs_GS_u.png',dpi=180);plt.close(fig)
 # 07 NASA metadata from THIRD-PARTY summary only
 fig,ax=plt.subplots(figsize=(11.0,5.4)); names=['B0005','B0006','B0007','B0018'];fst=[1.857,2.035,1.891,1.855];lst=[1.325,1.186,1.433,1.341];xx=np.arange(4)
 ax.bar(xx-.18,fst,width=.36,color=BLUE,label='Pierwszy pomiar [Ah]');ax.bar(xx+.18,lst,width=.36,color=ORANGE,label='Ostatni pomiar [Ah]')
 ax.set_xticks(xx,names);ax.set(title='NASA PCoE · opublikowane wartości skrajne (zestawienie wtórne)',ylabel='Pojemność rozładowania [Ah]');restyle(ax);ax.legend();
 ax.text(.5,-.20,'Źródło liczb: Lemonergy / opracowanie wtórne danych NASA · brak tu pełnych szeregów czasowych',ha='center',transform=ax.transAxes,color=MUTED,fontsize=8)
 fig.subplots_adjust(bottom=.23);fig.savefig(FIG/'07_nasa_published_endpoints.png',dpi=180);plt.close(fig)


def run():
 cfg=Config()
 summary=[]; traces={}; lifes=[]
 for Ta in (15.,25.,35.):
  for st in STRATS:
   d=run_session(cfg,st,Ta)
   traces[(st,Ta)]=d.pop('trace'); summary.append(d)
   aux=np.array(traces[(st,Ta)])
   meanTc=float(np.mean(aux[:,1])); imax=float(np.max(aux[:,4])); park=.5 if st=='GS_LIFE' else .78
   d['mean_Tc_C']=meanTc; d['Ipeak_A']=imax
   yy=life_model(cfg,meanTc,imax,Ta,park)
   lifes.append((st,Ta,float(yy[-1,1]),float(yy[-1,2]),float(yy[-1,3])))
   if Ta==35.:save_csv(f'session_35C_{st}.csv',aux,['time_min','Tc_C','Ts_C','SOC','I_A','u','Qgen_W','Qcool_W','Paux_W','FF','integrator','e_K','I_therm_A'])
 save_csv('sessions_summary.csv',[[d[k] for k in d] for d in summary],list(summary[0]))
 save_csv('life_summary.csv',lifes,['strategy','ambient_C','SOH_10y_pct','Dcal_pp','Dcyc_pp'])
 # Isolated PI vs GS, with identical environment and current profile. NO sensors estimated in this model.
 robustness=[]
 for r,gc,gcool,taOffset in itertools.product((.85,1.,1.15),(.8,1.,1.2),(.8,1.,1.2),(-3.,0.,3.)):
  c=replace(cfg,R_scale=r,Gcs_scale=gc,Gcool_scale=gcool)
  for st in ('PI_SAFE','GS_SAFE'):
   d=run_session(c,st,35.+taOffset,False)
   robustness.append([st,r,gc,gcool,taOffset,d['Tmax_C'],d['time_min'],d['status']])
 save_csv('robustness_35C.csv',robustness,['strategy','R_multiplier','Gcs_multiplier','Gcool_multiplier','Ta_offset_C','Tmax_C','time_min','status'])
 # fixed-gain analytic thermal Jacobian near operating conditions (for unsaturated, fixed operating point)
 poles=[]
 for soc in np.linspace(.25,.79,5):
  for st in ('PI','GS'):
   Kp,Ki=gains(cfg,soc,st)
   I=120.; Tc=30.;Ts=27.;u=.3; R=rpack(cfg,soc,Tc)
   # local plant Jacobian; derivatives R(Tc) and Qcool(Ts) in active, non-saturated regime
   dR_dTc=-.002*cfg.Rn
   A=np.array([[1+cfg.dt*(I*I*dR_dTc-cfg.Gcs)/cfg.Cc,cfg.dt*cfg.Gcs/cfg.Cc,0],
               [cfg.dt*(cfg.Gcs-cfg.Gcool*(Ts-cfg.Tcool)*Kp)/cfg.Cs,
                 1-cfg.dt*(cfg.Gcs+cfg.Gamb+cfg.Gcool*u)/cfg.Cs,
                 -cfg.dt*cfg.Gcool*(Ts-cfg.Tcool)/cfg.Cs],
               [cfg.dt*Ki,0,1]])
   poles.append([st,float(soc),float(max(abs(np.linalg.eigvals(A))))])
 save_csv('local_frozen_jacobian.csv',poles,['strategy','SOC','max_abs_lambda'])
 make_figures(summary,traces)
 # Consistency tests (not empirical validation)
 checks={
  'cases':len(summary),'results_complete':all(d['status']=='DONE' for d in summary),
  'SOH_finite':all(np.isfinite(row[2]) for row in lifes),
  'SOC_terminal_ok':all(abs(d['SOC_end']-cfg.soc_target)<1.e-9 for d in summary),
  'energy_balance_residual_max_J':max(d['energy_balance_residual_J'] for d in summary),
  'temperature_limit_safes_35':{s:next(d for d in summary if d['strategy']==s and d['ambient_C']==35)['Tmax_C']<=cfg.Tlim for s in ('PI_SAFE','GS_SAFE','GS_LIFE')},
  'n_robustness':len(robustness),'PI_GS_35_RMSE':{s:next(d for d in summary if d['strategy']==s and d['ambient_C']==35)['RMSE_error_K'] for s in ('PI','GS')}
 }
 (RESULT/'quality_checks.json').write_text(json.dumps(checks,indent=2,ensure_ascii=False))
 print(json.dumps(checks,indent=2,ensure_ascii=False))
 for Ta in (15,25,35):
  print('\nAMBIENT',Ta)
  for d in summary:
   if d['ambient_C']==Ta:
    soh=next(y for y in lifes if y[0]==d['strategy'] and y[1]==Ta)[2]
    print('%-8s %5.1f min %5.1f C  %5.3f kWh  SOH %.1f%%'%(d['strategy'],d['time_min'],d['Tmax_C'],d['energy_aux_kWh'],soh))

if __name__=='__main__':run()
