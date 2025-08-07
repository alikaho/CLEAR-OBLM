

[up_data, down_data, smooth_up_data, smooth_down_data, magnets, hor, vert] = get_data('16072025_corrector_magnet_lookup.txt');

plot_signal_differing_current(up_data, down_data, smooth_up_data, smooth_down_data, magnets, vert);
plot_rise_times_differing_current(smooth_up_data, magnets)

plot_signal_differing_magnets(up_data, down_data, smooth_up_data, smooth_down_data, magnets);
plot_rise_time_differing_magnets(smooth_up_data)


function [up_data, down_data, smooth_up_data, smooth_down_data, magnets, hor, vert] = get_data(table)

    % Call the lookup table between timestamps and screen names
    unsorted_lookup = readtable(table);
    lookup = sortrows(unsorted_lookup, [3 5]); % sorts by magnet values and then by the steering magnet current
    timestamps = lookup{:, 1};
    magnets = lookup{:, 3};
    hor = lookup{:, 4};
    vert = lookup{:, 5};
    
    % % Copy files from the raw data folder to this folder and rename with the
    % % screen name (will need to change date of the recorded data)
    % my_dir = pwd; % current directory
    % idx_slash = strfind(my_dir,'/');
    % upper_dir = my_dir(1:idx_slash(end)-1);
    % 
    for i = 1:length(timestamps)
        copyfile("Raw BLM data/BLM_GUI_data_16072025-" + char(timestamps(i)) + ".txt", my_dir + "/BLM_GUI_data_16072025_magnet_" + magnets(i) + "_" + hor(i) + "H" + vert(i) + "V.txt")
    end
    
    
    % Extracting up, down and smoothed data
    all_data = zeros(length(magnets), 4000);
    
    for i = 1:length(magnets)
        % all_data is up_data, down_data, smooth_up_data, smooth_data_down in a
        % length(screens)x4000 array 
        all_data(i, :) = table2array(readtable("BLM_GUI_data_16072025_magnet_" + magnets(i) + "_" + hor(i) + "H" + vert(i) + "V.txt"));
    
    end
    
    up_data = all_data(:, 1:1000);
    down_data = all_data(:, 1001:2000);
    smooth_up_data = all_data(:, 2001:3000);
    smooth_down_data = all_data(:, 3001:4000);

end




function plot_signal_differing_current(up_data, down_data, smooth_up_data, smooth_down_data, magnets, vert)
% Plot the signals for each magnet with differing currents

    for k = 1:4
        
        magnet_names = [320, 385, 590, 710];
        
        indices = find(magnets == magnet_names(k));
    
        f = figure(k);
        x_pos = 2300 + (k-1)*710;
        f.Position = [x_pos 2500 700 700];
        t = tiledlayout(2,2, 'TileSpacing','Compact');
    
        title(t, ['Beam Loss For Steering Magnet ', num2str(magnet_names(k))], fontsize = 20)
        subtitle(t, '(No horizontal steering)')
        C = {'red', 'green', 'blue', 'magenta', '#FF8800'}; % cell array of colours
        
    
        % up data
        ax1 = nexttile;
        hold on
        for i = indices(1):indices(end)
            plot(up_data(i, :), 'color', C{i+1-indices(1)}, 'DisplayName', [num2str(vert(i)), 'A'], 'LineWidth', 2)
        end
        title("Raw upstream signal")
        xlabel("Time points (ns)")
        ylabel("Photomultiplier signal (V?)")
        legend()
        
        % down data
        ax2 = nexttile;
        hold on
        for i = indices(1):indices(end)
            plot(down_data(i, :), 'color', C{i+1-indices(1)}, 'DisplayName', [num2str(vert(i)), 'A'], 'LineWidth', 2)
        end
        title("Raw downstream signal")
        xlabel("Time points (ns)")
        ylabel("Photomultiplier signal (V?)")
        legend()
        
        % smooth up data
        ax3 = nexttile;
        hold on
        for i = indices(1):indices(end)
            plot(smooth_up_data(i, :), 'color', C{i+1-indices(1)}, 'DisplayName', [num2str(vert(i)), 'A'], 'LineWidth', 2)
        end
        title("Smoothed upstream signal")
        xlabel("Time points (ns)")
        ylabel("Photomultiplier signal (V?)")
        legend()
        
        % smooth down data
        ax4 = nexttile;
        hold on
        for i = indices(1):indices(end)
            plot(smooth_down_data(i, :), 'color', C{i+1-indices(1)}, 'DisplayName', [num2str(vert(i)), 'A'], 'LineWidth', 2)
        end
        title("Smoothed downstream signal")
        xlabel("Time points (ns)")
        ylabel("Photomultiplier signal (V?)")
        legend()
        
    
        max_down = max(down_data(indices(1):indices(end), :), [], 'all');
        max_up = max(up_data(indices(1):indices(end), :), [], 'all');
    
        axis([ax1 ax3], [300 800 -0.02 max_up + 0.01])
        axis([ax2 ax4], [300 800 0.05 max_down + 0.01])

        saveas(f, "BLM_16072025_Magnet_" + magnet_names(k) + "_Signal_Differing_Current.png")
        
    end
    hold off


end




function plot_rise_times_differing_current(smooth_up_data, magnets)
    % plots the rise times for different current values and for all
    % different magnets

    magnet_names = [320, 385, 590, 710];
    currents = [2, 4, 6, 8, 10]; % in amps
    currents_710 = [4, 6, 8, 10];
    C = {'red', 'green', 'blue', '#FF8800'}; % cell array of colours

    f = figure;
    f.Position = [3000 2500 700 700];
    title("Upstream rise time against current through steering magnets", fontsize = 12)
    hold on

    for k = 1:3 % not to 4 since 710 missing a point

        indices = find(magnets == magnet_names(k));

        rise_indices = zeros(1, 5);

        % change directories to grab Find_rise_time_idx function
        my_dir = pwd;
        idx_slash = strfind(my_dir,'/');
        upper_dir = my_dir(1:idx_slash(end)-1);
        cd(upper_dir); % go to the upper directory to find the function
        

        for i = 1:5
            rise_indices(i) = Find_rise_time_idx(smooth_up_data(i-1+indices(1), :));
        end

        cd(my_dir)

        plot(currents, rise_indices, '.', 'MarkerSize', 30, 'DisplayName', [num2str(magnet_names(k))], 'color', C{k})

        % fit with straight line
        fit = polyfit(currents, rise_indices, 1);
        gradient = fit(1);
        offset = fit(2);
        
        % plot straight line
        currents_plot = 2:10;
        rise_indices_expected =  gradient * currents_plot + offset;
        
        plot(currents_plot, rise_indices_expected, 'LineWidth', 2, 'color', C{k}, 'HandleVisibility', 'off')
        text(currents(3) + 1, rise_indices_expected(6) + 2, ['  Fit: y = ' num2str(gradient) 'x + ' num2str(offset)],'color', C{k})

    end

    % plot 710 ignoring current = 2A

    indices = find(magnets == 710);

    rise_indices = zeros(1, 4);

    % change directories to grab Find_rise_time_idx function
    my_dir = pwd;
    idx_slash = strfind(my_dir,'/');
    upper_dir = my_dir(1:idx_slash(end)-1);
    cd(upper_dir); % go to the upper directory to find the function
    

    for i = 1:4
        rise_indices(i) = Find_rise_time_idx(smooth_up_data(i+indices(1), :));
    end

    cd(my_dir)

    plot(currents_710, rise_indices, '.', 'MarkerSize', 30, 'DisplayName', num2str(710), 'color', C{4})

    % fit with straight line
    fit = polyfit(currents_710, rise_indices, 1);
    gradient = fit(1);
    offset = fit(2);
    
    % plot straight line
    currents_710_plot = 2:10;
    rise_indices_expected =  gradient * currents_710_plot + offset;
    
    plot(currents_710_plot, rise_indices_expected, 'LineWidth', 2, 'color', C{4}, 'HandleVisibility', 'off')
    text(currents(3) + 1, rise_indices_expected(6) + 2, ['  Fit: y = ' num2str(gradient) 'x + ' num2str(offset)],'color', C{4})



    legend('Location', 'west')
    xlabel("Current through steering magnet (A)")
    ylabel("Upstream rise time (ns)")

    hold off

    saveas(f, "BLM_16072025_Magnets_Rise_Time_vs_Current.png")

    
end







function plot_signal_differing_magnets(up_data, down_data, smooth_up_data, smooth_down_data, magnets)
% Plot the signals for each magnet with differing currents
        
    f = figure;
    f.Position = [3000 2500 700 700];
    t = tiledlayout(2,2, 'TileSpacing','Compact');

    title(t, 'Beam Loss For Steering Magnets at 10A' )
    subtitle(t, '(Purely vertical steering)')
    C = {'red', 'green', 'blue', '#FF8800'}; % cell array of colours
    

    % up data
    ax1 = nexttile;
    hold on
    for i = [5, 10, 15, 20]
        plot(up_data(i, :), 'color', C{i/5}, 'DisplayName', [num2str(magnets(i))], 'LineWidth', 2)
    end
    title("Raw upstream signal")
    xlabel("Time points (ns)")
    ylabel("Photomultiplier signal (V?)")
    legend()
    
    % down data
    ax2 = nexttile;
    hold on
    for i = [5, 10, 15, 20]
        plot(down_data(i, :), 'color', C{i/5}, 'DisplayName', [num2str(magnets(i))], 'LineWidth', 2)
    end
    title("Raw downstream signal")
    xlabel("Time points (ns)")
    ylabel("Photomultiplier signal (V?)")
    legend()
    
    % smooth up data
    ax3 = nexttile;
    hold on
    for i = [5, 10, 15, 20]
        plot(smooth_up_data(i, :), 'color', C{i/5}, 'DisplayName', [num2str(magnets(i))], 'LineWidth', 2)
    end
    title("Smoothed upstream signal")
    xlabel("Time points (ns)")
    ylabel("Photomultiplier signal (V?)")
    legend()
    
    % smooth down data
    ax4 = nexttile;
    hold on
    for i = [5, 10, 15, 20]
        plot(smooth_down_data(i, :), 'color', C{i/5}, 'DisplayName', [num2str(magnets(i))], 'LineWidth', 2)
    end
    title("Smoothed downstream signal")
    xlabel("Time points (ns)")
    ylabel("Photomultiplier signal (V?)")
    legend()
    

    max_down = max(down_data([5 10 15 20],:), [], 'all');
    max_up = max(up_data([5 10 15 20],:), [], 'all');

    axis([ax1 ax3], [300 800 -0.02 max_up + 0.01])
    axis([ax2 ax4], [300 800 0.05 max_down + 0.01])
    

    hold off
    saveas(f, "BLM_16072025_10A_Signal_Differing_Magnets.png")

end


function plot_rise_time_differing_magnets(smooth_up_data)
% Plot the signals for each magnet with differing currents
        
    magnet_names = [320 385 590 710]; % not gonna plot all screens
    rise_indices = zeros(1, length(magnet_names));
    
    % change directories to grab Find_rise_time_idx function
    my_dir = pwd;
    idx_slash = strfind(my_dir,'/');
    upper_dir = my_dir(1:idx_slash(end)-1);
    cd(upper_dir); % go to the upper directory to find the function
    
    for i = 1:length(magnet_names)
        rise_indices(i) = Find_rise_time_idx(smooth_up_data(i*5, :));
    end
    
    cd(my_dir) % come back to our directory

    magnet_distances = [17.7 20 25.21 29.31];

    f = figure;
    f.Position = [3000 2500 800 800];

    plot(magnet_distances, rise_indices, '.', 'MarkerSize', 30, 'Color', 'blue')
    title("Upstream Rise Time Against Steering Magnet (at 10A) Distances")
    xlabel("Steering magnet distances (m)")
    ylabel("Upstream rise time (ns)")
    text(magnet_distances, rise_indices, sprintfc('  %d', magnet_names))
    axis([15 36 360 460])
    hold on

    % fit with straight line
    fit = polyfit(magnet_distances, rise_indices, 1);
    gradient = fit(1);
    offset = fit(2);

    % plot straight line
    magnet_distances_plot = 15:36;
    rise_indices_expected =  gradient * magnet_distances_plot + offset;

    plot(magnet_distances_plot, rise_indices_expected, 'LineWidth', 2, 'Color', 'blue')
    text(25, 390, [' Fit: y = ' num2str(gradient) 'x + ' num2str(offset)])

    hold off

    saveas(f, "BLM_16072025_Magnets_Rise_Time_vs_Distance.png")

end



