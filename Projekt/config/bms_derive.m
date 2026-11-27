function P = bms_derive(P)
%BMS_DERIVE  Wielkości pochodne parametrów pakietu.
%   Wywołać po każdej zmianie P, na przykład w analizie Monte Carlo.
P.Q_pack_Ah = P.np*P.Q_cell_Ah;                     % 175 Ah
P.E_pack_kWh = P.ns*P.V_nom_cell*P.Q_pack_Ah/1000;  % 60.48 kWh
P.Rn_pack = P.ns*(P.R0_ref + P.R1_ref)/P.np;        % 53.76 mOhm
P.C_total = P.ns*P.np*P.m_cell*P.cp;                % 207 kJ/K
P.Cc = P.C_frac*P.C_total;
P.Cs = (1 - P.C_frac)*P.C_total;
P.Rgas = 8.314;
end
