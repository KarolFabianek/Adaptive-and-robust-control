function btms_sfun(block)
% Level-2 MATLAB S-Function do modelu btms_model.slx.
% Stany dyskretne [Tc; Ts; SOC; z], krok 5 s, strategia GS_LIFE.
% Wejscie: temperatura otoczenia Ta. Wyjscie: wektor stanow.
% Parametr bloku: temperatura poczatkowa pakietu Ta0 [C].
% W kazdym kroku wywoluje te sama funkcje model_step co symulacja w MATLAB.
setup(block);
end

function setup(block)
block.NumDialogPrms = 1;
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
block.RegBlockMethod('PostPropagationSetup', @dwork_setup);
block.RegBlockMethod('InitializeConditions', @init_states);
block.RegBlockMethod('Outputs', @outputs);
block.RegBlockMethod('Update', @update);
end

function dwork_setup(block)
block.NumDworks = 1;
block.Dwork(1).Name = 'x';
block.Dwork(1).Dimensions = 4;
block.Dwork(1).DatatypeID = 0;
block.Dwork(1).Complexity = 'Real';
block.Dwork(1).UsedAsDiscState = true;
end

function init_states(block)
p = params();
Ta0 = block.DialogPrm(1).Data;
block.Dwork(1).Data = [Ta0; Ta0; p.soc0; 0];
end

function outputs(block)
block.OutputPort(1).Data = block.Dwork(1).Data;
end

function update(block)
p = params();
x = block.Dwork(1).Data;
Ta = block.InputPort(1).Data;
% po dojsciu do 80% SOC prad = 0, a pakiet dalej stygnie
block.Dwork(1).Data = model_step(p, 'GS_LIFE', Ta, x);
end
