function v = ocv_nmc(P, soc)
%OCV_NMC  Napięcie obwodu otwartego ogniwa NMC/grafit [V] w funkcji SOC od 0 do 1.
v = lin_interp(P.ocv_soc, P.ocv_v, soc);
end
