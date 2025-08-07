
[up_data, down_data, smooth_up_data, smooth_down_data, screens] = get_data('BTV screen data/16072025_BTV_screen_lookup.txt');
plot_signal_different_screen(up_data, down_data, smooth_up_data, smooth_down_data, screens);
plot_rise_times(smooth_up_data);
plot_rise_times_less(smooth_up_data);

function [up_data, down_data, smooth_up_data, smooth_down_data, screens] = get_data(table)
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
        copyfile("Raw BLM data/BLM_GUI_data_16072025-" + char(timestamps(i)) + ".txt", "BTV screen data/BLM_GUI_data_16072025_BTV_" + screens_unsorted(i) + ".txt")
    end
    
    
    % Extracting up, down and smoothed data
    all_data = zeros(length(screens_unsorted), 4000);
    screens = sort(screens_unsorted);
    
    for i = 1:length(screens)
        % all_data is up_data, down_data, smooth_up_data, smooth_data_down in a
        % length(screens)x4000 array 
        all_data(i, :) = table2array(readtable("BTV screen data/BLM_GUI_data_16072025_BTV_" + screens(i) + ".txt"));
        
    end
    
    up_data = all_data(:, 1:1000);
    down_data = all_data(:, 1001:2000);
    smooth_up_data = all_data(:, 2001:3000);
    smooth_down_data = all_data(:, 3001:4000);

end


function plot_signal_different_screen(up_data, down_data, smooth_up_data, smooth_down_data, screens)
    % Plot the data
    
    f = figure;
    f.Position = [900 500 800 800];
    t = tiledlayout(2,2, 'TileSpacing','Compact');

    title(t, 'Beam Loss For BTV Screens Inserted Along CLEAR Beamline', fontsize = 20)
    C = {'red', 'green', 'blue', 'cyan', 'magenta', '#FF8800', 'black', '#800080'}; % cell array of colours
    
    
    % up data
    ax1 = nexttile;
    hold on
    for i = 1:length(screens)
        plot(up_data(i, :), 'color', C{i}, 'DisplayName', ['BTV', num2str(screens(i))], 'LineWidth', 2)
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
    end
    title("Smoothed downstream signal")
    xlabel("Time points (ns)")
    ylabel("Photomultiplier signal (V?)")
    legend()
    
    axis([ax1 ax3], [200 800 -0.02 0.12])
    axis([ax2 ax4], [200 800 0.05 0.55])

    saveas(t, 'BLM_16072025_BTV_Screens_Signal.png')
end






function plot_rise_times(smooth_up_data)


    screen_names = [215 390 545 620 730 810]; % not gonna plot all screens
    rise_indices = zeros(1, length(screen_names));
    
    % change directories to grab Find_rise_time_idx function
%     my_dir = pwd;
%     idx_slash = strfind(my_dir,'/');
%     upper_dir = my_dir(1:idx_slash(end)-1);
%     cd(upper_dir); % go to the upper directory to find the function

    for i = 1:length(screen_names)+1
        rise_indices(i) = Find_rise_time_gradient(smooth_up_data(i, :));
    end
    
%     cd(my_dir) % come back to our directory

    % removing BTV 240 since don't know distance
    rise_indices(2) = [];

    screen_distances = [1.81 20 24.5 26.04 29.75 32.53];

    f = figure;
    f.Position = [1800 500 800 800];

    plot(screen_distances, rise_indices, '.', 'MarkerSize', 20)
    title("Upstream rise time vs known BTV screen distances")
    xlabel("BTV screen distances (m)")
    ylabel("Upstream rise time (ns)")
    text(screen_distances, rise_indices, sprintfc('  %d', screen_names))
    axis([0 36 280 460])
    hold on

    % fit with straight line
    fit = polyfit(screen_distances, rise_indices, 1);
    gradient = fit(1);
    offset = fit(2);

    % plot straight line
    screen_distances_plot = 0:36;
    rise_indices_expected =  gradient * screen_distances_plot + offset;

    plot(screen_distances_plot, rise_indices_expected, 'LineWidth', 2)
    text(15, 330, [' Fit: y = ' num2str(gradient) 'x + ' num2str(offset)])

    rise_indices_rms = gradient * screen_distances + offset;
    rms = rmse(rise_indices_rms, rise_indices); % find root mean squared error between the predicted rise indices and the observed rise indices
    text(15, 320, ['RMS value = ' num2str(rms)])

    saveas(f, 'BLM_16072025_BTV_Screens_Rise_Time_Distance.png')
    
end




function plot_rise_times_less(smooth_up_data)

    screen_names = [390 620 730 810]; % not gonna plot all screens
    rise_indices = zeros(1, length(screen_names));

    rise_indices(1) = Find_rise_time_gradient(smooth_up_data(3, :));
    rise_indices(2) = Find_rise_time_gradient(smooth_up_data(5, :));
    rise_indices(3) = Find_rise_time_gradient(smooth_up_data(6, :));
    rise_indices(4) = Find_rise_time_gradient(smooth_up_data(7, :));


    screen_distances = [20.6 26.04 29.75 32.53];

    f = figure;
    f.Position = [1800 500 800 800];

    plot(screen_distances, rise_indices, '.', 'MarkerSize', 20)
    title("Upstream rise time vs known BTV screen distances")
    xlabel("BTV screen distances (m)")
    ylabel("Upstream rise time (ns)")
    text(screen_distances, rise_indices, sprintfc('  %d', screen_names))
    axis([18 36 380 460])
    hold on

    % fit with straight line
    fit = polyfit(screen_distances, rise_indices, 1);
    gradient = fit(1);
    offset = fit(2);

    % plot straight line
    screen_distances_plot = 0:36;
    rise_indices_expected =  gradient * screen_distances_plot + offset;

    plot(screen_distances_plot, rise_indices_expected, 'LineWidth', 2)
    text(26, 400, [' Fit: y = ' num2str(gradient) 'x + ' num2str(offset)])

    rise_indices_rms = gradient * screen_distances + offset;
    rms = rmse(rise_indices_rms, rise_indices); % find root mean squared error between the predicted rise indices and the observed rise indices
    text(26, 397, ['RMS value = ' num2str(rms)])

    saveas(f, 'BLM_16072025_BTV_Screens_Rise_Time_Distance.png')
    
end
