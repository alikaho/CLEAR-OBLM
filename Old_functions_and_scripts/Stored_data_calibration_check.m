
screen_idx = 2; % screen index set (1,2,3,4) corresponding to (390, 620, 730, 810) respectively


% Calibration parameters
screen_names = [390, 620, 730, 810];
realdist = [20.592,26.04,29.745,32.528]'; % distances in meters of reference screens [4 x 1]
realpix  = [2293,1288,918,552]'; % pixel positions of reference screens [4 x 1]
light_speed = 3*10^8; % speed of light
refr_idx = 1.46; % silicon refractive index
total_beam_length = 36.2814; % total length (42m?) of beamline (from Alex's result above) in meters

% Call back stored signal

Fiber_up_saved = table2array(readtable("Calibration saved data/Saved_" + num2str(screen_names(screen_idx)) + "_up.txt"));
Fiber_down_saved = table2array(readtable("Calibration saved data/Saved_" + num2str(screen_names(screen_idx)) + "_down.txt"));
plot(Fiber_up_saved)
hold on
plot(Fiber_down_saved)

% Find the calibrated difference in the upstream and downstream excess
% fiber. And use this value to calculate the distance to the beam loss
% point. 
diff_excess_fiber = Calibrate_excess_fiber(screen_names, realdist, 2, Fiber_up_saved, Fiber_down_saved)
beam_loss_dist = Find_beam_loss_dist(Fiber_up_saved, Fiber_down_saved, diff_excess_fiber)


function [rise_idx] = Find_rise_time_idx(in_data)
    % Function finds the indices (ie time samples) in the signal array 
    % where any beam loss has occurred. It finds where the UPSTREAM
    % input data has an average gradient (over 10 samples) higher
    % than a certain threshold and returns the index of that point.
    % Inputs:
        % in_data: input signal (1x1000 array)
    % Outputs:
        % rise_idx: array of indices where beam loss occurred

        gradients_up = gradient(in_data); % instantaneous gradients of upstream data 
        window_size = 10;
        mean_gradients_up = movmean(gradients_up, window_size); % mean gradients over every 10 samples
        
        
        % use first 200 samples to represent the steady-state
        % background signal (with no beam loss). The average of this
        % gives the baseline offset.
        % max(in_data - background) gives the peak signal
        % deviation from the baseline. define threshold gradient as
        % 1/50th of the peak signal amplitude per ns:

        % Calculate the threshold gradient
        background = mean(in_data(1:200));
        t_width = 1; % time resolution of the signal (in ns)
        threshold_rise = 50; % empirically chosen for the threshold_grad: a valid loss should have slope 1/50th of the peak signal amplitude per ns
        % smaller threshold_rise gives higher threshold            
        threshold_grad = max(in_data - background) / (threshold_rise/t_width);


        candidates = find(mean_gradients_up > threshold_grad)

        if isempty(candidates)
            rise_idx = 0;
        else
            rise_idx = candidates(1);
        end

    
    % % find the places where the gradient exceeds the threshold:
    % candidate = find(mean_gradients_up == max(mean_gradients_up)); % find index of maximum gradient
    % 
    % 
    % 
    % if isempty(candidate)
    %     rise_idx = 0;
    %     return
    % elseif mean_gradients_up(candidate) > threshold_grad % check whether maximum gradient exceeds the threshold
    %     rise_idx = candidate;
    % else
    %     rise_idx = 0;
    % end
    
end

function [rise_idx] = Find_rise_time_idx_2(in_data)
    % Function finds the indices (ie time samples) in the signal array 
    % where any beam loss has occurred. It finds where the UPSTREAM
    % input data has an average gradient (over 10 samples) higher
    % than a certain threshold and returns the index of that point.
    % Inputs:
        % in_data: input signal (1x1000 array)
    % Outputs:
        % rise_idx: array of indices where beam loss occurred

    gradients_up = gradient(in_data); % instantaneous gradients of upstream data 
    sup = max(size(in_data)); 
    t_width = 1; % time resolution of the signal (in ns)
    threshold_rise = 50; % empirically chosen for the threshold_grad: a valid loss should have slope 1/50th of the peak signal amplitude per ns
    % smaller threshold_rise gives higher threshold
    
    % use first 200 samples to represent the steady-state
    % background signal (with no beam loss). The average of this
    % gives the baseline offset.
    % max(data_up(:)-mean(data_up(1:200)) gives the peak signal
    % deviation from the baseline. define threshold gradient as
    % 1/50th of the peak signal amplitude per ns:
    threshold_grad = max(in_data(:)-mean(in_data(1:200)))/(threshold_rise/t_width); 

    
    % find the mean gradients for every 10 samples to compare with
    % the threshold gradient:
    mean_gradients_up = zeros(sup); 
    for i = 1:sup-10
        mean_gradients_up(i) = mean(gradients_up(i:i+10));
    end        

    % find the places where the gradient exceeds the threshold:
    candidates = find(mean_gradients_up > threshold_grad); % indices of positions which are candidates for beam loss positions (can be multiple)
    min_samples_between_losses = 20; % minimum amount of samples between beam loss positions (empirically determine)

    % impose that the beam loss positions cannot be too close
    % together:
    rise_indices = [];

    if ~isempty(candidates)
        rise_indices(1) = candidates(1);
        for i = 2:length(candidates)
            if candidates(i) - rise_indices(end) >= min_samples_between_losses % checking the separation between beam loss positions is greater than some minimum value 
                rise_indices(end+1) = candidates(i); %#ok<AGROW> % fix this - can't preallocate given size determined by function
            end
        end    
    else 
        rise_indices = 0;
    end            

    rise_idx = rise_indices(1);

end





function [beam_loss_dist] = Find_beam_loss_dist(up_data, down_data, diff_excess_fiber)
    % This function finds the beam loss position (in meters) from
    % the start of the beamline, using the time difference between
    % the time index of the upstream beam loss and the time index
    % of the downstream beam loss. 

    % loss_idx_up: time index of beam loss using Find_rise_time_idx
    % on the upstream (averaged) signal 
    % loss_idx_down: time index of beam loss using Find_rise_time_idx
    % on the downstream (averaged) signal 

    light_speed = 3*10^8; % speed of light
    refr_idx = 1.46; % silicon refractive index
    total_beam_length = 36.2814; % total length (42m?) of beamline (from Alex's result above) in meters

    time_diff = Find_time_diff(up_data,down_data); % time difference between upstream beam loss rising edge and downstream beam loss rising edge in ns
    beam_loss_dist = (- light_speed/refr_idx * time_diff * 10^-9 + diff_excess_fiber + total_beam_length)/2 ; % calculation of beam loss position 

end

function [beam_loss_dist] = Find_beam_loss_dist_NEW(time_diff)
    % This function finds the beam loss position (in meters) from
    % the start of the beamline, using the time difference between
    % the time index of the upstream beam loss and the time index
    % of the downstream beam loss. 

    % loss_idx_up: time index of beam loss using Find_rise_time_idx
    % on the upstream (averaged) signal 
    % loss_idx_down: time index of beam loss using Find_rise_time_idx
    % on the downstream (averaged) signal 

    % time_diff = Find_time_diff(app); % time difference between upstream beam loss rising edge and downstream beam loss rising edge in ns
    light_speed = 3*10^8; % speed of light
    refr_idx = 1.46; % silicon refractive index
    total_beam_length = 36.2814; % total length (42m?) of beamline (from Alex's result above) in meters
    diff_excess_fiber = 1.2906;
    beam_loss_dist = (- light_speed/refr_idx * time_diff * 10^-9 + diff_excess_fiber + total_beam_length)/2 ; % calculation of beam loss position 

end




function time_diff = Find_time_diff(up_data, down_data)
    % Function calls Acquire_signal to get the averaged upstream and
    % downstream signals, then uses Find_rise_time_idx to find the
    % time of beam loss. Calculates the time difference between the
    % upstream and downstream beam loss.

    loss_indices_up = Find_rise_time_idx(up_data);  
    loss_indices_down = Find_rise_time_idx(down_data);
    % 
    % loss_idx_up = loss_indices_up(1); % only take the first rising edge
    % loss_idx_down = loss_indices_down(1);

    loss_idx_up = 408; % only take the first rising edge
    loss_idx_down = 327;

    time_diff = loss_idx_down - loss_idx_up;
end


function diff_excess_fiber = Calibrate_excess_fiber(screen_names, realdist, screen_idx, up_data, down_data)
    % Function uses the known 620 screen position to calibrate the
    % distance where the beam is lost, by calculating the
    % difference in length between the upstream and downstream
    % excess fiber. 
    % Inputs:
        % button_idx: index 1, 2, 3, 4 corresponding to screens
        % 390, 620, 730, and 810 respectively
    light_speed = 3*10^8; % speed of light
    refr_idx = 1.46; % silicon refractive index
    total_beam_length = 36.2814; % total length (42m?) of beamline (from Alex's result above) in meters
    
    screen_dist = realdist(screen_idx);
    time_diff = Find_time_diff(up_data, down_data); 
    diff_excess_fiber = light_speed/refr_idx * 10^-9 * time_diff - total_beam_length + 2*screen_dist; % downstream excess fibre length minus upstream excess fibre length. (expecting to be negative)

    disp(['Calibrated excess fiber lengths using screen ' num2str(screen_names(screen_idx)) '. Calibrated difference in upstream and downstream fiber lengths = ' num2str(diff_excess_fiber) ' m.']);

end


