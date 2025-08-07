function [up_data, down_data] = Acquire_signal(~)
    % This function acquires the raw upstream and downstream signals
    % over 1000 ns with one data point every 1ns. 

     % Acquire raw reading from oscilloscope ADC 
    Fiber_down_all = matlabJapc.staticGetSignal('SCT.USER.SETUP','CA.SCOPE10.CH02/Acquisition') ;
    Fiber_up_all = matlabJapc.staticGetSignal('SCT.USER.SETUP','CA.SCOPE10.CH01/Acquisition') ;            
    
    % Convert raw signal to physical signal (in volts)
    down_data = double(Fiber_down_all.value) .* Fiber_down_all.sensitivity + Fiber_down_all.offset;
    up_data = double(Fiber_up_all.value) .* Fiber_up_all.sensitivity + Fiber_up_all.offset;             

end
