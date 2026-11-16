function [Kp,Ki] = btms_gains(c,soc,strategy)
% Harmonogram SOC jawny i liniowo interpolowany.
if any(strcmp(strategy,{'CC','PI','PI_FF','PI_SAFE'}))
    Kp=c.Kp_const; Ki=c.Ki_const;
else
    a=min(1,max(0,(soc-.2)/.6));
    Kp=.055+.035*a; Ki=(35+25*a)*1e-6;
end
end
