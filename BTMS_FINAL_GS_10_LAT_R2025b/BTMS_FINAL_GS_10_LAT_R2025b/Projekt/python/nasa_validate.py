"""Optional NASA PCoE *real-data* 70/30 baseline validation, not EV pack validation.
Usage: python python/nasa_validate.py nasa_data/B0005.mat
Or CSV with columns cycle,capacity_Ah; no fake measurements are generated.
"""
from __future__ import annotations
import argparse,sys
from pathlib import Path
import numpy as np
import pandas as pd
from scipy.io import loadmat
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
ROOT=Path(__file__).resolve().parents[1]

def load_cycles(file):
 file=Path(file)
 if not file.is_file():raise FileNotFoundError(f'Brak oryginalnego pliku NASA: {file}')
 if file.suffix.lower()=='.csv':
  v=pd.read_csv(file)
  if not {'cycle','capacity_Ah'}.issubset(v.columns):
   raise ValueError('CSV wymaga nagłówków cycle,capacity_Ah')
  return np.asarray(v['cycle'],dtype=float),np.asarray(v['capacity_Ah'],dtype=float)
 if file.suffix.lower()!='.mat':raise ValueError('Format wejścia: .mat lub .csv')
 m=loadmat(file,simplify_cells=True)
 raw=next((v for k,v in m.items() if not k.startswith('__')),None)
 if raw is None:raise ValueError('Plik MAT nie zawiera danych')
 if isinstance(raw,dict): raw=raw.get('cycle',raw)
 if isinstance(raw,np.ndarray):raw=raw.tolist()
 if isinstance(raw,dict):raw=[raw]
 cap=[]
 for cyc in raw:
  if not isinstance(cyc,dict):continue
  if str(cyc.get('type','')).strip().lower()!='discharge':continue
  data=cyc.get('data',{})
  if isinstance(data,dict) and 'Capacity' in data:
   try:
    q=float(np.asarray(data['Capacity']).reshape(-1)[0]);
    if np.isfinite(q) and q>0:cap.append(q)
   except (TypeError,ValueError):pass
 return np.arange(1,len(cap)+1,dtype=float),np.array(cap,dtype=float)

def validate(path):
 cycles,capacity=load_cycles(path)
 good=np.isfinite(cycles)&np.isfinite(capacity)&(capacity>0)
 cycles,capacity=cycles[good],capacity[good];idx=np.argsort(cycles);cycles=cycles[idx];capacity=capacity[idx]
 if len(cycles)<15:raise ValueError('Wymagane co najmniej 15 prawdziwych cykli')
 cut=int(.7*len(cycles));x=np.sqrt(cycles-cycles.min()+1)
 X=np.column_stack([np.ones(len(x)),x]);b=np.linalg.lstsq(X[:cut],capacity[:cut],rcond=None)[0]
 predicted=X@b
 pd.DataFrame({'discharge_index':cycles.astype(int), 'capacity_Ah':capacity, 'capacity_fit_Ah':predicted}).to_csv(ROOT/'results'/'nasa_B0005_discharge_python.csv',index=False)
 train=float(np.sqrt(np.mean((capacity[:cut]-predicted[:cut])**2)))
 test=float(np.sqrt(np.mean((capacity[cut:]-predicted[cut:])**2)))
 out=ROOT/'results'/'nasa_validation_python.csv';pd.DataFrame([{'source':Path(path).name,'n_cycles':len(x),'train_n':cut,'RMSE_train_Ah':train,'RMSE_test_Ah':test,'C_first_Ah':capacity[0],'C_last_Ah':capacity[-1]}]).to_csv(out,index=False)
 plt.figure(figsize=(9.5,5.1),facecolor='white');plt.plot(cycles,capacity,'o',ms=3,label='Prawdziwe dane NASA');plt.plot(cycles,predicted,'-',label='Dopasowanie Q=a+b sqrt(N)');plt.axvline(cycles[cut-1],color='grey',ls='--',label='Granica 70/30');plt.grid(alpha=.2);plt.xlabel('Cykl rozładowania');plt.ylabel('Pojemność [Ah]');plt.legend();plt.tight_layout();plt.savefig(ROOT/'figures'/'08_nasa_fit.png',dpi=170)
 print(f'NASA test N={len(x)} RMSE_test={test:.4f} Ah; rzeczywisty plik={path}')
 return test

if __name__=='__main__':
 a=argparse.ArgumentParser();a.add_argument('file',help='Autentyczny B0005.mat lub własny CSV cycle,capacity_Ah'); args=a.parse_args()
 try:validate(args.file)
 except Exception as exc:print('NASA validation NOT RUN:',exc,file=sys.stderr);sys.exit(2)
