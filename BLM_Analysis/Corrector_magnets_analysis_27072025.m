
close all
refr_idx = 1.25;

parent_folder = fileparts(cd); % get the parent folder of this script
addpath(fullfile(parent_folder, 'BLM_GUI_APP')); % add path with GUI app

[up_data, down_data, smooth_up_data, smooth_down_data, magnets] = get_data('Corrector magnet data/27072025_corrector_magnet_lookup.txt');
[rise_indices_up, rise_indices_down] = Find_rise_indices(up_data, down_data);

magnet_distances = transpose(Get_magnet_distances(magnets));

plot_signals(up_data, down_data, magnets, rise_indices_up, rise_indices_down)
[gradient, offset] = Plot_reconstructed_positions(magnets, magnet_distances, rise_indices_up, rise_indices_down, refr_idx);
[gradient, offset] = Plot_reconstructed_positions_upstream(rise_indices_up, magnets, magnet_distances, date, refr_idx);
[gradient, offset] = Plot_reconstructed_positions_downstream(rise_indices_down, magnets, magnet_distances, date, refr_idx);

% plot_signal_differing_current(up_data, down_data, smooth_up_data, smooth_down_data, magnets, vert);
% plot_rise_times_differing_current(smooth_up_data, magnets)

% plot_signal_differing_magnets(up_data, down_data, smooth_up_data, smooth_down_data, magnets);
% plot_rise_time_differing_magnets(smooth_up_data)



function [up_data, down_data, smooth_up_data, smooth_down_data, magnets] = get_data(table)

    % Call the lookup table between timestamps and magnet names
    unsorted_lookup = readtable(table);
    lookup = sortrows(unsorted_lookup, 2); % sorts by magnet values
    timestamps = lookup{:, 1};
    magnets = lookup{:, 2};
    
    % % Copy files from the raw data folder to this folder and rename with the
    % % magnet name (will need to change date of the recorded data)

    % copy txt files
    for i = 1:length(timestamps)
        copyfile("Raw BLM data/BLM_GUI_data_27072025-" + char(timestamps(i)) + ".txt", "Corrector magnet data/BLM_GUI_data_27072025_magnet_" + magnets(i) + ".txt")
    end
    
    % copy jpg files
    for i = 1:length(timestamps)
        copyfile("Raw BLM data/BLM_GUI_data_27072025-" + char(timestamps(i)) + ".jpg", "Corrector magnet data/BLM_GUI_data_27072025_magnet_" + magnets(i) + ".jpg")
    end
    

    % Extracting up, down and smoothed data
    all_data = zeros(length(magnets), 4000);
    
    for i = 1:length(magnets)
        % all_data is up_data, down_data, smooth_up_data, smooth_data_down in a
        % length(magnets)x4000 array 
        all_data(i, :) = table2array(readtable("Corrector magnet data/BLM_GUI_data_27072025_magnet_" + magnets(i) + ".txt"));
    
    end
    
    up_data = all_data(:, 1:1000);
    down_data = all_data(:, 1001:2000);
    smooth_up_data = all_data(:, 2001:3000);
    smooth_down_data = all_data(:, 3001:4000);


end



function [rise_indices_up, rise_indices_down] = Find_rise_indices(up_data, down_data)
    
    number_magnets = size(up_data, 1);
    rise_indices_up = zeros(1, number_magnets);
    rise_indices_down = zeros(1, number_magnets);

    for i = 1:number_magnets
        rise_indices_up(i) = Find_rise_time_CFD(up_data(i,:));
        rise_indices_down(i) = Find_rise_time_CFD(down_data(i,:));
        
    end


end


function magnet_distances = Get_magnet_distances(magnets)
    lookup_table = readtable('Distance_pixel_lookup_new_distances.txt');
    magnet_distances = zeros(length(magnets));
    % return the row in the table which has Name of Beamline Feature ending
    % in the magnet name number
    for i = 1:length(magnets)
        row = lookup_table(endsWith(lookup_table.CLEARMAP1, num2str(magnets(i))),:);
        magnet_distances(i) = row.Var2;
    end
    magnet_distances = magnet_distances(:, 1);
    
end



function plot_signals(up_data, down_data, magnets, rise_indices_up, rise_indices_down)
    % Plot the data

    f = figure(1);
    f.Position = [900 500 1400 800];
    t = tiledlayout(1,2, 'TileSpacing','Compact');

    title(t, 'Beam Loss For Corrector Magnets Along CLEAR Beamline', fontsize = 18)
    subtitle(t, 'Rise time found using Constant Fraction Discriminator (CFD)')
    C = {'red', 'green', 'blue', 'cyan','black', 'magenta', [1 0.647 0], [128 0 128]/255 }; % cell array of colours
    
    
    % up data
    ax1 = nexttile;
    hold on
    for i = 1:length(magnets)
        plot(up_data(i, :), 'Color', C{i}, 'DisplayName', ['Magnet ', num2str(magnets(i))], 'LineWidth', 2)
        scatter(rise_indices_up(i), up_data(i, rise_indices_up(i)),100, C{i},'filled', 'HandleVisibility', 'off')
    end
    title("Upstream")
    xlabel("Time points (ns)")
    ylabel("Photomultiplier signal (V)")
    legend('FontSize', 14)
    
    % down data
    ax2 = nexttile;
    hold on
    for i = 1:length(magnets)
        plot(down_data(i, :), 'color', C{i}, 'DisplayName', ['Magnet ', num2str(magnets(i))], 'LineWidth', 2)
        scatter(rise_indices_down(i), down_data(i, rise_indices_down(i)),100, C{i},'filled', 'HandleVisibility', 'off')
    end
    title("Downstream")
    xlabel("Time (ns)")
    ylabel("Photomultiplier signal (V)")
    legend('FontSize', 14)

    axis(ax1, [200 1000 -0.05 0.3])
    axis(ax2, [200 600 0 0.8])    

    exportgraphics(f, 'Corrector magnet data/BLM_27072025_Corrector_Magnets_Waveforms_CFD.png')
end





function [gradient, offset] = Plot_reconstructed_positions(magnets, magnet_distances, rise_indices_up, rise_indices_down, refr_idx)

    reconstructed_positions = Find_fiber_loss_dist_combined_readout(refr_idx, rise_indices_up, rise_indices_down);

    f_comb = figure(2);
    f_comb.Position = [1800 500 800 800];

    plot(magnet_distances, reconstructed_positions, '.', 'MarkerSize', 20)
    title("Reconstructed positions against known corrector magnet distances")
    subtitle("Constant Fraction Discriminator (CFD) method, all magnets at 10A")
    xlabel("Corrector Magnet Position (m)")
    ylabel("Reconstructed Corrector Magnet Position (m)")
    text(magnet_distances, reconstructed_positions, sprintfc('  %d', magnets))
    hold on

    % fit with straight line
    fit = polyfit(magnet_distances, reconstructed_positions, 1);
    gradient = fit(1);
    offset = fit(2);
    axis([10 36 0 25])
    % plot straight line
    magnet_distances_plot = [magnet_distances(1),magnet_distances(end)];
    expected_magnet_distances =  gradient * magnet_distances_plot + offset;

    plot(magnet_distances_plot, expected_magnet_distances, 'LineWidth', 2)
    text(magnet_distances(2) + 5, reconstructed_positions(2), [' Fit: y = ' num2str(gradient) 'x + ' num2str(offset)])

    distances_rms = gradient * magnet_distances + offset;    
    rms = rmse(reshape(distances_rms, 1, length(distances_rms)), reconstructed_positions, 'all'); % find root mean squared error between the predicted rise indices and the observed rise indices
    text(magnet_distances(2) + 5, reconstructed_positions(2) - 1, ['RMS value = ' num2str(rms)])

    exportgraphics(f_comb, 'Corrector magnet data/BLM_27072025_Corrector_Magnets_Reconstructed_Distance_CFD_Combined.png')

end




function [gradient, offset] = Plot_reconstructed_positions_upstream(rise_indices_up, magnets, magnet_distances, date, refr_idx)

    reconstructed_positions = Find_fiber_loss_dist_upstream(refr_idx, rise_indices_up);

    f_up = figure(3);
    f_up.Position = [1800 500 800 800];
    hold on

    % fit with straight line
    fit = polyfit(magnet_distances, reconstructed_positions, 1);
    gradient = fit(1);
    offset = fit(2);

    plot(magnet_distances, reconstructed_positions - offset, '.', 'MarkerSize', 20)
    title("Reconstructed positions using upstream signal only")
    subtitle("Constant Fraction Discriminator (CFD) method")
    xlabel("BTV magnet distances (m)")
    ylabel("Reconstructed positions (m)")
    text(magnet_distances, reconstructed_positions - offset, sprintfc('  %d', magnets))
    hold on


    % plot straight line
    magnet_distances_plot = [magnet_distances(1),magnet_distances(end)];
    expected_time_delays =  gradient * magnet_distances_plot;
    
    plot(magnet_distances_plot, expected_time_delays, 'LineWidth', 2)
    text(magnet_distances_plot(1) + 15, expected_time_delays(1) + 10, [' Fit: y = ' num2str(gradient) 'x + ' num2str(offset)])

    distances_rms = gradient * magnet_distances + offset;
    rms = rmse(distances_rms, reconstructed_positions); % find root mean squared error between the predicted rise indices and the observed rise indices
    text(magnet_distances_plot(1) + 15, expected_time_delays(1) + 8, ['RMS value = ' num2str(rms)])

    exportgraphics(f_up, 'Corrector magnet data/BLM_27072025_Corrector_Magnets_Reconstructed_Distance_CFD_Upstream.png')


end


function [gradient, offset] = Plot_reconstructed_positions_downstream(rise_indices_down, magnets, magnet_distances, date, refr_idx)

    reconstructed_positions = Find_fiber_loss_dist_downstream(refr_idx, rise_indices_down);

    f_down = figure(4);
    f_down.Position = [1800 500 800 800];
    hold on

    % fit with straight line
    fit = polyfit(magnet_distances, reconstructed_positions, 1);
    gradient = fit(1); 
    offset = fit(2);

    plot(magnet_distances, reconstructed_positions - offset, '.', 'MarkerSize', 20)
    title("Reconstructed positions using downstream signal only")
    subtitle("Constant Fraction Discriminator (CFD) method")
    xlabel("BTV magnet distances (m)")
    ylabel("Reconstructed position (m)")
    text(magnet_distances, reconstructed_positions - offset, sprintfc('  %d', magnets))
    hold on


    % plot straight line
    magnet_distances_plot = [magnet_distances(1),magnet_distances(end)];
    expected_time_delays =  gradient * magnet_distances_plot;
    
    plot(magnet_distances_plot, expected_time_delays, 'LineWidth', 2)
    text(magnet_distances_plot(1) + 15, expected_time_delays(1) + 10, [' Fit: y = ' num2str(gradient) 'x + ' num2str(offset)])

    distances_rms = gradient * magnet_distances + offset;
    rms = rmse(distances_rms, reconstructed_positions); % find root mean squared error between the predicted rise indices and the observed rise indices
    text(magnet_distances_plot(1) + 15, expected_time_delays(1)+ 8, ['RMS value = ' num2str(rms)])

    exportgraphics(f_down, 'Corrector magnet data/BLM_27072025_Corrector_Magnets_Reconstructed_Distance_CFD_Downstream.png')


end
