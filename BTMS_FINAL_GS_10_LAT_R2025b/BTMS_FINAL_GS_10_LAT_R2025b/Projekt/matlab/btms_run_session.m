function [S,tr] = btms_run_session(c,strategy,Ta)
% Powtarzalna sesja 25->80% SOC, jawny Euler dt=5 s.
x=[Ta;Ta;c.soc0;0]; maxN=round(c.Tmax/c.dt);
tr=zeros(maxN,13); n=0; t=0; qaux=0; qheat=0; rmse_sum=0; nsat=0; peak=x(1); maxres=0;
for k=1:maxN
    if x(3)>=c.soc_target-1e-10, break; end
    [xn,o]=btms_step(c,strategy,Ta,x);
    t=t+c.dt; qaux=qaux+o(5)*c.dt/3.6e6; qheat=qheat+o(3)*c.dt/3.6e6;
    rmse_sum=rmse_sum+o(8)^2; nsat=nsat+double(o(2)>=.999999);
    maxres=max(maxres,abs(o(10))); peak=max(peak,xn(1));
    n=n+1;
    tr(n,:)=[t/60,xn(1),xn(2),xn(3),o(1:6),o(7:9)];
    x=xn;
end
tr=tr(1:n,:);
if n==0, error('Pusta sesja: brak krokow symulacji'); end
S=struct('strategy',string(strategy),'ambient_C',Ta,'time_min',t/60,...
'Tmax_C',peak,'Tend_C',x(1),'energy_aux_kWh',qaux,'energy_heat_kWh',qheat,...
'SOC_end',x(3),'RMSE_error_K',sqrt(rmse_sum/size(tr,1)), ...
'sat_fraction',nsat/size(tr,1),'energy_balance_residual_J',maxres,...
'points',size(tr,1),'mean_Tc_C',mean(tr(:,2)),'Ipeak_A',max(tr(:,5)));
if x(3)>=c.soc_target-1e-9,S.status="DONE";else,S.status="TIMEOUT";end
end
