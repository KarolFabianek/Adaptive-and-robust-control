function P = bms_params()
%BMS_PARAMS  Parametry modelu pakietu, regulatorów, starzenia i użytkowania.
%
%   P = bms_params() zwraca strukturę z parametrami. Przy każdej wartości
%   podane jest źródło:
%     [W]  wartość z wykładu,
%     [L]  rząd wielkości z literatury (źródła w docs/DOKUMENTACJA.md),
%     [Z]  założenie projektowe.
%   Prąd ładowania jest dodatni, prąd rozładowania ujemny. Temperatury
%   podawane są w °C i przeliczane na K tylko w równaniach Arrheniusa.

%% Pakiet 96s50p z ogniw 18650 NMC/grafit
P.ns         = 96;      % [W] liczba ogniw połączonych szeregowo
P.np         = 50;      % [W] liczba ogniw połączonych równolegle
P.Q_cell_Ah  = 3.5;     % [W] pojemność nominalna ogniwa [Ah]
P.V_nom_cell = 3.6;     % [W] napięcie nominalne ogniwa [V]
P.V_max_cell = 4.20;    % [L] napięcie końca ładowania w fazie CV [V]
P.V_min_cell = 3.00;    % [L] napięcie odcięcia rozładowania [V]

% Napięcie obwodu otwartego w funkcji SOC, typowa krzywa NMC/grafit [L]
P.ocv_soc = [0    0.05 0.10 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1.00];
P.ocv_v   = [3.00 3.35 3.47 3.57 3.63 3.68 3.74 3.82 3.91 4.00 4.08 4.18];

%% Model zastępczy ogniwa 1RC (nowe ogniwo, 25°C)
% Suma R0 + R1 = 28 mOhm odpowiada rezystancji ogniwa z wykładu [W]
P.R0_ref  = 0.018;      % [L] rezystancja omowa [Ohm]
P.R1_ref  = 0.010;      % [L] rezystancja polaryzacji [Ohm]
P.tau1    = 40;         % [L] stała czasowa gałęzi RC [s]
P.Ea_R    = 22e3;       % [L] energia aktywacji rezystancji [J/mol]
P.kR_soc  = 0.20;       % [W] wzrost rezystancji przy niskim SOC: 1 + 0,2(0,5 - SOC)

%% Anoda grafitowa i litowanie
% Potencjał anody: phi_an = U_an(SOC) - I_ogniwa R_an(T, SOH).
% Gdy phi_an spada poniżej 0 V względem Li/Li+, na anodzie osadza się lit.
P.x0      = 0.03;       % [L] stopień zlitowania anody przy SOC = 0
P.x100    = 0.80;       % [L] stopień zlitowania anody przy SOC = 1
P.R_an_ref = 0.014;     % [Z] rezystancja anody przy 25°C [Ohm], przy 1C litowanie poniżej około 14°C
P.Ea_an    = 50e3;      % [L] energia aktywacji przenoszenia ładunku [J/mol]
P.phi_margin = 0.015;   % [Z] zapas potencjału anody w strategii LIFE [V]
P.k_pl     = 1.0;       % [Z] udział prądu w litowaniu na 1 V nadpotencjału [1/V]
P.f_pl_max = 0.10;      % [Z] największy udział prądu w litowaniu [-]
P.eta_irr  = 0.20;      % [L] część osadzonego litu tracona trwale [-]

%% Model cieplny dwuwęzłowy (z wykładu)
P.m_cell  = 0.048;      % [W] masa ogniwa [kg]
P.cp      = 900;        % [W] ciepło właściwe [J/(kg K)]
P.C_frac  = 0.76;       % [W] udział pojemności cieplnej w rdzeniu [-]
P.Gcs     = 1650;       % [W] przewodność rdzeń-powierzchnia [W/K]
P.Gamb    = 25;         % [W] przewodność powierzchnia-otoczenie [W/K]
P.Gcool   = 470;        % [W] przewodność powierzchnia-ciecz przy u = 1 [W/K]
P.Qcool_max = 6500;     % [W] największa moc chłodzenia [W]
P.T_chill = 18;         % [W] temperatura cieczy z chillera [°C]
P.COP     = 2.6;        % [W] współczynnik wydajności chillera [-]
P.P_pump  = 400;        % [W] moc pompy przy u = 1 [W]
P.Qheat_max = 5000;     % [Z] moc grzałki PTC w obiegu cieczy [W]
P.T_heat_fluid = 45;    % [Z] największa temperatura cieczy grzewczej [°C]
P.eta_heat = 0.95;      % [Z] sprawność grzałki [-]
P.P_standby = 100;      % [Z] pobór BMS i pompy w czuwaniu na postoju [W]

%% Regulator temperatury PI i gain scheduling (z wykładu)
P.Kp      = 0.0725;     % [W] wzmocnienie proporcjonalne dla rho0 = 17 K [1/K]
P.Ki      = 47.5e-6;    % [W] wzmocnienie całkujące [1/(K s)]
P.rho0    = 17;         % [W] punkt projektowy rho = Ts - Tchill [K]
P.gs_min  = 1;          % [W] najmniejszy mnożnik nastaw [-]
P.gs_max  = 3;          % [W] największy mnożnik nastaw [-]
P.ff_gain = 0.70;       % [W] wzmocnienie kompensacji strat cieplnych [-]
P.Tref_charge = 30;     % [W] temperatura zadana rdzenia podczas ładowania [°C]
P.T_derate_start = 36.5;% [W] początek redukcji prądu przez nadzór [°C]
P.T_derate_full  = 39.5;% [W] pełna redukcja prądu przez nadzór [°C]
P.T_lim   = 40;         % [W] dopuszczalna temperatura rdzenia [°C]
P.Kh      = 0.25;       % [Z] wzmocnienie regulatora grzania [1/K]
P.T_precond = 22;       % [Z] temperatura podgrzania przed szybkim ładowaniem [°C]

%% Ładowanie
P.I_dc_max   = 300;     % [W] największy prąd ładowania DC pakietu, około 1,71C [A]
P.I_dc_min   = 20;      % [Z] najmniejszy prąd ładowania DC [A]
P.soc_taper  = 0.70;    % [W] profil z wykładu: redukcja prądu od 70% SOC
P.I_taper    = 130;     % [W] profil z wykładu: prąd przy 80% SOC [A]
P.I_dc_derated = 110;   % [W] prąd przy pełnej redukcji przez nadzór [A]
P.P_ac       = 11e3;    % [Z] moc ładowarki AC (wallbox) [W]
P.I_cutoff_C = 0.05;    % [L] koniec fazy CV przy prądzie C/20 [-]
% Dopuszczalny prąd w funkcji temperatury w typowym BMS [L]
P.std_T  = [-20  -10   0    10   20   45   50   55];
P.std_C  = [0.05 0.10 0.30 0.70 1.71 1.71 0.50 0.0];

%% Starzenie (model półempiryczny)
% Utrata pojemności jest sumą trzech składowych: Q_cal + Q_cyc + Q_pl.
% Kalendarzowa: Q_cal = k_cal t_eq^z_cal, t_eq w dniach przy 25°C i SOC 50%.
% Cykliczna:    Q_cyc = k_cyc FEC_eq^z_cyc, FEC_eq to ważona liczba cykli.
P.T_ref_aging = 25;     % [L] temperatura odniesienia [°C]
P.z_cal   = 0.75;       % [L] wykładnik czasu (Schmalstieg i in. 2014)
P.k_cal   = 0.09/3650^0.75; % [Z] 9% utraty po 10 latach w 25°C przy SOC 50%
P.Ea_cal  = 55e3;       % [L] energia aktywacji starzenia kalendarzowego [J/mol]
P.alpha_V = 1.79;       % [L] wpływ napięcia, 2,2 razy szybciej przy SOC 100% niż 50% [1/V]
P.z_cyc   = 0.5;        % [L] wykładnik liczby cykli
P.k_cyc   = 0.12/sqrt(1000); % [Z] 12% utraty po 1000 cyklach w 25°C przy 1C
P.Ea_cyc  = 30e3;       % [L] energia aktywacji wzrostu SEI (Waldmann 2014) [J/mol]
P.b_C     = 0.35;       % [L] wpływ prądu: exp(b_C (C - 1))
P.b_socc  = 1.0;        % [Z] dodatkowe zużycie cykli powyżej 80% SOC
P.gamma_R = 2.5;        % [L] wzrost rezystancji: R = R_ref (1 + gamma_R (1 - SOH))
P.SOH_EOL = 0.80;       % [W] kryterium końca życia baterii
P.years   = 10;         % [W] horyzont symulacji [lata]

%% Profil użytkowania
P.km_per_day   = 41;    % [Z] dzienny przebieg, około 15 000 km rocznie
P.kWh_per_100km = 17;   % [Z] zużycie energii w mieście [kWh/100 km]
P.dc_per_month = 2;     % [Z] liczba szybkich ładowań w trasie na miesiąc
P.P_highway    = 30e3;  % [Z] moc w trasie, około 130 km/h [W]
P.kWh_per_100km_hwy = 23; % [Z] zużycie energii na autostradzie [kWh/100 km]
P.trip_km      = 150;   % [Z] długość jednego odcinka trasy [km]
P.soc_dc_end   = 0.80;  % [W] docelowy SOC szybkiego ładowania

%% Nadrzędna pętla SOH (strategia LIFE_ADAPT)
P.SOH_target_10y = 0.82;% [Z] cel pętli po 10 latach, 2 p.p. zapasu nad 80%
P.lambda0  = 0.30;      % [Z] początkowy poziom ochrony (0 komfort, 1 pełna ochrona)
P.Kp_lam   = 8;         % [Z] wzmocnienie proporcjonalne pętli SOH
P.Ki_lam   = 1.5;       % [Z] wzmocnienie całkujące pętli SOH na miesiąc
P.sigma_soh_meas = 0.005; % [Z] odchylenie standardowe pomiaru pojemności [-]
P.rls_lambda = 0.85;    % [Z] współczynnik zapominania estymatora SOH [-]

%% Wielkości pochodne
P = bms_derive(P);
end
