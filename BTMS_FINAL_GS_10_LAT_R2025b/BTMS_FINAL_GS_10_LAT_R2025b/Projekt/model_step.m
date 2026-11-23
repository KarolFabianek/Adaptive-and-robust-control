function [x_next, out] = model_step(p, strategy, Ta, x)
% Jeden krok symulacji (metoda Eulera, krok p.dt).
% Model cieplny z dwoma wezlami: rdzen (Tc) i powierzchnia (Ts) + regulator chlodzenia.
%   x   = [Tc; Ts; SOC; z]   (z - stan integratora PI)
%   out = [I, u, Qgen, Qcool, Paux, FF, z, e, I_thermal, bilans]

Tc = x(1);
Ts = x(2);
soc = x(3);
z = x(4);

%% Prad ladowania
% profil: 300 A do 70% SOC, potem liniowo do 130 A przy 80% SOC
f = (soc - p.soc_taper)/(p.soc_end - p.soc_taper);
f = min(1, max(0, f));
I_profile = p.I_max*(1 - f) + p.I_taper*f;

% nadzor pradu: redukcja pradu gdy Tc > 36.5 C (strategie SAFE i LIFE)
if any(strcmp(strategy, {'PI_SAFE', 'GS_SAFE', 'GS_LIFE'}))
    fT = (Tc - p.T_derate_start)/(p.T_derate_full - p.T_derate_start);
    fT = min(1, max(0, fT));
    I_thermal = p.I_max - (p.I_max - p.I_min)*fT;
else
    I_thermal = p.I_max;
end

% GS_LIFE ma dodatkowy limit 210 A
if strcmp(strategy, 'GS_LIFE')
    I_cap = p.I_life;
else
    I_cap = p.I_max;
end

% w ostatnim kroku nie przekraczamy SOC docelowego
I_soc = (p.soc_end - soc)*p.Qah*3600/p.dt;
I = max(0, min([I_profile, I_thermal, I_cap, I_soc]));

%% Moc cieplna
kR = 1 + 0.2*(0.5 - soc) + 0.002*(25 - Tc);   % opor zalezy od SOC i temperatury
kR = min(1.4, max(0.7, kR));
R = p.Rn*kR;
Q_gen = I^2*R;

%% Regulator chlodzenia (PI + anti-windup + feedforward)
[Kp, Ki] = controller_gains(p, strategy, Ts);

if any(strcmp(strategy, {'PI_FF', 'GS_FF', 'PI_SAFE', 'GS_SAFE', 'GS_LIFE'}))
    FF = p.ff_gain*Q_gen/p.Qcool_max;
else
    FF = 0;
end

e = Tc - p.Tref;
if strcmp(strategy, 'CC')
    u = 0.20;            % stale chlodzenie 20%, bez regulatora
    z_next = z;
else
    u_raw = Kp*e + z + FF;
    u = min(1, max(0, u_raw));
    % anti-windup: nie calkujemy, gdy wyjscie jest nasycone
    if (u_raw >= 1 && e > 0) || (u_raw <= 0 && e < 0)
        z_next = z;
    else
        z_next = z + Ki*p.dt*e;
    end
end

%% Bilans cieplny
Q_cool = min(p.Qcool_max*u, p.Gcool*u*(Ts - p.Tcool));
Q_cool = max(0, Q_cool);
Q_amb = p.Gamb*(Ts - Ta);
Q_cs = p.Gcs*(Tc - Ts);

dTc = p.dt*(Q_gen - Q_cs)/p.Cc;
dTs = p.dt*(Q_cs - Q_amb - Q_cool)/p.Cs;

P_aux = p.P_pump*u^3 + Q_cool/p.COP;   % pompa + chiller

soc_next = min(p.soc_end, soc + I*p.dt/(3600*p.Qah));
x_next = [Tc + dTc; Ts + dTs; soc_next; z_next];

% kontrola kodu: zmiana energii = cieplo dostarczone - odebrane (powinno wyjsc ~0)
balance = p.Cc*dTc + p.Cs*dTs - p.dt*(Q_gen - Q_amb - Q_cool);

out = [I, u, Q_gen, Q_cool, P_aux, FF, z_next, e, I_thermal, balance];
end
