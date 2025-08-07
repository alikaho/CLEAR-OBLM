
function [beam_loss_dist_fiber] = Find_fiber_loss_dist_combined_readout(refr_idx, loss_idx_up, loss_idx_down)
    % This function finds the beam loss position (in meters) from
    % the start of the beamline, using the time difference between
    % the time index of the upstream beam loss and the time index
    % of the downstream beam loss. 

    % loss_idx_up: time index of beam loss using Find_rise_time_idx
    % on the upstream (averaged) signal 
    % loss_idx_down: time index of beam loss using Find_rise_time_idx
    % on the downstream (averaged) signal 

    % physical parameters:
    light_speed = 3*10^8; % speed of light
    % total_beam_length = 36.2814; % total length (42m?) of beamline (from Alex's result above) in meters

    % find the time difference between the upstream and downstream
    % rise times
    time_diff = loss_idx_up - loss_idx_down;

    % determine the distance along the fiber of the loss
    beam_loss_dist_fiber = (light_speed/refr_idx * time_diff * 10 ^-9)/(2) ; % calculation of beam loss position 

    
end