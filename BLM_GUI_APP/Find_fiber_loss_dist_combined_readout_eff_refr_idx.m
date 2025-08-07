
function [beam_loss_dist_fiber] = Find_fiber_loss_dist_combined_readout_eff_refr_idx(loss_idx_up, loss_idx_down)
    % This function finds the beam loss position (in meters) from
    % the start of the beamline, using the time difference between
    % the time index of the upstream beam loss and the time index
    % of the downstream beam loss. It takes into account the non-linearity
    % of the effective refractive index that depends on the distance
    % travelled in the fiber (due to attenuation wavelength dependence)

    % loss_idx_up: time index of beam loss using Find_rise_time_idx
    % on the upstream (averaged) signal 
    % loss_idx_down: time index of beam loss using Find_rise_time_idx
    % on the downstream (averaged) signal 
    % physical parameters:
    light_speed = 3*10^8; % speed of light

    % find the time difference between the upstream and downstream
    % rise times
    time_diff = loss_idx_up - loss_idx_down;

    % the equation below relates the effective refractive index in silica
    % to the distance that the cherenkov photons have travelled.
    % Calculations that led to this equation are in:
    % Refractive_index_attenuation_wavelength_dependence.ipynb
    % Solve the polynomial equation for the beam_loss_distance_fiber


    poly_coeffs = [-1.22850073e-09  5.05237755e-07 -9.22909293e-05  1.46923503e+00];
    syms f(x)
%     poly_coeffs = [ 2.98264887*1e-14 -1.65165421*1e-11  3.74831999*1e-09 -4.52359258*1e-07 3.16734911*1e-05 -1.33581054*1e-03  1.49445199];
%     f(x) = poly_coeffs(1) * x^7 + poly_coeffs(2) * x^6 + poly_coeffs(3) * x^5 + poly_coeffs(4) * x^4 + poly_coeffs(5) * x^3 + poly_coeffs(6) * x^2 + poly_coeffs(7) * x - ((light_speed * time_diff * 1e-9) /2 ); 
    f(x) = poly_coeffs(1) * x^4 + poly_coeffs(2) * x^3 + poly_coeffs(3) * x^2 + poly_coeffs(4) * x - ((light_speed * time_diff * 1e-9) /2 );
    solutions = vpasolve(f);
    beam_loss_dist_fiber = double(solutions(1));
    
end