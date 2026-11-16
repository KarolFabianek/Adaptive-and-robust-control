function btms_sfcn_life80(block)
% Level-2 MATLAB S-function. R2025b: discrete states [Tc; Ts; SOC; z].
% Input: ambient temperature. Output: the 4 states. No interpreted Fcn block.
% Calls EXACTLY btms_step(), used by the ordinary MATLAB solver.
setup(block);
end

function setup(block)
block.NumDialogPrms = 0;
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
% The demo is initialized at 35 C, 25% SOC. z is the PI integrator state.
block.Dwork(1).Data = [35; 35; 0.25; 0];
end

function outputStates(block)
block.OutputPort(1).Data = block.Dwork(1).Data;
end

function updateStates(block)
c = btms_cfg();
x = block.Dwork(1).Data;
Ta = double(block.InputPort(1).Data);
if x(3) < c.soc_target - 1e-10
    [xnext, ~] = btms_step(c, 'GS_LIFE', Ta, x);
    block.Dwork(1).Data = xnext;
end
end
