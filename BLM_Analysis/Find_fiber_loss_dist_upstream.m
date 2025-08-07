
function [beam_loss_dist_fiber] = Find_fiber_loss_dist_upstream(refr_idx, loss_idx_up)
    % This function finds the beam loss position (in meters) from
    % the start of the beamline, using the upstream time index only (there
    % will of course be a constant offset)

    % loss_idx_up: time index of beam loss using Find_rise_time_idx
    % on the upstream (averaged) signal 

    % physical parameters:
    light_speed = 3*10^8; % speed of light
    % total_beam_length = 36.2814; % total length (42m?) of beamline (from Alex's result above) in meters

    % determine the distance along the fiber of the loss
    beam_loss_dist_fiber = light_speed/(1+refr_idx) * loss_idx_up * 10 ^-9 ; % calculation of beam loss position 

    
end