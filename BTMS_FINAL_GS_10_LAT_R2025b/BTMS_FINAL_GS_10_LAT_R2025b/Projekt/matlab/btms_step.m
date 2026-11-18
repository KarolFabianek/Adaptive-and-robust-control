function [xn,o] = btms_step(c,strategy,Ta,x)
% Jeden krok dt modelu termicznego + PI + anti-windup + feedforward.
% x = [Tc; Ts; SOC; z]. Brak modelu OCV/CC-CV; taper SOC jest przyblizeniem.
Tc=x(1); Ts=x(2); soc=x(3); z=x(4);
clamp=@(v,a,b) min(b,max(a,v));
f=clamp((soc-c.taper_soc)/(c.soc_target-c.taper_soc),0,1);
Iprof=c.I_max*(1-f)+c.I_taper*f;
if any(strcmp(strategy,{'PI_SAFE','GS_SAFE','GS_LIFE'}))
    fT=clamp((Tc-c.thermal_start)/(c.thermal_full-c.thermal_start),0,1);
    Itherm=c.I_max-(c.I_max-c.I_min)*fT;
else
    Itherm=c.I_max;
end
if strcmp(strategy,'GS_LIFE'), Icap=210; else, Icap=c.I_max; end
I=max(0,min([Iprof,Itherm,Icap,(c.soc_target-soc)*c.Qah*3600/c.dt]));
R=c.Rn*c.R_scale*clamp(1+.2*(.5-soc)+.002*(25-Tc),.7,1.4);
Qgen=I^2*R;
[Kp,Ki]=btms_gains(c,strategy,Ts);
if any(strcmp(strategy,{'PI_FF','GS_FF','PI_SAFE','GS_SAFE','GS_LIFE'}))
    FF=c.ff_gain*Qgen/c.Tmax_cool;
else
    FF=0;
end
e=Tc-c.Tref;
if strcmp(strategy,'CC')
    u=.20; raw=u; zn=z;
else
    raw=Kp*e+z+FF;
    u=clamp(raw,0,1);
    if ~((raw>=1 && e>0) || (raw<=0 && e<0))
        zn=z+Ki*c.dt*e;
    else
        zn=z;
    end
end
Qcool=max(0,min(c.Tmax_cool*u,c.Gcool*c.Gcool_scale*u*(Ts-c.Tcool)));
Qamb=c.Gamb*(Ts-Ta);
Qcs=c.Gcs*c.Gcs_scale*(Tc-Ts);
dTc=c.dt*(Qgen-Qcs)/c.Cc;
dTs=c.dt*(Qcs-Qamb-Qcool)/c.Cs;
Paux=c.pump_max*u^3+Qcool/c.COP;
xn=[Tc+dTc; Ts+dTs; min(c.soc_target,soc+I*c.dt/(3600*c.Qah)); zn];
o=[I,u,Qgen,Qcool,Paux,FF,zn,e,Itherm, ...
    c.Cc*dTc+c.Cs*dTs-c.dt*(Qgen-Qamb-Qcool)];
end
