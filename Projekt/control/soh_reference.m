function s = soh_reference(P, t_years)
%SOH_REFERENCE  Trajektoria odniesienia SOH(t) dla pętli SOH.
%
%   SOH_ref(t) = 1 - (1 - SOH_target_10y) (t/10)^0,65
%   Wykładnik 0,65 leży między 0,5 (starzenie cykliczne) a 0,75 (starzenie
%   kalendarzowe). Trajektoria ma więc kształt naturalnego starzenia
%   i regulator nie reaguje na szybszy spadek pojemności w pierwszym roku.
s = 1 - (1 - P.SOH_target_10y)*(max(t_years, 0)/P.years).^0.65;
end
