function p = params()
% Parametry modelu pakietu, chlodzenia i regulatora.
% Wartosci projektowe (zalozenia), nie dane producenta.

% symulacja
p.dt = 5;            % krok [s]
p.t_max = 7200;      % maksymalny czas sesji [s]

% pakiet 96s50p, ogniwa 18650
p.ns = 96;
p.np = 50;
p.U_cell = 3.6;      % [V]
p.Ah_cell = 3.5;     % [Ah]
p.R_cell = 0.028;    % [Ohm]
p.m_cell = 0.048;    % [kg]
p.cp = 900;          % [J/(kg K)]
p.C_frac = 0.76;     % czesc pojemnosci cieplnej w rdzeniu

% model cieplny
% Gcs = 1650 W/K -> ok. 2.9 K/W na ogniwo (4800 ogniw), wg Bhundiya i in. (TFAWS 2018)
p.Gcs = 1650;        % rdzen -> powierzchnia [W/K]
p.Gamb = 25;         % powierzchnia -> otoczenie [W/K]
p.Gcool = 470;       % powierzchnia -> ciecz chlodzaca przy u = 1 [W/K]
p.Qcool_max = 6500;  % maksymalna moc chlodzenia [W]
p.Tcool = 18;        % temperatura cieczy [C]
p.COP = 2.6;         % sprawnosc chillera
p.P_pump = 400;      % moc pompy przy u = 1 [W]

% ladowanie
p.soc0 = 0.25;
p.soc_end = 0.80;
p.soc_taper = 0.70;  % od tego SOC prad maleje
p.I_max = 300;       % [A]
p.I_taper = 130;     % prad przy 80% SOC [A]
p.I_life = 210;      % limit pradu w strategii GS_LIFE [A]

% temperatury i nadzor pradu (SAFE, LIFE)
p.Tref = 30;            % temperatura zadana rdzenia [C]
p.Tlim = 40;            % limit projektowy [C]
p.T_derate_start = 36.5;
p.T_derate_full = 39.5;
p.I_min = 110;          % prad przy pelnej redukcji [A]

% regulator PI (dobrany dla Ts - Tcool = 17 K, tj. ok. 35 C)
p.Kp = 0.0725;
p.Ki = 47.5e-6;
p.ff_gain = 0.70;    % feedforward od mocy cieplnej I^2*R
% gain scheduling: Kp, Ki = PI * clip(rho0/(Ts - Tcool), gs_min, gs_max)
p.rho0 = 17;
p.gs_min = 1;
p.gs_max = 3;

% model starzenia (SOH)
p.k_cal = 0.025;
p.k_cyc = 5e-5;
p.soc_park = 0.78;       % SOC postoju (wszystkie strategie)
p.soc_park_life = 0.50;  % polityka postoju przy 50% SOC
p.sessions_per_year = 300;
p.EFC_per_session = 0.55;

% wielkosci pochodne
p.Qah = p.np*p.Ah_cell;                  % 175 Ah
p.Rn = p.ns*p.R_cell/p.np;               % 53.76 mOhm
p.C_total = p.ns*p.np*p.m_cell*p.cp;     % [J/K]
p.Cc = p.C_frac*p.C_total;
p.Cs = (1 - p.C_frac)*p.C_total;
p.E_kWh = p.ns*p.U_cell*p.Qah/1000;      % 60.48 kWh
end
