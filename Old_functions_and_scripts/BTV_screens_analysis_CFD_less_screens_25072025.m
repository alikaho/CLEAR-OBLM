
% Script analyses the BLM signals from screens 390, 620, 730 and 810.
% Plots the reconstructed positions, and pulls the relationship between the
% reconstructed positions (ALONG THE FIBER) and the actual BTV screen
% positions (ALONG THE BEAM). These would be expected to give a 1-to-1
% gradient given the fiber is parallel, 

date = num2str(25072025);

[up_data, down_data, smooth_up_data, smooth_down_data, screens] = get_and_copy_data(['BTV screen data/', date, '_BTV_screen_lookup.txt'], date);
[rise_indices_up, rise_indices_down] = Find_rise_indices(up_data, down_data);
[gradient, offset] = Plot_reconstructed_positions(rise_indices_up, rise_indices_down, date)
plot_signals(up_data, down_data, smooth_up_data, smooth_down_data, screens, rise_indices_up, rise_indices_down, date);



function [up_data, down_data, smooth_up_data, smooth_down_data, screens] = get_and_copy_data(table, date)
    % Call the lookup table between timestamps and screen names
    lookup = readtable(table);
    timestamps = lookup{:, 'Timestamp'};
    screens_unsorted = lookup{:, 'Screen'};
    
    
%     % Copy files from the raw data folder to this folder and rename with the
%     % screen name (will need to change date of the recorded data)
%     my_dir = pwd; % current directory
%     idx_slash = strfind(my_dir,'/');
%     upper_dir = my_dir(1:idx_slash(end)-1);
    
    for i = 1:length(timestamps)
        copyfile("Raw BLM data/BLM_GUI_data_" + date + "-" + char(timestamps(i)) + ".txt", "BTV screen data/BLM_GUI_data_" + date + "_BTV_" + screens_unsorted(i) + ".txt")
    end
    
    
    % Extracting up, down and smoothed data
    all_data = zeros(length(screens_unsorted), 4000);
    screens = sort(screens_unsorted);
    
    for i = 1:length(screens)
        % all_data is up_data, down_data, smooth_up_data, smooth_data_down in a
        % length(screens)x4000 array 
        all_data(i, :) = table2array(readtable("BTV screen data/BLM_GUI_data_" + date + "_BTV_" + screens(i) + ".txt"));
        
    end
    
    up_data = all_data(:, 1:1000);
    down_data = all_data(:, 1001:2000);
    smooth_up_data = all_data(:, 2001:3000);
    smooth_down_data = all_data(:, 3001:4000);

end



function [rise_indices_up, rise_indices_down] = Find_rise_indices(up_data, down_data)
    
    number_screens = size(up_data, 1);
    rise_indices_up = zeros(1, number_screens)
    rise_indices_down = zeros(1, number_screens)

    for i = 1:number_screens
        rise_indices_up(i) = Find_rise_time_CFD(up_data(i,:));
        rise_indices_down(i) = Find_rise_time_CFD(down_data(i,:));
        
    end

end



function [gradient, offset] = Plot_reconstructed_positions(rise_indices_up, rise_indices_down, date)
    screen_names = [390 620 730 810]; % not gonna plot all screens
    reconstructed_positions = Find_fiber_loss_dist(rise_indices_up, rise_indices_down);

    screen_distances = [20.6 26.04 29.75 32.55];

    f = figure;
    f.Position = [1800 500 800 800];

    plot(screen_distances, reconstructed_positions, '.', 'MarkerSize', 20)
    title("Reconstructed positions against known BTV screen distances")
    subtitle("Constant Fraction Discriminator (CFD) method")
    xlabel("BTV screen distances (m)")
    ylabel("Reconstructed screen positions (m)")
    text(screen_distances, reconstructed_positions, sprintfc('  %d', screen_names))
    hold on

    % fit with straight line
    fit = polyfit(screen_distances, reconstructed_positions, 1);
    gradient = fit(1);
    offset = fit(2);

    % plot straight line
    screen_distances_plot = [screen_distances(1),screen_distances(end)];
    expected_screen_distances =  gradient * screen_distances_plot + offset;

    plot(screen_distances_plot, expected_screen_distances, 'LineWidth', 2)
    text(screen_distances_plot(1) + 5, expected_screen_distances(1) + 1, [' Fit: y = ' num2str(gradient) 'x + ' num2str(offset)])

    distances_rms = gradient * screen_distances + offset;
    rms = rmse(distances_rms, reconstructed_positions); % find root mean squared error between the predicted rise indices and the observed rise indices
    text(screen_distances_plot(1) + 5, expected_screen_distances(1) + 0.75, ['RMS value = ' num2str(rms)])

    savefig(['BTV screen data/BLM_', date, '_BTV_Screens_Reconstructed_Distance_CFD.fig'])

end



function plot_signals(up_data, down_data, smooth_up_data, smooth_down_data, screens, rise_indices_up, rise_indices_down, date)
    % Plot the data

    f = figure;
    f.Position = [900 500 800 800];
    t = tiledlayout(2,2, 'TileSpacing','Compact');

    title(t, 'Beam Loss For BTV Screens Inserted Along CLEAR Beamline', fontsize = 18)
    subtitle(t, date)
    C = {'red', 'green', 'blue', 'cyan', 'magenta', '#FF8800', 'black', '#800080'}; % cell array of colours
    
    
    % up data
    ax1 = nexttile;
    hold on
    for i = 1:length(screens)
        plot(up_data(i, :), 'color', C{i}, 'DisplayName', ['BTV', num2str(screens(i))], 'LineWidth', 2)
        scatter(rise_indices_up(i), up_data(i, rise_indices_up(i)),100, C{i},'filled', 'HandleVisibility', 'off')
    end
    title("Raw upstream signal")
    xlabel("Time points (ns)")
    ylabel("Photomultiplier signal (V?)")
    legend()
    
    % down data
    ax2 = nexttile;
    hold on
    for i = 1:length(screens)
        plot(down_data(i, :), 'color', C{i}, 'DisplayName', ['BTV', num2str(screens(i))], 'LineWidth', 2)
        scatter(rise_indices_down(i), down_data(i, rise_indices_down(i)),100, C{i},'filled', 'HandleVisibility', 'off')
    end
    title("Raw downstream signal")
    xlabel("Time points (ns)")
    ylabel("Photomultiplier signal (V?)")
    legend()
    
    % smooth up data
    ax3 = nexttile;
    hold on
    for i = 1:length(screens)
        plot(smooth_up_data(i, :), 'color', C{i}, 'DisplayName', ['BTV', num2str(screens(i))], 'LineWidth', 2)
        scatter(rise_indices_up(i), smooth_up_data(i, rise_indices_up(i)),100, C{i},'filled', 'HandleVisibility', 'off')
    end
    title("Smoothed upstream signal")
    xlabel("Time points (ns)")
    ylabel("Photomultiplier signal (V?)")
    legend()
    
    % smooth down data
    ax4 = nexttile;
    hold on
    for i = 1:length(screens)
        plot(smooth_down_data(i, :), 'color', C{i}, 'DisplayName', ['BTV', num2str(screens(i))], 'LineWidth', 2)
        scatter(rise_indices_down(i), smooth_down_data(i, rise_indices_down(i)),100, C{i},'filled', 'HandleVisibility', 'off')
    end
    title("Smoothed downstream signal")
    xlabel("Time points (ns)")
    ylabel("Photomultiplier signal (V?)")
    legend()
    % 
    % axis([ax1 ax3], [200 800 min(up_data)-0.02 max(up_data)])
    % axis([ax2 ax4], [200 800 min(down_data)+0.02 max(down_data)])

    saveas(t, ['BTV screen data/BLM_', date, '_BTV_Screens_Signal_CFD.fig'])
end



