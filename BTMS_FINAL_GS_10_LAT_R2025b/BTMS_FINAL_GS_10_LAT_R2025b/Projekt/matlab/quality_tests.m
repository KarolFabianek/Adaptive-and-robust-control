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
  assert(s.energy_balance_residual_J<1e-7);
  L=btms_life(c,s.mean_Tc_C,s.Ipeak_A,Ta,.5);
  assert(all(diff(L.SOH_pct)<=1e-9)); % SOH must NOT recover by seasonal temperature
 end
end
% Feasibility conditions for 10-year 80% target (assumed model only).
[s,tr]=btms_run_session(c,'GS_LIFE',35);
[~,ordinary]=btms_life_goal(c,mean(tr(:,2)),max(tr(:,5)),35,35,.5,300);
[~,conditional]=btms_life_goal(c,mean(tr(:,2)),max(tr(:,5)),35,23,.4,300);
assert(s.Tmax_C<40 && ordinary.SOH_10y_pct<80 && conditional.SOH_10y_pct>=80);
fprintf('Unit and invariance checks passed. Conditional life scenario is model-only.\n');
end
