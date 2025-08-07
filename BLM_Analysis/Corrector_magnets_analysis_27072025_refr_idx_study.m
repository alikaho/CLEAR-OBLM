
close all
date = '27072025';


[up_data, down_data, smooth_up_data, smooth_down_data, magnets] = get_data('Corrector magnet data/27072025_corrector_magnet_lookup.txt');
[rise_indices_up, rise_indices_down] = Find_rise_indices(up_data, down_data);

magnet_distances = transpose(Get_magnet_distances(magnets));



% Plot for a range of refractive indices
refr_indices = linspace(1.45, 1.55, 5);
Plot_diff_refr_combined_readout(refr_indices, rise_indices_up, rise_indices_down, magnets, magnet_distances, date)
Plot_diff_refr_upstream(refr_indices, rise_indices_up, magnets, magnet_distances, date)
Plot_diff_refr_downstream(refr_indices, rise_indices_down, magnets, magnet_distances, date)


function Plot_diff_refr_combined_readout(refr_indices, rise_indices_up, rise_indices_down, magnets, magnet_distances, date)
    
    % Combined readout method
    f_comb = figure(2);
    f_comb.Position = [1800 500 800 800];
    hold on
    
    title("Reconstructed positions using combined readout method")
    subtitle("For different silicon refractive indices")
    xlabel("BTV magnet distances (m)")
    ylabel("Reconstructed magnet positions (m)")
    
    C = {'blue', 'red', 'green', 'cyan', 'magenta'};
    
    for i = 1:length(refr_indices)
        reconstructed_positions = Find_fiber_loss_dist_combined_readout(refr_indices(i), rise_indices_up, rise_indices_down);
    
        % fit with straight line
        fit = polyfit(magnet_distances, reconstructed_positions, 1);
        gradient = fit(1);
        offset = fit(2);
    
        plot(magnet_distances, reconstructed_positions - offset, '.', 'MarkerSize', 20, 'Color', C{i}, 'HandleVisibility','off')
    
    
        % plot straight line
        magnet_distances_plot = [magnet_distances(1),magnet_distances(end)];
        expected_magnet_distances =  gradient * magnet_distances_plot;
    
        plot(magnet_distances_plot, expected_magnet_distances, 'LineWidth', 2, 'Color',C{i},'DisplayName', ['n = ', num2str(refr_indices(i))])
        text(magnet_distances_plot(1), expected_magnet_distances(1) + 18 - i * 0.7, [' Fit: y = ' num2str(gradient) 'x + ' num2str(offset)], 'Color', C{i})
        legend('Location', 'best')
    
    
        distances_rms = gradient * magnet_distances + offset;
        rms = rmse(distances_rms, reconstructed_positions); % find root mean squared error between the predicted rise indices and the observed rise indices
        text(magnet_distances_plot(1) + 10, expected_magnet_distances(1) + 18 - i * 0.7, ['RMS = ' num2str(rms)], 'Color', C{i})
                
        

        
    end
    
    text(magnet_distances, reconstructed_positions - offset, sprintfc('  %d', magnets))
    exportgraphics(f_comb, ['Corrector magnet data/BLM_', date, '_Corrector_Magnets_Reconstructed_Distance_CFD_Combined_Refr_Idx.png'])
end





function Plot_diff_refr_upstream(refr_indices, rise_indices_up, magnets, magnet_distances, date)
    
    % Combined readout method
    f_up = figure(3);
    f_up.Position = [1800 500 800 800];
    hold on
    
    title("Reconstructed positions using upstream signal only")
    subtitle("For different silicon refractive indices")
    xlabel("BTV magnet distances (m)")
    ylabel("Reconstructed magnet positions (m)")
    
    C = {'blue', 'red', 'green', 'cyan', 'magenta'};
    
    for i = 1:length(refr_indices)
        reconstructed_positions = Find_fiber_loss_dist_upstream(refr_indices(i), rise_indices_up);
    
        % fit with straight line
        fit = polyfit(magnet_distances, reconstructed_positions, 1);
        gradient = fit(1);
        offset = fit(2);
    
        plot(magnet_distances, reconstructed_positions - offset, '.', 'MarkerSize', 20, 'Color', C{i}, 'HandleVisibility','off')
    
    
        % plot straight line
        magnet_distances_plot = [magnet_distances(1),magnet_distances(end)];
        expected_magnet_distances =  gradient * magnet_distances_plot;
    
        plot(magnet_distances_plot, expected_magnet_distances, 'LineWidth', 2, 'Color',C{i},'DisplayName', ['n = ', num2str(refr_indices(i))])
        text(magnet_distances_plot(1), expected_magnet_distances(1) + 18 - i * 0.7, [' Fit: y = ' num2str(gradient) 'x + ' num2str(offset)], 'Color', C{i})
        legend('Location', 'best')
    
    
        distances_rms = gradient * magnet_distances + offset;
        rms = rmse(distances_rms, reconstructed_positions); % find root mean squared error between the predicted rise indices and the observed rise indices
        text(magnet_distances_plot(1) + 10, expected_magnet_distances(1) + 18 - i * 0.7, ['RMS = ' num2str(rms)], 'Color', C{i})
                
               
        
    end
    
    text(magnet_distances, reconstructed_positions - offset, sprintfc('  %d', magnets))
    exportgraphics(f_up, ['Corrector magnet data/BLM_', date, '_Corrector_Magnets_Reconstructed_Distance_CFD_Upstream_Refr_Idx.png'])

end



function Plot_diff_refr_downstream(refr_indices, rise_indices_down, magnets, magnet_distances, date)
    
    % Combined readout method
    f_down = figure(4);
    f_down.Position = [1800 500 800 800];
    hold on
    
    title("Reconstructed positions using downstream signal only")
    subtitle("For different silicon refractive indices")
    xlabel("BTV magnet distances (m)")
    ylabel("Reconstructed magnet positions (m)")
    
    C = {'blue', 'red', 'green', 'cyan', 'magenta'};
    
    for i = 1:length(refr_indices)
        reconstructed_positions = Find_fiber_loss_dist_downstream(refr_indices(i), rise_indices_down);
    
        % fit with straight line
        fit = polyfit(magnet_distances, reconstructed_positions, 1);
        gradient = fit(1);
        offset = fit(2);
    
        plot(magnet_distances, reconstructed_positions - offset, '.', 'MarkerSize', 20, 'Color', C{i}, 'HandleVisibility','off')
    
    
        % plot straight line
        magnet_distances_plot = [magnet_distances(1),magnet_distances(end)];
        expected_magnet_distances =  gradient * magnet_distances_plot;
    
        plot(magnet_distances_plot, expected_magnet_distances, 'LineWidth', 2, 'Color',C{i},'DisplayName', ['n = ', num2str(refr_indices(i))])
        text(magnet_distances_plot(1), expected_magnet_distances(1) + 18 - i * 0.4, [' Fit: y = ' num2str(gradient) 'x + ' num2str(offset)], 'Color', C{i})
        legend('Location', 'best')
    
    
        distances_rms = gradient * magnet_distances + offset;
        rms = rmse(distances_rms, reconstructed_positions); % find root mean squared error between the predicted rise indices and the observed rise indices
        text(magnet_distances_plot(1) + 10, expected_magnet_distances(1) + 18 - i * 0.4, ['RMS = ' num2str(rms)], 'Color', C{i})
                
        
    end
    
    text(magnet_distances, reconstructed_positions - offset, sprintfc('  %d', magnets))
    exportgraphics(f_down, ['Corrector magnet data/BLM_', date, '_Corrector_Magnets_Reconstructed_Distance_CFD_Downstream_Refr_Idx.png'])

end






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


