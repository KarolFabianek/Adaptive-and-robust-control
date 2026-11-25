function C = climate_profile(name)
%CLIMATE_PROFILE  Sinusoidalny model temperatury otoczenia (rok + doba).
%
%   Ta(dzień, godzina) = T_mean - A_year cos(2 pi (d - 15)/365)
%                               + A_day  cos(2 pi (h - 15)/24)
%   Minimum roczne w połowie stycznia, maksimum dobowe o 15:00.
%   Wartości są przybliżeniem średnich klimatycznych (nie dane pogodowe).
%
%   'opole'  – klimat umiarkowany chłodny (PL):  średnio  8.5°C, I ~ -2°C, VII ~ 19°C
%   'madryt' – klimat ciepły (ES):                średnio 15.0°C, I ~  6°C, VII ~ 25°C
%   'dubaj'  – klimat gorący (AE):                średnio 28.0°C, I ~ 19°C, VII ~ 36°C
switch lower(name)
    case 'opole'
        C = struct('name', 'Opole', 'T_mean', 8.5, 'A_year', 10.5, 'A_day', 5);
    case 'madryt'
        C = struct('name', 'Madryt', 'T_mean', 15.0, 'A_year', 9.5, 'A_day', 7);
    case 'dubaj'
        C = struct('name', 'Dubaj', 'T_mean', 28.0, 'A_year', 8.5, 'A_day', 6);
    otherwise
        error('climate_profile:unknown', 'Nieznany klimat: %s', name);
end
C.key = lower(name);
end
