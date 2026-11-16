function main_btms()
% Punkt startowy (MATLAB; potrzebny jedynie MATLAB bazowy z table/writetable).
% UWAGA: nowa, jawna implementacja; wyniki NIE musza byc rowne starym slajdom.
root=fileparts(fileparts(mfilename('fullpath')));
out=fullfile(root,'results');fig=fullfile(root,'figures');
if ~exist(out,'dir'),mkdir(out);end
if ~exist(fig,'dir'),mkdir(fig);end
c=btms_cfg(); strategies={'CC','PI','GS','PI_FF','GS_FF','PI_SAFE','GS_SAFE','GS_LIFE'};
ambs=[15,25,35]; cases=struct([]); lrows=cell(24,5);idx=0;
for a=ambs
    for i=1:numel(strategies)
        st=strategies{i};idx=idx+1;
        [s,tr]=btms_run_session(c,st,a);cases=[cases;s]; %#ok<AGROW>
        park=c.socpark_regular;if strcmp(st,'GS_LIFE'),park=c.socpark_life;end
        L=btms_life(c,s.mean_Tc_C,s.Ipeak_A,a,park);
        lrows(idx,:)={string(st),a,L.SOH_pct(end),L.Dcal_pp(end),L.Dcyc_pp(end)};
        if a==35
            labels={'time_min','Tc_C','Ts_C','SOC','I_A','u','Qgen_W','Qcool_W','Paux_W','FF','integrator','e_K','I_therm_A'};
            writetable(array2table(tr,'VariableNames',labels),fullfile(out,['session_35C_' st '_matlab.csv']));
        end
    end
end
writetable(struct2table(cases),fullfile(out,'sessions_summary_matlab.csv'));
Life=cell2table(lrows,'VariableNames',{'strategy','ambient_C','SOH_10y_pct','Dcal_pp','Dcyc_pp'});
writetable(Life,fullfile(out,'life_summary_matlab.csv'));
% Model-based uncertainty stress test: does NOT constitute a formal robustness proof.
rr=cell(162,8);j=0;
for r=[.85,1,1.15]
for gc=[.8,1,1.2]
for gco=[.8,1,1.2]
for da=[-3,0,3]
    c2=c;c2.R_scale=r;c2.Gcs_scale=gc;c2.Gcool_scale=gco;
    for st={'PI_SAFE','GS_SAFE'}
        s=btms_run_session(c2,st{1},35+da);j=j+1;
        rr(j,:)={string(st{1}),r,gc,gco,da,s.Tmax_C,s.time_min,s.status};
    end
end
end
end
end
rr=cell2table(rr,'VariableNames',{'strategy','R_multiplier','Gcs_multiplier','Gcool_multiplier','Ta_offset_C','Tmax_C','time_min','status'});
writetable(rr,fullfile(out,'robustness_35C_matlab.csv'));
J=btms_local_jacobian(c);writetable(J,fullfile(out,'local_frozen_jacobian_matlab.csv'));
% NASA runs ONLY when requested: BTMS_MENU('nasa'). Never as part of basic experiments.
fprintf('NASA: opcjonalne; nie jest uruchamiane automatycznie.\n');
fprintf('BTMS completed: %d scenarios. Results in %s\n',numel(cases),out);
assert(all(arrayfun(@(v) v.status=="DONE",cases)),'Some cases did not finish');
assert(all(abs([cases.SOC_end]-c.soc_target)<1e-9),'SOC target mismatch');
assert(height(rr)==162,'Oczekiwano 162 testow niepewnosci');
assert(all(isfinite([cases.Tmax_C])) && all([cases.time_min]>0),'Niepoprawne wyniki sesji');
assert(all([cases.energy_balance_residual_J]<1e-7),'Energy balance broken');
end
