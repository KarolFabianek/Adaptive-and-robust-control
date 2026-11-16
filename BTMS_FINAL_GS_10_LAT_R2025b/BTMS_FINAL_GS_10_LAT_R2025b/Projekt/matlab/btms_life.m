function T = btms_life(c,meanTc,Ipeak,Tamb,park_soc)
% Scenariuszowy model SOH. Nie jest zidentyfikowany na NASA ani na pakiecie EV.
% Dkal monotonicznie kumuluje dodatnie przyrosty sqrt(t); amplituda sezonowa 7C.
Dcal=0;Dcyc=0; L=zeros(120,4);
cfac=1+.2*max(0,Ipeak/c.Qah-1);
for m=1:120
    seasonal=7*sin(2*pi*(mod(m-.5,12))/12);
    Tstore=Tamb+seasonal; Tcyc=meanTc+seasonal;
    droot=sqrt(m/12)-sqrt((m-1)/12);
    Dcal=Dcal+c.k_cal*droot*exp(.04*(Tstore-25))*exp(1.1*(park_soc-.5));
    Dcyc=Dcyc+(c.days_per_year/12)*c.EFC_per_session*c.k_cyc*exp(.03*(Tcyc-25))*cfac;
    L(m,:)=[m/12,100*max(0,1-Dcal-Dcyc),100*Dcal,100*Dcyc];
end
T=array2table(L,'VariableNames',{'years','SOH_pct','Dcal_pp','Dcyc_pp'});
end
