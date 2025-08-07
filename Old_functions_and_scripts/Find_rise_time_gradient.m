function [rise_idx] = Find_rise_time_gradient(in_data)
    % Function finds the indices (ie time samples) in the signal array 
    % where any beam loss has occurred. It finds where the UPSTREAM
    % input data has an average gradient (over 10 samples) higher
    % than a certain threshold and returns the index of that point. NB the
    % gradient method is found to be the least accurate of the methods for
    % beam loss positioning. 
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
    threshold_rise = 40; % empirically chosen for the threshold_grad: a valid loss should have slope 1/50th of the peak signal amplitude per ns
    % smaller threshold_rise gives higher threshold            
    threshold_grad = max(in_data - background) / (threshold_rise/t_width);


    candidates = find(mean_gradients_up > threshold_grad);

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