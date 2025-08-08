

[up_data, down_data, smooth_up_data, smooth_down_data, magnets, hor, vert] = get_data('Corrector magnet data/16072025_corrector_magnet_lookup.txt');
[rise_indices_up, rise_indices_down] = Find_rise_indices(up_data, down_data);
[gradient, offset] = Plot_reconstructed_positions(rise_indices_up, rise_indices_down)
plot_signals(up_data, down_data, smooth_up_data, smooth_down_data, magnets, rise_indices_up, rise_indices_down)

% plot_signal_differing_current(up_data, down_data, smooth_up_data, smooth_down_data, magnets, vert);
% plot_rise_times_differing_current(smooth_up_data, magnets)

% plot_signal_differing_magnets(up_data, down_data, smooth_up_data, smooth_down_data, magnets);
% plot_rise_time_differing_magnets(smooth_up_data)


parent_folder = fileparts(cd); % get the parent folder of this script
addpath(fullfile(parent_folder, 'BLM_GUI_APP')); % add path with GUI app



function [up_data, down_data, smooth_up_data, smooth_down_data, magnets, hor, vert] = get_data(table)

    % Call the lookup table between timestamps and screen names
    unsorted_lookup = readtable(table);
    lookup = sortrows(unsorted_lookup, [3 5]); % sorts by magnet values and then by the steering magnet current
    timestamps = lookup{:, 1};
    magnets_all = lookup{:, 3};
    hor = lookup{:, 4};
    vert = lookup{:, 5};
    
    % % Copy files from the raw data folder to this folder and rename with the
    % % screen name (will need to change date of the recorded data)
    % my_dir = pwd; % current directory
    % idx_slash = strfind(my_dir,'/');
    % upper_dir = my_dir(1:idx_slash(end)-1);
    % 
    for i = 1:length(timestamps)
        copyfile("Raw BLM data/BLM_GUI_data_16072025-" + char(timestamps(i)) + ".txt", "Corrector magnet data/BLM_GUI_data_16072025_magnet_" + magnets_all(i) + "_" + hor(i) + "H" + vert(i) + "V.txt")
    end
    
    
    % Extracting up, down and smoothed data
    all_data = zeros(length(magnets_all), 4000);
    
    for i = 1:length(magnets_all)
        % all_data is up_data, down_data, smooth_up_data, smooth_data_down in a
        % length(screens)x4000 array 
        all_data(i, :) = table2array(readtable("Corrector magnet data/BLM_GUI_data_16072025_magnet_" + magnets_all(i) + "_" + hor(i) + "H" + vert(i) + "V.txt"));
    
    end
    
    up_data = all_data([5 10 15 20], 1:1000);
    down_data = all_data([5 10 15 20], 1001:2000);
    smooth_up_data = all_data([5 10 15 20], 2001:3000);
    smooth_down_data = all_data([5 10 15 20], 3001:4000);

    magnets = magnets_all([5 10 15 20]);

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



function [gradient, offset] = Plot_reconstructed_positions(rise_indices_up, rise_indices_down)
    magnet_names = [320 385 590 710]; % not gonna plot all screens
    reconstructed_positions = Find_fiber_loss_dist(rise_indices_up, rise_indices_down);

    magnet_distances = [17.7 20 25.21 29.31];

    f = figure;
    f.Position = [1800 500 800 800];

    plot(magnet_distances, reconstructed_positions, '.', 'MarkerSize', 20)
    title("Reconstructed positions against known corrector magnet distances")
    subtitle("Constant Fraction Discriminator (CFD) method")
    xlabel("Corrector magnet distances (m)")
    ylabel("Reconstructed corrector magnet positions (m)")
    text(magnet_distances, reconstructed_positions, sprintfc('  %d', magnet_names))
    hold on

    % fit with straight line
    fit = polyfit(magnet_distances, reconstructed_positions, 1);
    gradient = fit(1);
    offset = fit(2);
    axis([16 30 21 28])

    % plot straight line
    screen_distances_plot = [magnet_distances(1),magnet_distances(4)];
    expected_screen_distances =  gradient * screen_distances_plot + offset;

    plot(screen_distances_plot, expected_screen_distances, 'LineWidth', 2)
    text(23, 23, [' Fit: y = ' num2str(gradient) 'x + ' num2str(offset)])

    distances_rms = gradient * magnet_distances + offset;
    rms = rmse(distances_rms, reconstructed_positions); % find root mean squared error between the predicted rise indices and the observed rise indices
    text(23, 22.8, ['RMS value = ' num2str(rms)])

    saveas(f, 'Corrector magnet data/BLM_16072025_Corrector_Magnets_Reconstructed_Distance_CFD.png')

end



function plot_signals(up_data, down_data, smooth_up_data, smooth_down_data, magnets, rise_indices_up, rise_indices_down)
    % Plot the data

    f = figure;
    f.Position = [900 500 800 800];
    t = tiledlayout(2,2, 'TileSpacing','Compact');

    title(t, 'Beam Loss For Corrector Magnets Along CLEAR Beamline', fontsize = 18)
    subtitle(t, 'Rise time found using Constant Fraction Discriminator (CFD)')
    C = {'red', 'green', 'blue', 'cyan'}; % cell array of colours
    
    
    % up data
    ax1 = nexttile;
    hold on
    for i = 1:length(magnets)
        plot(up_data(i, :), 'color', C{i}, 'DisplayName', ['Magnet ', num2str(magnets(i))], 'LineWidth', 2)
        scatter(rise_indices_up(i), up_data(i, rise_indices_up(i)),100, C{i},'filled', 'HandleVisibility', 'off')
    end
    title("Raw upstream signal")
    xlabel("Time points (ns)")
    ylabel("Photomultiplier signal (V?)")
    legend()
    
    % down data
    ax2 = nexttile;
    hold on
    for i = 1:length(magnets)
        plot(down_data(i, :), 'color', C{i}, 'DisplayName', ['Magnet ', num2str(magnets(i))], 'LineWidth', 2)
        scatter(rise_indices_down(i), down_data(i, rise_indices_down(i)),100, C{i},'filled', 'HandleVisibility', 'off')
    end
    title("Raw downstream signal")
    xlabel("Time points (ns)")
    ylabel("Photomultiplier signal (V?)")
    legend()
    
    % smooth up data
    ax3 = nexttile;
    hold on
    for i = 1:length(magnets)
        plot(smooth_up_data(i, :), 'color', C{i}, 'DisplayName', ['Magnet ', num2str(magnets(i))], 'LineWidth', 2)
        scatter(rise_indices_up(i), smooth_up_data(i, rise_indices_up(i)),100, C{i},'filled', 'HandleVisibility', 'off')
    end
    title("Smoothed upstream signal")
    xlabel("Time points (ns)")
    ylabel("Photomultiplier signal (V?)")
    legend()
    
    % smooth down data
    ax4 = nexttile;
    hold on
    for i = 1:length(magnets)
        plot(smooth_down_data(i, :), 'color', C{i}, 'DisplayName', ['Magnet ', num2str(magnets(i))], 'LineWidth', 2)
        scatter(rise_indices_down(i), smooth_down_data(i, rise_indices_down(i)),100, C{i},'filled', 'HandleVisibility', 'off')
    end
    title("Smoothed downstream signal")
    xlabel("Time points (ns)")
    ylabel("Photomultiplier signal (V?)")
    legend()
    
    axis([ax1 ax3], [200 800 -0.02 0.12])
    axis([ax2 ax4], [200 800 0.05 0.55])

    saveas(t, 'Corrector magnet data/BLM_16072025_Corrector_Magnets_Signal_CFD.png')
end
