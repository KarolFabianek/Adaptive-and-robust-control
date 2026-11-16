function [life, summary] = btms_life_goal(c,meanTc,Ipeak,Tcharge,Tstorage,SOCstorage,annualSessions)
% 10-year scenario: Tcharge controls cycling, Tstorage controls CALENDAR
% aging independently. This is CONDITIONAL feasibility, not validation.
% No storage HVAC energy is accounted for in this simplified analysis.
% Requested target: SOH(10y) >= 80% (capacity retention).
Dcal=0; Dcyc=0; rows=zeros(120,4);
cfac=1 + 0.2*max(0,Ipeak/c.Qah-1);
for m=1:120
    seasonal=7*sin(2*pi*(mod(m-.5,12))/12);
    deltaRoot=sqrt(m/12)-sqrt((m-1)/12);
    Dcal=Dcal+c.k_cal*deltaRoot * exp(.04*(Tstorage+seasonal-25)) * ...
        exp(1.1*(SOCstorage-.5));
    Dcyc=Dcyc+(annualSessions/12)*c.EFC_per_session*c.k_cyc * ...
        exp(.03*(meanTc+seasonal-25))*cfac;
    rows(m,:)=[m/12,100*max(0,1-Dcal-Dcyc),100*Dcal,100*Dcyc];
end
life=array2table(rows,'VariableNames',{'years','SOH_pct','Dcal_pp','Dcyc_pp'});
summary=table(Tcharge,Tstorage,SOCstorage,annualSessions, ...
    life.SOH_pct(end),life.Dcal_pp(end),life.Dcyc_pp(end), ...
    life.SOH_pct(end)>=80, ...
    'VariableNames',{'charging_ambient_C','storage_temperature_C','storage_SOC', ...
    'sessions_per_year','SOH_10y_pct','Dcal_pp','Dcyc_pp','meets_80'});
end
