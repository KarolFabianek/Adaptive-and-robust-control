function btms_sfcn_life80(block)
% Level-2 MATLAB S-function. R2025b: discrete states [Tc; Ts; SOC; z].
% Input: ambient temperature. Output: the 4 states. No interpreted Fcn block.
% Calls EXACTLY btms_step(), used by the ordinary MATLAB solver.
% Dialog parameter 1: initial pack temperature Ta0 [C] (= ambient at start).
% Poprawki po przegladzie: (1) warunek poczatkowy nie jest juz wpisany na
% sztywno (35 C), tylko pochodzi z parametru bloku; (2) po osiagnieciu
% SOC docelowego stan termiczny dalej ewoluuje (I=0, chlodzenie dziala),
% zamiast "zamrozenia" temperatury do konca symulacji.
setup(block);
end

function setup(block)
block.NumDialogPrms = 1;
block.DialogPrmsTunable = {'Nontunable'};
block.NumInputPorts = 1;
block.NumOutputPorts = 1;
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;
block.InputPort(1).Dimensions = 1;
block.InputPort(1).DatatypeID = 0;
block.InputPort(1).Complexity = 'Real';
block.InputPort(1).DirectFeedthrough = false;
block.OutputPort(1).Dimensions = 4;
block.OutputPort(1).DatatypeID = 0;
block.OutputPort(1).Complexity = 'Real';
block.SampleTimes = [5 0];
block.SimStateCompliance = 'DefaultSimState';
block.RegBlockMethod('PostPropagationSetup', @allocateState);
block.RegBlockMethod('InitializeConditions', @initialize);
block.RegBlockMethod('Outputs', @outputStates);
block.RegBlockMethod('Update', @updateStates);
end

function allocateState(block)
block.NumDworks = 1;
block.Dwork(1).Name = 'BTMS_state';
block.Dwork(1).Dimensions = 4;
block.Dwork(1).DatatypeID = 0;
block.Dwork(1).Complexity = 'Real';
block.Dwork(1).UsedAsDiscState = true;
end

function initialize(block)
% Start: pakiet w temperaturze otoczenia Ta0, SOC = soc0 z btms_cfg, z = 0.
c = btms_cfg();
Ta0 = double(block.DialogPrm(1).Data);
block.Dwork(1).Data = [Ta0; Ta0; c.soc0; 0];
end

function outputStates(block)
block.OutputPort(1).Data = block.Dwork(1).Data;
end

function updateStates(block)
c = btms_cfg();
x = block.Dwork(1).Data;
Ta = double(block.InputPort(1).Data);
% Po osiagnieciu SOC docelowego btms_step zwraca I=0 i SOC=const,
% a temperatury dalej sie zmieniaja (stygniecie pakietu przy chlodzeniu).
[xnext, ~] = btms_step(c, 'GS_LIFE', Ta, x);
block.Dwork(1).Data = xnext;
end
