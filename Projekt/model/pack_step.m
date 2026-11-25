function [x_next, y] = pack_step(P, x, I_pack, u, Ta, dt, SOH)
%PACK_STEP  Jeden krok modelu elektryczno-cieplnego pakietu 96s50p.
%
%   [x_next, y] = pack_step(P, x, I_pack, u, Ta, dt, SOH)
%
%   Stan  x = [Tc; Ts; SOC; V1]
%     Tc  – temperatura rdzenia ogniw [°C]
%     Ts  – temperatura powierzchni / płyty chłodzącej [°C]
%     SOC – stan naładowania (względem aktualnej pojemności) 0..1
%     V1  – napięcie gałęzi RC ogniwa [V]
%   Wejścia
%     I_pack – prąd pakietu [A] (+ ładowanie, - rozładowanie)
%     u      – sterowanie termiczne -1..1 (u > 0 chłodzenie, u < 0 grzanie)
%     Ta     – temperatura otoczenia [°C]
%     dt     – krok [s]
%     SOH    – stan zdrowia (skaluje pojemność i rezystancje)
%   Wyjście y (wektor):
%     1 V_cell   napięcie zacisków ogniwa [V]
%     2 Q_gen    moc strat w pakiecie [W]
%     3 Q_act    ciepło odebrane przez układ termiczny [W] (+ chłodzenie)
%     4 P_aux    moc elektryczna układu termicznego [W]
%     5 phi_an   potencjał anody względem Li/Li+ [V]
%     6 I_cell   prąd ogniwa [A]
%     7 f_pl     udział prądu idący w litowanie [-]
%     8 bal      reszta bilansu energii kroku [J] (kontrola, ~0)
%     9 R0       rezystancja omowa ogniwa [Ohm]
%
%   Model elektryczny: ECM 1RC, dyskretyzacja dokładna gałęzi RC.
%   Model cieplny: dwa węzły (rdzeń–powierzchnia), jak na wykładzie,
%   całkowany niejawną metodą Eulera (stabilną dla dowolnego kroku,
%   co pozwala symulować 10 lat z krokiem 60 s na postoju).

Tc = x(1); Ts = x(2); soc = x(3); V1 = x(4);
I_cell = I_pack/P.np;
Q_cell = P.Q_cell_Ah*SOH;

%% Elektryka (ECM 1RC)
[R0, R1, R_an] = cell_resistance(P, Tc, soc, SOH);
a = exp(-dt/P.tau1);
V1_next = V1*a + R1*(1 - a)*I_cell;
V_cell  = ocv_nmc(P, soc) + V1 + R0*I_cell;
% straty: omowe + polaryzacyjne (średnia w kroku)
V1m   = 0.5*(V1 + V1_next);
q_cell = I_cell^2*R0 + V1m^2/R1;
Q_gen  = P.ns*P.np*q_cell;
soc_next = soc + I_cell*dt/(3600*Q_cell);
soc_next = min(max(soc_next, 0), 1);

%% Anoda – potencjał i litowanie (tylko przy ładowaniu)
phi_an = anode_ocp(P, soc) - max(I_cell, 0)*R_an;
if I_cell > 0 && phi_an < 0
    f_pl = min(P.f_pl_max, P.k_pl*(-phi_an));
else
    f_pl = 0;
end

%% Termika – układ chłodzenia / grzania
% Chłodzenie (u > 0):  Q = min(Qmax u, Gcool u (Ts - Tchill))  (wykład)
% Grzanie   (u < 0):   Q = -min(Qheat_max |u|, Gcool |u| (Tfluid - Ts))
Gk = 0; Tk = 0; Qconst = 0;
if u > 0
    if Ts > P.T_chill
        if P.Gcool*u*(Ts - P.T_chill) < P.Qcool_max*u
            Gk = P.Gcool*u; Tk = P.T_chill;       % zakres przewodności
        else
            Qconst = P.Qcool_max*u;               % nasycenie mocy chłodzenia
        end
    end
elseif u < 0
    Qconst = -min(P.Qheat_max*(-u), P.Gcool*(-u)*max(P.T_heat_fluid - Ts, 0));
end

% Niejawny Euler: A [Tc'; Ts'] = b
A11 = P.Cc/dt + P.Gcs;   A12 = -P.Gcs;
A21 = -P.Gcs;            A22 = P.Cs/dt + P.Gcs + P.Gamb + Gk;
b1  = P.Cc/dt*Tc + Q_gen;
b2  = P.Cs/dt*Ts + P.Gamb*Ta + Gk*Tk - Qconst;
dd = A11*A22 - A12*A21;
Tc_next = ( A22*b1 - A12*b2)/dd;
Ts_next = (-A21*b1 + A11*b2)/dd;

Q_act = Gk*(Ts_next - Tk) + Qconst;
Q_amb = P.Gamb*(Ts_next - Ta);
bal = P.Cc*(Tc_next - Tc) + P.Cs*(Ts_next - Ts) - dt*(Q_gen - Q_amb - Q_act);

% Moc elektryczna układu termicznego
if Q_act >= 0
    P_aux = P.P_pump*abs(u)^3 + Q_act/P.COP;
else
    P_aux = P.P_pump*abs(u)^3 + (-Q_act)/P.eta_heat;
end

x_next = [Tc_next; Ts_next; soc_next; V1_next];
y = [V_cell, Q_gen, Q_act, P_aux, phi_an, I_cell, f_pl, bal, R0];
end
