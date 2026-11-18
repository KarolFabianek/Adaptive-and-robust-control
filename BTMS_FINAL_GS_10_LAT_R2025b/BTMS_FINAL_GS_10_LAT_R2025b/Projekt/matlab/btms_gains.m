function [Kp,Ki] = btms_gains(c,strategy,Ts)
% Nastawy PI. Strategie PI*: stale nastawy (dostrojone w punkcie projektowym).
% Strategie GS*: GAIN SCHEDULING po rho = Ts - Tcool [K].
% Uzasadnienie: wzmocnienie obiektu dQcool/du = Gcool*(Ts-Tcool) zmienia sie
% z temperatura powierzchni (nie z SOC). PI dostrojono dla goracej powierzchni
% rho0 = 35 - 18 = 17 K; harmonogram utrzymuje iloczyn Kp*Gcool*rho staly,
% gdy rho maleje (kompensacja zmiennego wzmocnienia, Astrom i Wittenmark).
% Ograniczenie skali do [gs_smin, gs_smax] = [1, 3].
if any(strcmp(strategy,{'CC','PI','PI_FF','PI_SAFE'}))
    Kp=c.Kp_const; Ki=c.Ki_const;
else
    rho=max(Ts-c.Tcool, c.gs_rho0/c.gs_smax);
    k=min(c.gs_smax,max(c.gs_smin,c.gs_rho0/rho));
    Kp=c.Kp_const*k; Ki=c.Ki_const*k;
end
end
