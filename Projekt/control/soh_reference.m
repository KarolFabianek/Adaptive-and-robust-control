function s = soh_reference(P, t_years)
%SOH_REFERENCE  Trajektoria odniesienia („budżet zdrowia”) SOH(t).
%   SOH_ref(t) = 1 - (1 - SOH_target_10y) (t/10)^0.65
%   Wykładnik 0.65 leży między 0.5 (starzenie cykliczne ~ sqrt(Ah)) a 0.75
%   (kalendarzowe ~ t^0.75), więc trajektoria ma kształt naturalnego
%   starzenia – regulator nie „walczy” z szybszym spadkiem w 1. roku.
s = 1 - (1 - P.SOH_target_10y)*(max(t_years, 0)/P.years).^0.65;
end
