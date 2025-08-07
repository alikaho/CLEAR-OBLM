
% Script analyses the BLM signals from all screens.
% Plots the reconstructed positions, and pulls the relationship between the
% reconstructed positions (ALONG THE FIBER) and the actual BTV screen
% positions (ALONG THE BEAM). These would be expected to give a 1-to-1
% gradient given the fiber is parallel, 

close all
date = num2str(27072025);
refr_idx = 1.465; % silicon refractive index minimum (for maximum wavelength). Should be somewhere in between 1.45 and 1.485. Monty uses 1.465
addpath '/nfs/cs-ccr-nfsop/nfs6/vol29/Linux/data/clear/MatLab/Operation/BLM_GUI_2/BLM_GUI_APP'

% copy_data_over("BTV screen data/27072025_BTV_screen_lookup.txt");
[up_data, down_data, smooth_up_data, smooth_down_data, screens] = get_data(date);
[rise_indices_up, rise_indices_down] = Find_rise_indices(up_data, down_data);

% cut down to the usable screens
screens_less_cell = {screens{1:3}, screens{6:9}};
screens_less = transpose(str2double(string(screens_less_cell)));
screen_distances = [1.8095, 7.07, 20.5964, 24.2259, 25.9344, 29.7544, 32.0174];
errors_on_distances = [0.001, 0.3, 0.001, 0.001, 0.001, 0.4, 0.001, 0.001, 0.001];
up_data_less = up_data([1:3, 6:9], :);
down_data_less = down_data([1:3, 6:9], :);

rise_indices_up_less = rise_indices_up([1:3, 6:9]);
rise_indices_down_less = rise_indices_down([1:3, 6:9]);

% Plot_signals(up_data_less, down_data_less, screens_less, rise_indices_up_less, rise_indices_down_less, date);
[gradient_comb, offset_comb] = Plot_reconstructed_positions_combined_readout(rise_indices_up_less, rise_indices_down_less, screens_less, screen_distances, date, refr_idx);


[gradient_comb_eff, offset_comb_eff] = Plot_reconstructed_positions_combined_readout_eff_refr_idx(rise_indices_up_less, rise_indices_down_less, screens_less, screen_distances, date);
% [gradient_up, offset_up] = Plot_reconstructed_positions_upstream_eff_refr_idx(rise_indices_up_less, screens_less, screen_distances, date);
[gradient_down, offset_down] = Plot_reconstructed_positions_downstream_eff_refr_idx(rise_indices_down_less, screens_less, screen_distances, date);




function [up_data, down_data, smooth_up_data, smooth_down_data, screens] = get_data(date)
    % Gets the upstream and downstream, raw and smoothed data the txt
    % files. nb that the smoothed data was the same as the raw data for
    % these screen measurements (to increase speed of GUI)
    
    % Extracting up, down and smoothed data
    screens = {'215', '235', '390', '390_OTR', '390_CHROMOX', '545', '620', '730', '810', '910', 'natural_losses', 'pre_conical_scatterer', 'BHB400', 'BHB400_420'};
    all_data = zeros(length(screens), 4000);

    for i = 1:length(screens)
        % all_data is up_data, down_data, smooth_up_data, smooth_data_down in a
        % length(screens)x4000 array 
        all_data(i, :) = table2array(readtable("BTV screen data/BLM_GUI_data_" + date + "_BTV_" + screens{i} + ".txt"));
        
    end

    up_data = all_data(:, 1:1000);
    down_data = all_data(:, 1001:2000);
    smooth_up_data = all_data(:, 2001:3000);
    smooth_down_data = all_data(:, 3001:4000);

end



function [rise_indices_up, rise_indices_down] = Find_rise_indices(up_data, down_data)
    
    number_screens = size(up_data, 1);
    rise_indices_up = zeros(1, number_screens);
    rise_indices_down = zeros(1, number_screens);

    for i = 1:number_screens
        rise_indices_up(i) = Find_rise_time_CFD(up_data(i,:));
        rise_indices_down(i) = Find_rise_time_CFD(down_data(i,:));
        
    end

end



function [gradient, offset] = Plot_reconstructed_positions_combined_readout(rise_indices_up_less, rise_indices_down_less, screens, screen_distances, date, refr_idx)

    reconstructed_positions = Find_fiber_loss_dist_combined_readout(refr_idx, rise_indices_up_less, rise_indices_down_less);
    f_comb = figure(2);
    f_comb.Position = [1800 500 800 800];
    hold on

    % fit with straight line
    fit = polyfit(screen_distances, reconstructed_positions, 1);
    gradient = fit(1);
    offset = fit(2);

    plot(screen_distances, reconstructed_positions - offset, '.', 'MarkerSize', 20)
    title("Reconstructed positions using combined readout method")
    subtitle("Using fixed refractive index n = 1.465")
    xlabel("BTV screen distances (m)")
    ylabel("Reconstructed screen positions (m)")
    text(screen_distances, reconstructed_positions - offset, sprintfc('  %d', screens))


    % plot straight line
    screen_distances_plot = [screen_distances(1),screen_distances(end)];
    expected_screen_distances =  gradient * screen_distances_plot;

    plot(screen_distances_plot, expected_screen_distances, 'LineWidth', 2)
    text(screen_distances_plot(1) + 15, expected_screen_distances(1) + 10, [' Fit: y = ' num2str(gradient) 'x + ' num2str(offset)])

    distances_rms = gradient * screen_distances + offset;
    rms = rmse(distances_rms, reconstructed_positions); % find root mean squared error between the predicted rise indices and the observed rise indices
    text(screen_distances_plot(1) + 15, expected_screen_distances(1) + 8, ['RMS value = ' num2str(rms)])

    exportgraphics(f_comb, ['BTV screen data/BLM_', date, '_BTV_Screens_Reconstructed_Distance_CFD_Combined.png'])

end

% just plot the upstream time delay against the known distances
% then see for a time delay given by the second peak where this would be
% situated along the beamline. Does this then match the intensities of the
% beam loss seen at screens nearest to this point??? Why is beam loss
% secondary peak so low for 545? 


function [gradient, offset] = Plot_reconstructed_positions_upstream_eff_refr_idx(rise_indices_up_less, screens, screen_distances, date)

    reconstructed_positions = Find_fiber_loss_dist_upstream_eff_refr_idx(rise_indices_up_less);

    f_up = figure(3);
    f_up.Position = [1800 500 800 800];
    hold on

    % fit with straight line
    fit = polyfit(screen_distances, reconstructed_positions, 1);
    gradient = fit(1);
    offset = fit(2);

    plot(screen_distances, reconstructed_positions - offset, '.', 'MarkerSize', 20)
    title("Reconstructed positions using upstream signal only")
    subtitle("Constant Fraction Discriminator (CFD) method")
    xlabel("BTV screen distances (m)")
    ylabel("Reconstructed positions (m)")
    text(screen_distances, reconstructed_positions - offset, sprintfc('  %d', screens))
    hold on


    % plot straight line
    screen_distances_plot = [screen_distances(1),screen_distances(end)];
    expected_time_delays =  gradient * screen_distances_plot;
    
    plot(screen_distances_plot, expected_time_delays, 'LineWidth', 2)
    text(screen_distances_plot(1) + 15, expected_time_delays(1) + 10, [' Fit: y = ' num2str(gradient) 'x + ' num2str(offset)])

    distances_rms = gradient * screen_distances + offset;
    rms = rmse(distances_rms, reconstructed_positions); % find root mean squared error between the predicted rise indices and the observed rise indices
    text(screen_distances_plot(1) + 15, expected_time_delays(1) + 8, ['RMS value = ' num2str(rms)])

    exportgraphics(f_up, ['BTV screen data/BLM_', date, '_BTV_Screens_Reconstructed_Distance_CFD_Upstream_Eff_Refr_Idx.png'])


end


function [gradient, offset] = Plot_reconstructed_positions_downstream_eff_refr_idx(rise_indices_down_less, screens, screen_distances, date)

    reconstructed_positions = Find_fiber_loss_dist_downstream_eff_refr_idx(rise_indices_down_less);

    f_down = figure(4);
    f_down.Position = [1800 500 800 800];
    hold on

    % fit with straight line
    fit = polyfit(screen_distances, reconstructed_positions, 1);
    gradient = fit(1); 
    offset = fit(2);

    plot(screen_distances, reconstructed_positions - offset, '.', 'MarkerSize', 20)
    title("Reconstructed positions using downstream signal only")
    subtitle("Using effective refractive index (dependent on fiber distance)")
    xlabel("BTV screen distances (m)")
    ylabel("Reconstructed position (m)")
    text(screen_distances, reconstructed_positions - offset, sprintfc('  %d', screens))
    hold on


    % plot straight line
    screen_distances_plot = [screen_distances(1),screen_distances(end)];
    expected_time_delays =  gradient * screen_distances_plot;
    
    plot(screen_distances_plot, expected_time_delays, 'LineWidth', 2)
    text(screen_distances_plot(1) + 15, expected_time_delays(1) + 10, [' Fit: y = ' num2str(gradient) 'x + ' num2str(offset)])

    distances_rms = gradient * screen_distances + offset;
    rms = rmse(distances_rms, reconstructed_positions); % find root mean squared error between the predicted rise indices and the observed rise indices
    text(screen_distances_plot(1) + 15, expected_time_delays(1)+ 8, ['RMS value = ' num2str(rms)])

    exportgraphics(f_down, ['BTV screen data/BLM_', date, '_BTV_Screens_Reconstructed_Distance_CFD_Downstream_Eff_Refr_Idx.png'])

end





function [gradient, offset] = Plot_reconstructed_positions_combined_readout_eff_refr_idx(rise_indices_up_less, rise_indices_down_less, screens, screen_distances, date)


    reconstructed_positions = zeros(1, length(screens));
    for i = 1:length(screens)
        reconstructed_positions(i) = Find_fiber_loss_dist_combined_readout_eff_refr_idx(rise_indices_up_less(i), rise_indices_down_less(i)) ; 
    end

    f_comb_refr = figure(5);
    f_comb_refr.Position = [1800 500 800 800];
    hold on

    % fit with straight line
    fit = polyfit(screen_distances, reconstructed_positions, 1);
    gradient = fit(1);
    offset = fit(2);

    plot(screen_distances, reconstructed_positions - offset, '.', 'MarkerSize', 20)
    title("Reconstructed positions using combined readout method")
    subtitle("Using effective refractive index (dependent on fiber distance)")
    xlabel("BTV screen distances (m)")
    ylabel("Reconstructed screen positions (m)")
    text(screen_distances, reconstructed_positions - offset, sprintfc('  %d', screens))
    hold on


    % plot straight line
    screen_distances_plot = [screen_distances(1),screen_distances(end)];
    expected_screen_distances =  gradient * screen_distances_plot;

    plot(screen_distances_plot, expected_screen_distances, 'LineWidth', 2)
    text(screen_distances_plot(1) + 15, expected_screen_distances(1) + 10, [' Fit: y = ' num2str(gradient) 'x + ' num2str(offset)])

    distances_rms = gradient * screen_distances + offset;
    rms = rmse(distances_rms, reconstructed_positions); % find root mean squared error between the predicted rise indices and the observed rise indices
    text(screen_distances_plot(1) + 15, expected_screen_distances(1) + 8, ['RMS value = ' num2str(rms)])

    exportgraphics(f_comb_refr, ['BTV screen data/BLM_', date, '_BTV_Screens_Reconstructed_Distance_CFD_Combined_Eff_Refr_Idx.png'])

end
