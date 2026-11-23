function [res, data] = simulate_charging(p, strategy, Ta)
% Symulacja jednej sesji szybkiego ladowania 25% -> 80% SOC.
%   strategy - 'CC','PI','GS','PI_FF','GS_FF','PI_SAFE','GS_SAFE','GS_LIFE'
%   Ta       - temperatura otoczenia [C]
%   res      - podsumowanie sesji (struct)
%   data     - przebiegi w czasie (tabela)

x = [Ta; Ta; p.soc0; 0];   % na starcie pakiet ma temperature otoczenia
N = round(p.t_max/p.dt);
rec = zeros(N, 13);

n = 0;
t = 0;
E_aux = 0;       % energia chlodzenia [kWh]
E_heat = 0;      % cieplo wydzielone w ogniwach [kWh]
sum_e2 = 0;
n_sat = 0;
Tc_max = x(1);
max_balance = 0;

for k = 1:N
    if x(3) >= p.soc_end - 1e-10
        break
    end
    [x_next, o] = model_step(p, strategy, Ta, x);

    t = t + p.dt;
    E_aux = E_aux + o(5)*p.dt/3.6e6;
    E_heat = E_heat + o(3)*p.dt/3.6e6;
    sum_e2 = sum_e2 + o(8)^2;
    if o(2) >= 0.999999
        n_sat = n_sat + 1;      % chlodzenie na 100%
    end
    max_balance = max(max_balance, abs(o(10)));
    Tc_max = max(Tc_max, x_next(1));

    n = n + 1;
    rec(n,:) = [t/60, x_next(1), x_next(2), x_next(3), o(1:9)];
    x = x_next;
end
rec = rec(1:n,:);

data = array2table(rec, 'VariableNames', {'time_min','Tc_C','Ts_C','SOC','I_A','u', ...
    'Qgen_W','Qcool_W','Paux_W','FF','integrator','e_K','I_therm_A'});

res.strategy = string(strategy);
res.ambient_C = Ta;
res.time_min = t/60;
res.Tmax_C = Tc_max;
res.Tend_C = x(1);
res.energy_aux_kWh = E_aux;
res.energy_heat_kWh = E_heat;
res.SOC_end = x(3);
res.RMSE_error_K = sqrt(sum_e2/n);
res.sat_fraction = n_sat/n;
res.energy_balance_residual_J = max_balance;
res.points = n;
res.mean_Tc_C = mean(data.Tc_C);
res.Ipeak_A = max(data.I_A);
if x(3) >= p.soc_end - 1e-9
    res.status = "DONE";
else
    res.status = "TIMEOUT";
end
end
