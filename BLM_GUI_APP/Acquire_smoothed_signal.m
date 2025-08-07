function [up_data, down_data, smooth_up_data, smooth_down_data] = Acquire_smoothed_signal(~)
    % This function acquires the raw upstream and downstream signals
    % both for singular measurements of 1000 time samples, and also
    % the averaged and smoothed (using Sgolayfilt) data for
    % upstream and downstream.

    % Acquire raw reading from oscilloscope ADC 
    Fiber_down_all = matlabJapc.staticGetSignal('SCT.USER.SETUP','CA.SCOPE10.CH02/Acquisition') ;
    Fiber_up_all = matlabJapc.staticGetSignal('SCT.USER.SETUP','CA.SCOPE10.CH01/Acquisition') ;            
    
    % Convert raw signal to physical signal (in volts)
    down_data = double(Fiber_down_all.value) .* Fiber_down_all.sensitivity + Fiber_down_all.offset;
    up_data = double(Fiber_up_all.value) .* Fiber_up_all.sensitivity + Fiber_up_all.offset;             

    % up_data = table2array(readtable("Calibration saved data/Saved_620_up.txt"));
    % down_data = table2array(readtable("Calibration saved data/Saved_620_down.txt"));

    % smooth_up_data = up_data;
    % smooth_down_data = down_data;
    [smooth_up_data, smooth_down_data] = Smooth_data(up_data, down_data);
    % 
    function [smooth_data_up, smooth_data_down] = Smooth_data(avg_up_data, avg_down_data)
        % Function smooths the averaged signal using a
        % Savitsky-Golay filter.
        order = 2; % polynomial fitting order of the smoothing filter.
        framelen = 31; % number of data points in each window at any one time. 
        smooth_data_up = sgolayfilt(avg_up_data, order, framelen);
        smooth_data_down = sgolayfilt(avg_down_data, order, framelen);

    end
    

end
