function T=btms_local_jacobian(c)
% LOCAL JACOBIAN SENSITIVITY, NOT a proof of stability: linearization points
% are NOT independently computed as stationary equilibria.
SOC=linspace(.25,.79,5); rows=cell(10,3); row=0;
for soc=SOC
 for strategy={'PI','GS'}
  st=strategy{1}; [Kp,Ki]=btms_gains(c,soc,st);
  I=120;Ts=27;u=.3;
  dR_dTc=-.002*c.Rn;
  A=[1+c.dt*(I^2*dR_dTc-c.Gcs)/c.Cc, c.dt*c.Gcs/c.Cc, 0;...
     c.dt*(c.Gcs-c.Gcool*(Ts-c.Tcool)*Kp)/c.Cs,...
     1-c.dt*(c.Gcs+c.Gamb+c.Gcool*u)/c.Cs,...
     -c.dt*c.Gcool*(Ts-c.Tcool)/c.Cs;...
     c.dt*Ki,0,1];
  row=row+1;rows(row,:)={string(st),soc,max(abs(eig(A)))};
 end
end
T=cell2table(rows,'VariableNames',{'strategy','SOC','max_abs_lambda'});
end
