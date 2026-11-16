function c = btms_cfg()
% Jawne PARAMETRY PROJEKTOWE, nie pomiary fabryczne ani kalibracja NASA.
c.dt=5; c.Tmax=7200;
c.ns=96; c.np=50; c.U_cell=3.6; c.Ah_cell=3.5; c.R_cell=0.028;
c.mass_cell=0.048; c.cp=900; c.Cfrac=0.76;
c.Gcs=165; c.Gamb=25; c.Gcool=470; c.Tmax_cool=6500;
c.Tcool=18; c.COP=2.6; c.pump_max=400;
c.soc0=.25; c.soc_target=.80; c.taper_soc=.70;
c.I_max=300; c.I_taper=130;
c.Tref=30; c.Tlim=40; c.thermal_start=36.5; c.thermal_full=39.5; c.I_min=110;
c.ff_gain=.70; c.Kp_const=.0725; c.Ki_const=47.5e-6;
c.R_scale=1; c.Gcs_scale=1; c.Gcool_scale=1;
c.k_cal=.025; c.k_cyc=5e-5;
c.socpark_regular=.78; c.socpark_life=.50;
c.days_per_year=300; c.EFC_per_session=.55;
c.Qah=c.np*c.Ah_cell;
c.Rn=c.ns*c.R_cell/c.np;
c.Ctotal=c.ns*c.np*c.mass_cell*c.cp;
c.Cc=c.Cfrac*c.Ctotal; c.Cs=(1-c.Cfrac)*c.Ctotal;
c.En_kWh=c.ns*c.U_cell*c.Qah/1000;
end
