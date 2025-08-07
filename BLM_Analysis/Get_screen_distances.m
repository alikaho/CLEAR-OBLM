function screen_distances = Get_screen_distances(screen_names)
    % uses the lookup table 'Distance_pixel_lookup_new_distances.txt' to
    % return the real distance of a given screen or magnet name. Screen or
    % magnet name must be given as a character not a string. 

    lookup_table = readtable('Distance_pixel_lookup_new_distances.txt');
    screen_distances = zeros(length(screen_names));
    % return the row in the table which has Name of Beamline Feature ending
    % in the magnet name number
    for i = 1:length(screen_names)
        row = lookup_table(endsWith(lookup_table.CLEARMAP1, num2str(screen_names(i))),:);
        screen_distances(i) = row.Var2;
    end
    screen_distances = screen_distances(:, 1);
    
end
