function quality_tests()
% Unit/invariant tests, not empirical validation.
c=btms_cfg();
assert(abs(c.Qah-175)<1e-10);
assert(abs(c.Rn-.05376)<1e-10);
assert(abs(c.En_kWh-60.48)<1e-10);
for st={'CC','PI','GS','PI_FF','GS_FF','PI_SAFE','GS_SAFE','GS_LIFE'}
 for Ta=[15,25,35]
  [s,T]=btms_run_session(c,st{1},Ta);
  assert(strcmp(s.status,'DONE') && abs(s.SOC_end-.8)<1e-9);
  assert(all(T(:,6)>=0 & T(:,6)<=1));
  assert(all(T(:,8)>=0)); % Qcool >= 0
  % Tozsamosc algebraiczna kroku Eulera - chroni spojnosc kodu, nie waliduje fizyki.
  assert(s.energy_balance_residual_J<1e-7);
  L=btms_life(c,s.mean_Tc_C,s.Ipeak_A,Ta,.5);
  assert(all(diff(L.SOH_pct)<=1e-9)); % SOH must NOT recover by seasonal temperature
 end
end
% Nominalnie przy 35 C wszystkie strategie z regulatorem trzymaja Tc < 40 C.
for st={'PI','GS','PI_SAFE','GS_SAFE','GS_LIFE'}
    s=btms_run_session(c,st{1},35); assert(s.Tmax_C<40,'%s >= 40 C',st{1});
end
% Model SOH: chlodniejszy postoj i nizszy SOC postoju starzeja mniej (niezmiennik).
[s,tr]=btms_run_session(c,'GS_LIFE',35);
[~,ordinary]=btms_life_goal(c,mean(tr(:,2)),max(tr(:,5)),35,35,.5,300);
[~,conditional]=btms_life_goal(c,mean(tr(:,2)),max(tr(:,5)),35,23,.4,300);
assert(s.Tmax_C<40 && conditional.SOH_10y_pct>ordinary.SOH_10y_pct);
% btms_life i btms_life_goal to ten sam model - musza dac ten sam wynik,
% gdy temperatura postoju = temperatura otoczenia ladowania.
L=btms_life(c,mean(tr(:,2)),max(tr(:,5)),35,.5);
assert(abs(L.SOH_pct(end)-ordinary.SOH_10y_pct)<1e-9,'btms_life != btms_life_goal');
% Zbieznosc numeryczna jawnego Eulera: dt=5 s vs dt=1 s (35 C).
c1=c; c1.dt=1;
for st={'PI','GS_SAFE','GS_LIFE'}
    a=btms_run_session(c,st{1},35); b=btms_run_session(c1,st{1},35);
    assert(abs(a.Tmax_C-b.Tmax_C)<0.1 && abs(a.time_min-b.time_min)<0.2, ...
        'Brak zbieznosci dt dla %s: %.3f vs %.3f C',st{1},a.Tmax_C,b.Tmax_C);
end
% Liniaryzacja w punkcie rownowagi: kazdy osiagalny punkt jest lokalnie stabilny,
% a przy 120 A rownowaga istnieje w kazdym klimacie.
J=btms_local_jacobian(c);
assert(all(J.max_abs_lambda(J.feasible)<1));
assert(all(J.feasible(J.I_A==120)));
% GS po Ts-Tcool: w punkcie projektowym rho0 rowny PI, nigdy ponizej nastaw PI.
[kp1,ki1]=btms_gains(c,'GS',c.Tcool+c.gs_rho0); [kp0,ki0]=btms_gains(c,'PI',c.Tcool+c.gs_rho0);
assert(kp1==kp0 && ki1==ki0);
for Ts=[10 20 30 40 50], assert(btms_gains(c,'GS',Ts)>=c.Kp_const); end
fprintf('Unit and invariance checks passed. Life scenario is model-only.\n');
end
