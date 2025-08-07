
function [beam_loss_dist_fiber] = Find_fiber_loss_dist_downstream(refr_idx, loss_idx_down)
    % This function finds the beam loss position (in meters) from
    % the start of the beamline, using the downstream time index only (there
    % will of course be a constant offset)

    % loss_idx_down: time index of beam loss using Find_rise_time_idx
    % on the downstream (averaged) signal 

    % physical parameters:
    light_speed = 3*10^8; % speed of light
    % total_beam_length = 36.2814; % total length (42m?) of beamline (from Alex's result above) in meters

    % determine the distance along the fiber of the loss
    beam_loss_dist_fiber = light_speed/(1 - refr_idx) * loss_idx_down * 10 ^-9 ; % calculation of beam loss position 
    % nb that the beam loss position will be calculated as a negative
    % distance (negative from the end of the beamline). This is converted
    % to positive here so that plot can be compared with the upstream and
    % combined readout methods (it should have an offset related to the
    % length of the fiber).

    
end