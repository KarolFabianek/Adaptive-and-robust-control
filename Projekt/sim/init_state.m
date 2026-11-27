function st = init_state(T0, soc0, SOH)
%INIT_STATE  Stan początkowy układu zamkniętego, pakiet w równowadze termicznej.
if nargin < 3, SOH = 1; end
st.x = [T0; T0; soc0; 0];
st.z = 0;
st.Tc_hat = T0;
st.guard_on = false;
st.SOH = SOH;
st.SOH_hat = SOH;
end
