
dist_pixels = Distance_to_pixels(18.74)
function dist_pixels = Distance_to_pixels(dist_meters)
    % Function converts from position in meters to pixels on the
    % CLIC map, by using linear interpolation between known
    % reference points (stored in
    % CLEAR_MAPS_PIXEL_MEASUREMENTS.csv)
    % Inputs:
        % dist_meters: distance along beamline in meters
    % Output:
        % dist_pixels: distance along beamline in pixels
    CLEARBeamlineAxesHorizontalPixels = 556;
    persistent ref_dist_part1 ref_pix_part1 ref_dist_part2 ref_pix_part2 % load reference data once and persist it
    
    if isempty(ref_dist_part1)
        ref_dist_part1 = csvread('CLEAR_MAPS_PIXEL_MEASUREMENTS.csv',4,1,[4,1,12,1]);
        ref_frac_pix_part1 = csvread('CLEAR_MAPS_PIXEL_MEASUREMENTS.csv',4,3,[4,3,12,3]);
        ref_pix_part1 = ref_frac_pix_part1 * CLEARBeamlineAxesHorizontalPixels;

        ref_dist_part2 = csvread('CLEAR_MAPS_PIXEL_MEASUREMENTS.csv',19,1,[19,1,32,1]);
        ref_frac_pix_part2 = csvread('CLEAR_MAPS_PIXEL_MEASUREMENTS.csv',19,3,[19,3,32,3]);
        ref_pix_part2 = ref_frac_pix_part2 * CLEARBeamlineAxesHorizontalPixels;
        plot(ref_dist_part1, ref_pix_part1)
        hold on
        plot(ref_dist_part2, ref_pix_part2)
    end

    if dist_meters <= 20.05 % signal loss lies on CLEAR beamline part 1
        % vectorised interpolation between reference points to find
        % beamloss signal in pixels. "extrapolation" in case out of
        % beamline.
        dist_pixels = interp1(ref_dist_part1, ref_pix_part1, dist_meters, "linear", "extrap");
    else % signal loss lies on CLEAR beamline part 2
        dist_pixels = interp1(ref_dist_part2, ref_pix_part2, dist_meters, "linear", "extrap");
    end


end
