function [Kp, Ki] = controller_gains(p, strategy, Ts)
% Nastawy regulatora PI.
% PI, PI_FF, PI_SAFE - stale nastawy.
% GS, GS_FF, GS_SAFE, GS_LIFE - gain scheduling po rho = Ts - Tcool.
% Wzmocnienie chlodzenia Gcool*(Ts - Tcool) maleje gdy powierzchnia stygnie,
% wiec nastawy rosna jak rho0/rho (ograniczone do [gs_min, gs_max]).

if strncmp(strategy, 'GS', 2)
    rho = max(Ts - p.Tcool, p.rho0/p.gs_max);
    k = min(p.gs_max, max(p.gs_min, p.rho0/rho));
    Kp = p.Kp*k;
    Ki = p.Ki*k;
else
    Kp = p.Kp;
    Ki = p.Ki;
end
end
