function [u, z_next] = thermal_controller(P, cfg, z, Tc_hat, Ts, Qgen_hat, Tref, T_heat, dt)
%THERMAL_CONTROLLER  Regulator temperatury pakietu: PI lub GS z kompensacją i grzaniem.
%
%   [u, z_next] = thermal_controller(P, cfg, z, Tc_hat, Ts, Qgen_hat, Tref, T_heat, dt)
%     z         stan integratora
%     Tc_hat    estymata temperatury rdzenia [°C]
%     Ts        zmierzona temperatura powierzchni [°C]
%     Qgen_hat  estymowane straty cieplne I^2 R [W], wejście kompensacji
%     Tref      temperatura zadana chłodzenia [°C]
%     T_heat    próg grzania [°C], -Inf wyłącza grzanie
%   Sterowanie u leży w przedziale od -1 do 1 (u < 0 grzanie, u > 0 chłodzenie).
%   Działanie odwrotne: dodatni uchyb e = Tc - Tref zwiększa chłodzenie.
%   Anti-windup: całkowanie jest wstrzymane, gdy pogłębiałoby nasycenie.

% Grzanie przed szybkim ładowaniem i w jego trakcie
if Tc_hat < T_heat
    u = -min(1, P.Kh*(T_heat - Tc_hat));
    z_next = 0;
    return
end

switch cfg.cool_mode
    case 0
        u = 0; z_next = z;
    case 1
        u = cfg.cc_u; z_next = z;
    otherwise
        [Kp, Ki] = gs_gains(P, Ts, cfg.cool_mode == 3);
        e = Tc_hat - Tref;
        FF = 0;
        if cfg.ff
            FF = P.ff_gain*Qgen_hat/P.Qcool_max;
        end
        u_raw = Kp*e + z + FF;
        u = min(1, max(0, u_raw));
        if (u_raw >= 1 && e > 0) || (u_raw <= 0 && e < 0)
            z_next = z;
        else
            z_next = z + Ki*dt*e;
        end
end
end
