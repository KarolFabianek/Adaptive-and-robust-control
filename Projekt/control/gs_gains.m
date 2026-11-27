function [Kp, Ki, k] = gs_gains(P, Ts, gs)
%GS_GAINS  Nastawy regulatora PI chłodzenia (z wykładu).
%
%   gs = 0   stałe nastawy dobrane w punkcie pracy rho0 = 17 K
%   gs = 1   gain scheduling według rho = Ts - Tchill:
%            k = clip(rho0/rho, 1, 3), Kp = Kp0 k, Ki = Ki0 k
%   Wzmocnienie obiektu dQcool/du = Gcool (Ts - Tchill) maleje, gdy
%   powierzchnia stygnie. Harmonogram utrzymuje stały iloczyn Kp Gcool rho,
%   czyli stałe wzmocnienie pętli otwartej.
if gs
    rho = max(Ts - P.T_chill, P.rho0/P.gs_max);
    k = min(P.gs_max, max(P.gs_min, P.rho0/rho));
else
    k = 1;
end
Kp = P.Kp*k;
Ki = P.Ki*k;
end
