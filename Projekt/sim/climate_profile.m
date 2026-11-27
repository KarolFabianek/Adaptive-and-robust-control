function C = climate_profile(name)
%CLIMATE_PROFILE  Sinusoidalny model temperatury otoczenia w roku i w dobie.
%
%   Ta(d, h) = T_mean - A_year cos(2 pi (d - 15)/365) + A_day cos(2 pi (h - 15)/24)
%   Minimum roczne przypada w połowie stycznia, maksimum dobowe o 15:00.
%   Wartości przybliżają średnie klimatyczne, nie są danymi pogodowymi.
%
%   opole    klimat umiarkowany: średnio 8,5°C, styczeń -2°C, lipiec 19°C
%   madryt   klimat ciepły:      średnio 15°C, styczeń 5,5°C, lipiec 24,5°C
%   dubaj    klimat gorący:      średnio 28°C, styczeń 19,5°C, lipiec 36,5°C
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
