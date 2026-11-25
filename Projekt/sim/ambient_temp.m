function Ta = ambient_temp(C, day_of_year, hour, dT)
%AMBIENT_TEMP  Temperatura otoczenia [°C] dla klimatu C (climate_profile).
%   dT – opcjonalne przesunięcie (np. +2 K w analizie odporności).
if nargin < 4, dT = 0; end
Ta = C.T_mean - C.A_year*cos(2*pi*(day_of_year - 15)/365) ...
     + C.A_day*cos(2*pi*(hour - 15)/24) + dT;
end
