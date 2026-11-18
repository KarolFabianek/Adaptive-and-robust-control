function T=btms_local_jacobian(c)
% LOKALNA LINIARYZACJA W PUNKCIE ROWNOWAGI - NIE jest dowodem stabilnosci
% globalnej ani stabilnosci LPV.
% Punkt pracy = stan ustalony petli PI (integrator => Tc = Tref):
%   Ts* = Tref - Qgen/Gcs,  Qcool* = Qgen - Gamb*(Ts*-Ta),  u* = z* z bilansu.
% Nastawy GS liczone w Ts*; ich pochodna po Ts mnozy e = 0, wiec A ma te sama postac.
% Jesli punkt NIE istnieje (Ts* <= Tcool albo u* poza [0,1]), Tref jest
% nieosiagalne przy danym pradzie: petla musi sie nasycic, a analiza liniowa
% nie ma zastosowania (feasible=false, lambda=NaN).
ambients=[15 25 35]; currents=[120 210 300]; SOC=[.25 .52 .79]; strategies={'PI','GS'};
rows=cell(numel(ambients)*numel(currents)*numel(SOC)*numel(strategies),9); row=0;
for Ta=ambients
 for I=currents
  for soc=SOC
   for k=1:numel(strategies)
    st=strategies{k};
    Gcs=c.Gcs*c.Gcs_scale; G=c.Gcool*c.Gcool_scale;
    Tc=c.Tref;
    R=c.Rn*c.R_scale*min(1.4,max(.7,1+.2*(.5-soc)+.002*(25-Tc)));
    Qgen=I^2*R;
    Ts=Tc-Qgen/Gcs;
    [Kp,Ki]=btms_gains(c,st,Ts);
    Qcool=Qgen-c.Gamb*(Ts-Ta);
    if G*(Ts-c.Tcool) <= c.Tmax_cool   % galaz Gcool*u*(Ts-Tcool)
        Bu=G*(Ts-c.Tcool); u=Qcool/Bu; Bs=G*u;
    else                               % galaz limitu mocy Tmax_cool*u
        Bu=c.Tmax_cool; u=Qcool/Bu; Bs=0;
    end
    feasible = Ts>c.Tcool && u>=0 && u<=1;
    lam=NaN; tau=NaN;
    if feasible
        dR_dTc=-.002*c.Rn*c.R_scale;
        A=[1+c.dt*(I^2*dR_dTc-Gcs)/c.Cc, c.dt*Gcs/c.Cc, 0; ...
           c.dt*(Gcs-Bu*Kp)/c.Cs, 1-c.dt*(Gcs+c.Gamb+Bs)/c.Cs, -c.dt*Bu/c.Cs; ...
           c.dt*Ki, 0, 1];
        lam=max(abs(eig(A)));
        tau=-c.dt/log(lam);
    end
    row=row+1;
    rows(row,:)={string(st),soc,I,Ta,Ts,u,feasible,lam,tau};
   end
  end
 end
end
T=cell2table(rows,'VariableNames',{'strategy','SOC','I_A','Ta_C', ...
    'Ts_eq_C','u_eq','feasible','max_abs_lambda','tau_dominant_s'});
end
