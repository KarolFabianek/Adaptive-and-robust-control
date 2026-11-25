function y = lin_interp(xt, yt, x)
%LIN_INTERP  Szybka interpolacja liniowa z nasyceniem na krańcach tablicy.
%   y = lin_interp(xt, yt, x) – xt rosnąca, x skalar.
%   Zastępuje interp1 w pętlach symulacji (kilkakrotnie szybsza dla
%   krótkich tablic) i jest zgodna z generacją kodu (MATLAB Function w Simulinku).
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
