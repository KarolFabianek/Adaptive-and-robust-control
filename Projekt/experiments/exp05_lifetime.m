function [Sum, Tall] = exp05_lifetime()
%EXP05_LIFETIME  E05. Dziesięć lat eksploatacji: 4 strategie w 3 klimatach.
%
%   Główny wynik projektu: SOH po 10 latach oraz koszt jego utrzymania,
%   czyli energia zarządzania termicznego, czas szybkiego ładowania i średni
%   SOC (zapas zasięgu). Wykresy rysuje plot_e05 z pliku results/e05_lifetime.mat.
P = bms_params();
fprintf('\n=== E05: 10 lat eksploatacji ===\n');
strategies = {'STD_100','STD_90','LIFE','LIFE_ADAPT'};
climates = {'opole','madryt','dubaj'};
Tall = struct();
rows = {};
for c = 1:numel(climates)
    for s = 1:numel(strategies)
        tic;
        [T, info] = simulate_lifetime(P, strategies{s}, climates{c});
        Tall.(climates{c}).(strategies{s}) = T;
        rows(end+1, :) = {climates{c}, strategies{s}, 100*info.SOH_10y, 100*info.Q_cal, 100*info.Q_cyc, ...
            100*info.Q_pl, info.meets_80, info.E_TM_kWh_year, info.t_dc_mean_min, ...
            info.t_dc_max_min, info.Tc_max_active, info.Tc_max, 100*info.soc_mean, 100*info.soc_ac_mean, info.lambda_mean}; %#ok<AGROW>
        fprintf('   %-7s %-10s SOH(10 lat) = %5.1f%%  (%.1f s)\n', climates{c}, strategies{s}, 100*info.SOH_10y, toc);
    end
end
Sum = cell2table(rows, 'VariableNames', {'climate','strategy','SOH_10y_pct','loss_calendar_pct', ...
    'loss_cycle_pct','loss_plating_pct','meets_80pct','E_thermal_kWh_per_year', ...
    't_dc_mean_min','t_dc_max_min','Tc_max_operation_C','Tc_max_incl_parking_C','soc_mean_pct','soc_ac_target_mean_pct','lambda_mean'});
save_csv(Sum, 'e05_lifetime_summary');
root = fileparts(fileparts(mfilename('fullpath')));
save(fullfile(root, 'results', 'e05_lifetime.mat'), 'Tall', 'Sum');
for c = 1:numel(climates)
    for s = 1:numel(strategies)
        save_csv(Tall.(climates{c}).(strategies{s}), sprintf('e05_monthly_%s_%s', climates{c}, strategies{s}));
    end
end
disp(Sum);
plot_e05();
end
