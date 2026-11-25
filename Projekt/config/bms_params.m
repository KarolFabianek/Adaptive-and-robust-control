function P = bms_params()
%BMS_PARAMS  Wszystkie parametry modelu pakietu, regulatorów i starzenia.
%
%   P = bms_params() zwraca strukturę z parametrami. Każda wartość ma
%   komentarz: [W] = z wykładu (spójne z prezentacją BTMS_WYKLAD),
%   [L] = rząd wielkości z literatury (źródło w docs/DOKUMENTACJA.md),
%   [Z] = założenie projektowe (do zmiany w analizie wrażliwości).
%
%   Konwencja znaków: prąd ładowania DODATNI, rozładowania ujemny.
%   Temperatury w °C (w równaniach Arrheniusa przeliczane na K).

%% ---------------- Pakiet 96s50p (ogniwa 18650 NMC/grafit) -------------
P.ns         = 96;      % [W] ogniwa szeregowo
P.np         = 50;      % [W] ogniwa równolegle
P.Q_cell_Ah  = 3.5;     % [W] pojemność nominalna ogniwa [Ah]
P.V_nom_cell = 3.6;     % [W] napięcie nominalne [V]
P.V_max_cell = 4.20;    % [L] napięcie końca ładowania (faza CV) [V]
P.V_min_cell = 3.00;    % [L] napięcie odcięcia rozładowania [V]

% Charakterystyka OCV(SOC) – typowa krzywa NMC/grafit (tablica) [L]
P.ocv_soc = [0    0.05 0.10 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1.00];
P.ocv_v   = [3.00 3.35 3.47 3.57 3.63 3.68 3.74 3.82 3.91 4.00 4.08 4.18];

%% ---------------- Model zastępczy ECM 1RC (ogniwo, 25°C, nowe) ---------
% R0 + R1 = 28 mΩ, czyli tyle, ile rezystancja ogniwa z wykładu [W]
P.R0_ref  = 0.018;      % [L] rezystancja omowa [Ohm]
P.R1_ref  = 0.010;      % [L] rezystancja polaryzacji [Ohm]
P.tau1    = 40;         % [L] stała czasowa gałęzi RC [s]
P.Ea_R    = 22e3;       % [L] energia aktywacji rezystancji [J/mol]
P.kR_soc  = 0.20;       % [W] R rośnie przy niskim SOC: 1 + 0.2(0.5-SOC)

%% ---------------- Anoda grafitowa (ryzyko litowania – Li plating) ------
% Potencjał anody: phi_an = U_an(x) - I_cell*R_an(T, SOH)
% Li plating zachodzi, gdy phi_an < 0 V względem Li/Li+.
P.x0      = 0.03;       % [L] stechiometria anody przy SOC = 0
P.x100    = 0.80;       % [L] stechiometria anody przy SOC = 1
P.R_an_ref = 0.014;     % [Z] rezystancja anody (część R0+R1) przy 25°C [Ohm]
                        %     -> przy 1C litowanie zaczyna się ok. 14°C (SOC 80%)
P.Ea_an    = 50e3;      % [L] energia aktywacji przenoszenia ładunku [J/mol]
P.phi_margin = 0.015;   % [Z] zapas potencjału w strategii LIFE [V]
P.k_pl     = 1.0;       % [Z] udział prądu w litowaniu na 1 V nadpotencjału [1/V]
P.f_pl_max = 0.10;      % [Z] maks. udział prądu idący w litowanie [-]
P.eta_irr  = 0.20;      % [L] część zlitowanego Li tracona nieodwracalnie [-]

%% ---------------- Model cieplny dwuwęzłowy (z wykładu) -----------------
P.m_cell  = 0.048;      % [W] masa ogniwa [kg]
P.cp      = 900;        % [W] ciepło właściwe [J/(kg K)]
P.C_frac  = 0.76;       % [W] udział pojemności cieplnej w rdzeniu
P.Gcs     = 1650;       % [W] rdzeń -> powierzchnia [W/K]
P.Gamb    = 25;         % [W] powierzchnia -> otoczenie [W/K]
P.Gcool   = 470;        % [W] powierzchnia -> ciecz przy u = 1 [W/K]
P.Qcool_max = 6500;     % [W] maks. moc chłodzenia [W]
P.T_chill = 18;         % [W] temperatura cieczy z chillera [°C]
P.COP     = 2.6;        % [W] COP chillera
P.P_pump  = 400;        % [W] moc pompy przy u = 1 [W]
P.Qheat_max = 5000;     % [Z] grzałka PTC w obiegu cieczy [W]
P.T_heat_fluid = 45;    % [Z] maks. temperatura cieczy grzewczej [°C]
P.eta_heat = 0.95;      % [Z] sprawność grzałki
P.P_standby = 100;      % [Z] BMS + pompa w trybie czuwania na postoju [W]

%% ---------------- Regulator termiczny PI / GS (z wykładu) --------------
P.Kp      = 0.0725;     % [W] [1/K]  dobrane dla rho0 = 17 K
P.Ki      = 47.5e-6;    % [W] [1/(K s)]
P.rho0    = 17;         % [W] punkt projektowy rho = Ts - Tchill [K]
P.gs_min  = 1;          % [W]
P.gs_max  = 3;          % [W]
P.ff_gain = 0.70;       % [W] feedforward od mocy cieplnej
P.Tref_charge = 30;     % [W] temperatura zadana rdzenia przy ładowaniu [°C]
P.T_derate_start = 36.5;% [W] nadzór prądu – początek redukcji [°C]
P.T_derate_full  = 39.5;% [W] nadzór prądu – pełna redukcja [°C]
P.T_lim   = 40;         % [W] limit projektowy rdzenia [°C]
P.Kh      = 0.25;       % [Z] wzmocnienie grzania (P) [1/K]
P.T_precond = 22;       % [Z] cel podgrzania przed szybkim ładowaniem [°C]

%% ---------------- Ładowanie ---------------------------------------------
P.I_dc_max   = 300;     % [W] maks. prąd DC pakietu [A] (~1,71C)
P.I_dc_min   = 20;      % [Z] minimalny sensowny prąd DC [A]
P.soc_taper  = 0.70;    % [W] profil STD: redukcja prądu od 70% SOC
P.I_taper    = 130;     % [W] profil STD: prąd przy 80% SOC [A]
P.I_dc_derated = 110;   % [W] prąd przy pełnej redukcji termicznej [A]
P.P_ac       = 11e3;    % [Z] ładowarka AC (wallbox 11 kW) [W]
P.I_cutoff_C = 0.05;    % [L] koniec fazy CV, gdy I < C/20
% Statyczna tablica dopuszczalnego prądu w funkcji temperatury (typowy BMS) [L]
P.std_T  = [-20  -10   0    10   20   45   50   55];
P.std_C  = [0.05 0.10 0.30 0.70 1.71 1.71 0.50 0.0];

%% ---------------- Starzenie (model półempiryczny) -----------------------
% Q_loss = Q_cal + Q_cyc + Q_pl  (addytywność – założenie, jak w literaturze)
% Kalendarzowe: Q_cal = k_cal * t_eq^z_cal,   t_eq [dni] przy stresie ref.
% Cykliczne:    Q_cyc = k_cyc * FEC_eq^z_cyc, FEC_eq – ważone cykle
P.T_ref_aging = 25;     % [L] temperatura odniesienia [°C]
P.z_cal   = 0.75;       % [L] wykładnik czasu (Schmalstieg i in. 2014)
P.k_cal   = 0.09/3650^0.75; % [Z/L] 9% po 10 latach przy 25°C, SOC 50%
P.Ea_cal  = 55e3;       % [L] [J/mol]
P.alpha_V = 1.79;       % [L] wpływ napięcia: x2,2 przy 100% vs 50% SOC [1/V]
P.z_cyc   = 0.5;        % [L] wykładnik przepływu ładunku (~sqrt(Ah))
P.k_cyc   = 0.12/sqrt(1000); % [Z/L] 12% po 1000 FEC przy 25°C i 1C
P.Ea_cyc  = 30e3;       % [L] Arrhenius wzrostu SEI przy cyklowaniu (Waldmann 2014)
P.b_C     = 0.35;       % [L] wpływ C-rate: exp(b_C (C - 1))
P.b_socc  = 1.0;        % [Z] cykle przy SOC > 80% szkodzą bardziej
P.gamma_R = 2.5;        % [L] wzrost R: R = R_ref (1 + gamma_R (1 - SOH))
P.SOH_EOL = 0.80;       % [W] kryterium końca życia
P.years   = 10;         % [W] horyzont

%% ---------------- Profil użytkowania (10 lat) ---------------------------
P.km_per_day   = 41;    % [Z] ok. 15 000 km/rok
P.kWh_per_100km = 17;   % [Z] zużycie energii
P.dc_per_month = 2;     % [Z] szybkie ładowania w trasie na miesiąc
P.P_highway    = 30e3;  % [Z] moc w trasie: ok. 130 km/h przy 0,23 kWh/km [W]
P.kWh_per_100km_hwy = 23; % [Z] zużycie na autostradzie
P.trip_km      = 150;   % [Z] dystans jednego odcinka trasy (tam i z powrotem)
P.soc_dc_end   = 0.80;  % [W] SOC docelowy szybkiego ładowania

%% ---------------- Nadrzędna pętla SOH (strategia LIFE_ADAPT) ------------
P.SOH_target_10y = 0.82;% [Z] cel z zapasem 2 p.p. nad 80%
P.lambda0  = 0.30;      % [Z] początkowy poziom ochrony (0 = komfort, 1 = max ochrona)
P.Kp_lam   = 8;         % [Z] wzmocnienie P pętli SOH [1/(1)]
P.Ki_lam   = 1.5;       % [Z] wzmocnienie I pętli SOH [1/(1 miesiąc)]
P.sigma_soh_meas = 0.005; % [Z] szum estymaty pojemności (1 sigma)
P.rls_lambda = 0.85;    % [Z] współczynnik zapominania filtru SOH (miesięczny)

%% ---------------- Wielkości pochodne ------------------------------------
P = bms_derive(P);
end
