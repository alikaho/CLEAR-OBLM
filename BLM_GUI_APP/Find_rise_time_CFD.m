
function rise_idx = Find_rise_time_CFD(raw_signal)
% Find_rise_time_CFD function finds the rise time index for smoothed input
% signal using the constant fraction descriminator method with a threshold
% of 40%. It only finds one rise index - the point closest to the maximum
% in the signal. 
    
    % take mean of first 200 signals as background and find the background
    % corrected signal (remove the DC offset)    
    background = mean(raw_signal(1:size(raw_signal, 2)/5));
    signal = raw_signal - background;
    [max_val, max_idx] = max(signal, [], 'all'); % the value and index of the maximum signal

    threshold = 0.4 * max_val; % 40% threshold CFD crossing value

    % search only the data before the maximum signal is reached:
    pre_peak_signal = signal(2:max_idx);

    % find all the possible crossings before the signal maximum where the
    % signal at the index is below the threshold and then above the
    % threshold at the index+1. 
    crossings = find(pre_peak_signal(1:end-1) < threshold & pre_peak_signal(2:end) >= threshold);

    if isempty(crossings)
        % if there are no crossings that satisfy the threshold condition,
        % set rise_idx to 1 (the first index)
        rise_idx = 1;
    else
        % if there is one or more crossing, take the crossing that is closest to the maximum
        [~, closest_crossing_idx] = min(abs(crossings - max_idx));
        rise_idx = crossings(closest_crossing_idx);
    end

end