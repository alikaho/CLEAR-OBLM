
% Script analyses the BLM signals from all screens.
% Plots the reconstructed positions, and pulls the relationship between the
% reconstructed positions (ALONG THE FIBER) and the actual BTV screen
% positions (ALONG THE BEAM). These would be expected to give a 1-to-1
% gradient given the fiber is parallel, 

close all
date = num2str(27072025);
refr_idx = 1.465; % silicon refractive index for fiber distance of around 60m. See effective refractive index to see full accounting of fiber distance/attenuation/wavelength etc. 

parent_folder = fileparts(cd); % get the parent folder of this script
addpath(fullfile(parent_folder, 'BLM_GUI_APP')); % add path with GUI app


[up_data, down_data, smooth_up_data, smooth_down_data, screens] = get_data(date); % get the data from the txt files in BTV screen data


% cut down to the usable screens
screens_less_cell = {screens{1:3}, screens{6:9}};
screens_less = transpose(str2double(string(screens_less_cell)));
screen_distances = [1.8095, 7.07, 20.5964, 24.2259, 25.9344, 29.7544, 32.0174];
errors_on_distances = [0.001, 0.3, 0.001, 0.001, 0.001, 0.4, 0.001, 0.001, 0.001];
up_data_less = up_data([1:3, 6:9], :);
down_data_less = down_data([1:3, 6:9], :);

[rise_indices_up_less, rise_indices_down_less] = Find_rise_indices(up_data_less, down_data_less);

Plot_signals(up_data_less, down_data_less, screens_less, rise_indices_up_less, rise_indices_down_less, date);

[gradient_comb, offset_comb] = Plot_reconstructed_positions_combined_readout(rise_indices_up_less, rise_indices_down_less, screens_less, screen_distances, date, refr_idx);
[gradient_up, offset_up] = Plot_reconstructed_positions_upstream(rise_indices_up_less, screens_less, screen_distances, date, refr_idx);
[gradient_down, offset_down] = Plot_reconstructed_positions_downstream(rise_indices_down_less, screens_less, screen_distances, date, refr_idx);


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




function Plot_signals(up_data, down_data, screens, rise_indices_up, rise_indices_down, date)
    % Plot the data
    f_waveforms = figure(1);
    f_waveforms.Position = [900 500 1400 800];
    t = tiledlayout(1,2, 'TileSpacing','Compact');

    title(t, 'Beam Loss For BTV Screens Along CLEAR Beamline', fontsize = 18)
    subtitle(t, 'Rise time found using Constant Fraction Discriminator (CFD)')
    C = {'red', 'green', 'blue', 'cyan','black', 'magenta', [1 0.647 0], [128 0 128]/255 }; % cell array of colours
    
    
    % up data
    ax1 = nexttile;
    hold on
    for i = 1:length(screens)
        plot(up_data(i, :), 'Color', C{i}, 'DisplayName', ['BTV ', num2str(screens(i))], 'LineWidth', 2)
        scatter(rise_indices_up(i), up_data(i, rise_indices_up(i)),100, C{i},'filled', 'HandleVisibility', 'off')
    end
    title("Upstream")
    xlabel("Time points (ns)")
    ylabel("Photomultiplier signal (V)")
    legend('FontSize', 14)
    
    % down data
    ax2 = nexttile;
    hold on
    for i = 1:length(screens)
        plot(down_data(i, :), 'color', C{i}, 'DisplayName', ['BTV ', num2str(screens(i))], 'LineWidth', 2)
        scatter(rise_indices_down(i), down_data(i, rise_indices_down(i)),100, C{i},'filled', 'HandleVisibility', 'off')
    end
    title("Downstream")
    xlabel("Time (ns)")
    ylabel("Photomultiplier signal (V)")
    legend('FontSize', 14)

    axis(ax1, [100 1000 -0.05 0.2])
    axis(ax2, [100 1000 0 0.7])    

%     savefig(f_waveforms, ['Corrector magnet data/BLM_', date, '_Corrector_Magnets_Signal_CFD.fig'])
    exportgraphics(f_waveforms, ['BTV screen data/BLM_', date, '_BTV_Screens_Waveforms_CFD.png'])
end


function [gradient, offset] = Plot_reconstructed_positions_combined_readout(rise_indices_up_less, rise_indices_down_less, screens, screen_distances, date, refr_idx)

    reconstructed_positions = Find_fiber_loss_dist_combined_readout(refr_idx, rise_indices_up_less, rise_indices_down_less);
    f_comb = figure(2);
    f_comb.Position = [1800 500 400 400];
    hold on

    % plot the fitted data and output gradient and offset
    [gradient, offset] = Fit_and_disp_rms_error(screen_distances, reconstructed_positions);

    % plot the experimental data (requires offset from fitting - hence afterwards)
    plot(screen_distances, reconstructed_positions - offset, '.', 'MarkerSize', 20)
    title("Reconstructed positions using combined readout method")
    subtitle("Constant Fraction Discriminator (CFD) method")
    xlabel("BTV screen distances (m)")
    ylabel("Reconstructed screen positions (m)")
    text(screen_distances, reconstructed_positions - offset, sprintfc('  %d', screens))

    % save the figure as png
    exportgraphics(f_comb, ['BTV screen data/BLM_', date, '_BTV_Screens_Reconstructed_Distance_CFD_Combined.png'])

end



function [gradient, offset] = Plot_reconstructed_positions_upstream(rise_indices_up_less, screens, screen_distances, date, refr_idx)

    reconstructed_positions = Find_fiber_loss_dist_upstream(refr_idx, rise_indices_up_less);

    f_up = figure(3);
    f_up.Position = [1800 500 400 400];
    hold on

    % plot the fitted data and output gradient and offset
    [gradient, offset] = Fit_and_disp_rms_error(screen_distances, reconstructed_positions)

    % plot the experimental data (requires offset from fitting - hence afterwards)
    plot(screen_distances, reconstructed_positions - offset, '.', 'MarkerSize', 20)
    title("Reconstructed positions using upstream signal only")
    subtitle("Constant Fraction Discriminator (CFD) method")
    xlabel("BTV screen distances (m)")
    ylabel("Reconstructed screen positions (m)")
    text(screen_distances, reconstructed_positions - offset, sprintfc('  %d', screens))

    % save the figure as png
    exportgraphics(f_up, ['BTV screen data/BLM_', date, '_BTV_Screens_Reconstructed_Distance_CFD_Upstream.png'])


end


function [gradient, offset] = Plot_reconstructed_positions_downstream(rise_indices_down_less, screens, screen_distances, date, refr_idx)

    reconstructed_positions = Find_fiber_loss_dist_downstream(refr_idx, rise_indices_down_less);

    f_down = figure(4);
    f_down.Position = [1800 500 400 400];
    hold on

    % plot the fitted data and output gradient and offset
    [gradient, offset] = Fit_and_disp_rms_error(screen_distances, reconstructed_positions);
 
    % plot the experimental data (requires offset from fitting - hence afterwards)
    plot(screen_distances, reconstructed_positions - offset, '.', 'MarkerSize', 20)
    title("Reconstructed positions using downstream signal only")
    subtitle("Constant Fraction Discriminator (CFD) method")
    xlabel("BTV screen distances (m)")
    ylabel("Reconstructed screen positions (m)")
    text(screen_distances, reconstructed_positions - offset, sprintfc('  %d', screens))

    % save the figure as png
    exportgraphics(f_down, ['BTV screen data/BLM_', date, '_BTV_Screens_Reconstructed_Distance_CFD_Downstream.png'])

end


