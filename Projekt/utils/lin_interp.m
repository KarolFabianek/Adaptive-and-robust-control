function y = lin_interp(xt, yt, x)
%LIN_INTERP  Interpolacja liniowa z nasyceniem na krańcach tablicy.
%   y = lin_interp(xt, yt, x), xt rosnąca, x skalar.
%   Dla krótkich tablic działa kilka razy szybciej niż interp1 i nadaje się
%   do generacji kodu w blokach MATLAB Function.
n = numel(xt);
if x <= xt(1)
    y = yt(1);
    return
elseif x >= xt(n)
    y = yt(n);
    return
end
k = 1;
while x > xt(k+1)
    k = k + 1;
end
w = (x - xt(k))/(xt(k+1) - xt(k));
y = yt(k) + w*(yt(k+1) - yt(k));
end
