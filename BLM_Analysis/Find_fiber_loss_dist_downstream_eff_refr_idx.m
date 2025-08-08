
function [beam_loss_dist_fiber] = Find_fiber_loss_dist_downstream_eff_refr_idx(loss_idx_down)
    % This function finds the beam loss position (in meters) from
    % the start of the beamline, using the downstream time index only (there
    % will of course be a constant offset). It uses the non linear effective refractive index (hence solves a polynomial for the downstream distance)

    % loss_idx_down: time index of beam loss using Find_rise_time_idx
    % on the downstream (averaged) signal 

    % physical parameters:
    light_speed = 3*10^8; % speed of light
    % total_beam_length = 36.2814; % total length (42m?) of beamline (from Alex's result above) in meters

    poly_coeffs = [-1.22850073e-09  5.05237755e-07 -9.22909293e-05  1.46923503e+00];
    syms f(x)
    f(x) = (x - (poly_coeffs(1) * x^4 + poly_coeffs(2) * x^3 + poly_coeffs(3) * x^2 + poly_coeffs(4) * x)) - (light_speed * loss_idx_down * 1e-9);
    solutions = vpasolve(f);
    beam_loss_dist_fiber = double(solutions(1));
    
end