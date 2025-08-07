function dist_pixels = Distance_to_pixels(dist_meters)
    % Function converts from position in meters to pixels on the
    % CLIC map, by using linear interpolation between known
    % reference points (stored in
    % CLEAR_MAPS_PIXEL_MEASUREMENTS.csv)
    % Inputs:
        % dist_meters: distance along beamline in meters
    % Output:
        % dist_pixels: distance along beamline in pixels
    
    persistent ref_dist_part1 ref_pix_part1 ref_dist_part2 ref_pix_part2 % load reference data once and persist it
    % App component dimensions
    Axes1_horizontal_length = 553;
    Axes2_horizontal_length = 554;


    if isempty(ref_dist_part1)
        ref_dist_part1 = csvread('CLEAR_MAPS_PIXEL_MEASUREMENTS.csv',4,1,[4,1,13,1]);
        ref_frac_pix_part1 = csvread('CLEAR_MAPS_PIXEL_MEASUREMENTS.csv',4,3,[4,3,13,3]);
        ref_pix_part1 = ref_frac_pix_part1 * Axes1_horizontal_length;

        % 3 offset is to match the calibration data (UIAxes is
        % slightly offset from the image!)

        ref_dist_part2 = csvread('CLEAR_MAPS_PIXEL_MEASUREMENTS.csv',19,1,[19,1,32,1]);
        ref_frac_pix_part2 = csvread('CLEAR_MAPS_PIXEL_MEASUREMENTS.csv',19,3,[19,3,32,3]);
        ref_pix_part2 = ref_frac_pix_part2 * Axes2_horizontal_length;

    end

    if dist_meters <= 22 % signal loss lies on CLEAR beamline part 1
        % vectorised interpolation between reference points to find
        % beamloss signal in pixels. "extrapolation" in case out of
        % beamline.
        dist_pixels = interp1(ref_dist_part1, ref_pix_part1, dist_meters, "linear", "extrap");
    else % signal loss lies on CLEAR beamline part 2
        dist_pixels = interp1(ref_dist_part2, ref_pix_part2, dist_meters, "linear", "extrap");
    end


end