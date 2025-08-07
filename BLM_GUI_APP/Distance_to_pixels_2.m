function dist_pixels = Distance_to_pixels_2(dist_meters)
    % Function converts from position in meters to pixels on the
    % CLIC map, by using linear interpolation between known
    % reference points (stored in
    % Distance_pixel_lookup.txt)
    % Inputs:
        % dist_meters: distance along beamline in meters
    % Output:
        % dist_pixels: distance along beamline in pixels

    Axes1_horizontal_length = 9925; % length of the plotting axes for beamline part 1
    Axes2_horizontal_length = 10010; % length of the plotting axes for beamline part 2

    persistent ref_dist_part1 ref_pix_part1 ref_dist_part2 ref_pix_part2 % load reference data once and persist it

    if isempty(ref_dist_part1)
        distance_pixel_lookup = readtable("Distance_pixel_lookup_new_distances.txt");        
        ref_dist_part1 = table2array(distance_pixel_lookup(3:30, 2));
        ref_frac_pix_part1 = table2array(distance_pixel_lookup(3:30, 4));
        ref_pix_part1 = ref_frac_pix_part1 * Axes1_horizontal_length;
    
        ref_dist_part2 = table2array(distance_pixel_lookup(34:58, 2));
        ref_frac_pix_part2 = table2array(distance_pixel_lookup(34:58, 4));
        ref_pix_part2 = ref_frac_pix_part2 * Axes2_horizontal_length; 

    end

    if dist_meters < 21.48 % signal loss lies on CLEAR beamline part 1
        % vectorised interpolation between reference points to find
        % beamloss signal in pixels. "extrapolation" in case out of
        % beamline.
        dist_pixels = interp1(ref_dist_part1, ref_pix_part1, dist_meters, "linear", "extrap");
    elseif dist_meters >= 21.48 && dist_meters <= 22.5 
        % signal loss lies in VESPER area (which overlaps with part of
        % beamline part 2)
        dist_pixels1 = interp1(ref_dist_part1, ref_pix_part1, dist_meters, "linear", "extrap");
        dist_pixels2 = interp1(ref_dist_part2, ref_pix_part2, dist_meters, "linear", "extrap");
        dist_pixels = [dist_pixels1, dist_pixels2];
    else
        % signal loss lies on CLEAR beamline part 2
        dist_pixels = interp1(ref_dist_part2, ref_pix_part2, dist_meters, "linear", "extrap");
    end


end