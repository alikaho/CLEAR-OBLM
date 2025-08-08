
% Script analyses the BLM signals from all screens.
% Plots the reconstructed positions, and pulls the relationship between the
% reconstructed positions (ALONG THE FIBER) and the actual BTV screen
% positions (ALONG THE BEAM). These would be expected to give a 1-to-1
% gradient given the fiber is parallel, 
close all
date = num2str(27072025);

parent_folder = fileparts(cd); % get the parent folder of this script
addpath(fullfile(parent_folder, 'BLM_GUI_APP')); % add path with GUI app

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


% Plot for a range of refractive indices
refr_indices = linspace(1.45, 1.55, 5);
Plot_diff_refr_combined_readout(refr_indices, rise_indices_up_less, rise_indices_down_less, screens_less, screen_distances, date)
Plot_diff_refr_upstream(refr_indices, rise_indices_up_less, screens_less, screen_distances, date)
Plot_diff_refr_downstream(refr_indices, rise_indices_down_less, screens_less, screen_distances, date)


function Plot_diff_refr_combined_readout(refr_indices, rise_indices_up_less, rise_indices_down_less, screens_less, screen_distances, date)
    
    % Combined readout method
    f_comb = figure(2);
    f_comb.Position = [1800 500 800 800];
    hold on
    
    title("Reconstructed positions using combined readout method")
    subtitle("Constant Fraction Discriminator (CFD) method")
    xlabel("BTV screen distances (m)")
    ylabel("Reconstructed screen positions (m)")
    
    C = {'blue', 'red', 'green', 'cyan', 'magenta'};
    
    for i = 1:length(refr_indices)
        reconstructed_positions = Find_fiber_loss_dist_combined_readout(refr_indices(i), rise_indices_up_less, rise_indices_down_less);
    
        % fit with straight line
        fit = polyfit(screen_distances, reconstructed_positions, 1);
        gradient = fit(1);
        offset = fit(2);
    
        plot(screen_distances, reconstructed_positions - offset, '.', 'MarkerSize', 20, 'Color', C{i}, 'HandleVisibility','off')
    
    
        % plot straight line
        screen_distances_plot = [screen_distances(1),screen_distances(end)];
        expected_screen_distances =  gradient * screen_distances_plot;
    
        plot(screen_distances_plot, expected_screen_distances, 'LineWidth', 2, 'Color',C{i},'DisplayName', ['n = ', num2str(refr_indices(i))])
        text(screen_distances_plot(1) + 12, expected_screen_distances(1) + 8 + i, [' Fit: y = ' num2str(gradient) 'x + ' num2str(offset)], 'Color', C{i})
        legend('Location', 'best')
    
    
        distances_rms = gradient * screen_distances + offset;
        rms = rmse(distances_rms, reconstructed_positions); % find root mean squared error between the predicted rise indices and the observed rise indices
        text(screen_distances_plot(1) + 25, expected_screen_distances(1) + 8 + i, ['RMS = ' num2str(rms)], 'Color', C{i})
        

        
    end
    
    text(screen_distances, reconstructed_positions - offset, sprintfc('  %d', screens_less))
    exportgraphics(f_comb, ['BTV screen data/BLM_', date, '_BTV_Screens_Reconstructed_Distance_CFD_Combined_Refr_Idx.png'])
end





function Plot_diff_refr_upstream(refr_indices, rise_indices_up_less, screens_less, screen_distances, date)
    
    % Combined readout method
    f_up = figure(3);
    f_up.Position = [1800 500 800 800];
    hold on
    
    title("Reconstructed positions using upstream signal only")
    subtitle("Constant Fraction Discriminator (CFD) method")
    xlabel("BTV screen distances (m)")
    ylabel("Reconstructed screen positions (m)")
    
    C = {'blue', 'red', 'green', 'cyan', 'magenta'};
    
    for i = 1:length(refr_indices)
        reconstructed_positions = Find_fiber_loss_dist_upstream(refr_indices(i), rise_indices_up_less);
    
        % fit with straight line
        fit = polyfit(screen_distances, reconstructed_positions, 1);
        gradient = fit(1);
        offset = fit(2);
    
        plot(screen_distances, reconstructed_positions - offset, '.', 'MarkerSize', 20, 'Color', C{i}, 'HandleVisibility','off')
    
    
        % plot straight line
        screen_distances_plot = [screen_distances(1),screen_distances(end)];
        expected_screen_distances =  gradient * screen_distances_plot;
    
        plot(screen_distances_plot, expected_screen_distances, 'LineWidth', 2, 'Color',C{i},'DisplayName', ['n = ', num2str(refr_indices(i))])
        text(screen_distances_plot(1) + 12, expected_screen_distances(1) + 8 + i, [' Fit: y = ' num2str(gradient) 'x + ' num2str(offset)], 'Color', C{i})
        legend('Location', 'best')
    
    
        distances_rms = gradient * screen_distances + offset;
        rms = rmse(distances_rms, reconstructed_positions); % find root mean squared error between the predicted rise indices and the observed rise indices
        text(screen_distances_plot(1) + 25, expected_screen_distances(1) + 8 + i, ['RMS = ' num2str(rms)], 'Color', C{i})
               
        
    end
    
    text(screen_distances, reconstructed_positions - offset, sprintfc('  %d', screens_less))
    exportgraphics(f_up, ['BTV screen data/BLM_', date, '_BTV_Screens_Reconstructed_Distance_CFD_Upstream_Refr_Idx.png'])

end



function Plot_diff_refr_downstream(refr_indices, rise_indices_down_less, screens_less, screen_distances, date)
    
    % Combined readout method
    f_down = figure(4);
    f_down.Position = [1800 500 800 800];
    hold on
    
    title("Reconstructed positions using downstream signal only")
    subtitle("Constant Fraction Discriminator (CFD) method")
    xlabel("BTV screen distances (m)")
    ylabel("Reconstructed screen positions (m)")
    
    C = {'blue', 'red', 'green', 'cyan', 'magenta'};
    
    for i = 1:length(refr_indices)
        reconstructed_positions = Find_fiber_loss_dist_downstream(refr_indices(i), rise_indices_down_less);
    
        % fit with straight line
        fit = polyfit(screen_distances, reconstructed_positions, 1);
        gradient = fit(1);
        offset = fit(2);
    
        plot(screen_distances, reconstructed_positions - offset, '.', 'MarkerSize', 20, 'Color', C{i}, 'HandleVisibility','off')
    
    
        % plot straight line
        screen_distances_plot = [screen_distances(1),screen_distances(end)];
        expected_screen_distances =  gradient * screen_distances_plot;
    
        plot(screen_distances_plot, expected_screen_distances, 'LineWidth', 2, 'Color',C{i},'DisplayName', ['n = ', num2str(refr_indices(i))])
        text(screen_distances_plot(1) + 12, expected_screen_distances(1) + 8 + i, [' Fit: y = ' num2str(gradient) 'x + ' num2str(offset)], 'Color', C{i})
        legend('Location', 'best')
    
    
        distances_rms = gradient * screen_distances + offset;
        rms = rmse(distances_rms, reconstructed_positions); % find root mean squared error between the predicted rise indices and the observed rise indices
        text(screen_distances_plot(1) + 25, expected_screen_distances(1) + 8 + i, ['RMS = ' num2str(rms)], 'Color', C{i})
                
        
    end
    
    text(screen_distances, reconstructed_positions - offset, sprintfc('  %d', screens_less))
    exportgraphics(f_down, ['BTV screen data/BLM_', date, '_BTV_Screens_Reconstructed_Distance_CFD_Downstream_Refr_Idx.png'])

end






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

