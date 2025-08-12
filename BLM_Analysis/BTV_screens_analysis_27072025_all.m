
% Script plots the BLM waveforms for all screens. No reconstruction of positions since don't have known distances for all screens. 

close all
date = num2str(27072025);
refr_idx = 1.465; % silicon refractive index for fiber distance of around 60m. See effective refractive index to see full accounting of fiber distance/attenuation/wavelength etc. 

parent_folder = fileparts(cd); % get the parent folder of this script
addpath(fullfile(parent_folder, 'BLM_GUI_APP')); % add path with GUI app


[up_data, down_data, smooth_up_data, smooth_down_data] = get_data(date); % get the data from the txt files in BTV screen data


% cut down to the usable screens
screens_plot =  {'BTV 215', 'BTV 235', 'BTV 390 YAG', 'BTV 390 OTR', 'BTV 390 CHROMOX', 'BTV 545', 'BTV 620', 'BTV 730', 'BTV 810', 'BTV 910', 'No Screens', 'Pre-conical scatterer', 'BHB400', 'BHB400 with BTV 420'};

[rise_indices_up, rise_indices_down] = Find_rise_indices(up_data, down_data);

Plot_signals(up_data, down_data, screens_plot, rise_indices_up, rise_indices_down, date);



function [up_data, down_data, smooth_up_data, smooth_down_data] = get_data(date)
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

    title(t, 'Beam Loss For All Screen Types Along CLEAR Beamline', fontsize = 18)
    subtitle(t, 'Rise time found using Constant Fraction Discriminator (CFD)')
    C = {
        'red',                  % Pure red [1 0 0]
        'green',                % Pure green [0 1 0]
        'blue',                 % Pure blue [0 0 1]
        'cyan',                 % Cyan [0 1 1]
        'magenta',              % Magenta [1 0 1]
        'yellow',               % Yellow [1 1 0]
        'black',                % Black [0 0 0]
        [1 0.5 0],              % Orange
        [0.5 0 0.5],            % Purple
        [0 0.5 0],              % Dark green
        [0.5 0.5 0.5],          % Gray
        [0.9290 0.6940 0.1250], % MATLAB gold
        [0.4940 0.1840 0.5560]  % MATLAB purple
        [0.3010 0.7450 0.9330]  % MATLAB light blue

    };
    
    % up data
    ax1 = nexttile;
    hold on
    for i = 1:length(screens)
        plot(up_data(i, :), 'Color', C{i}, 'DisplayName',  [screens{i}], 'LineWidth', 2)
        scatter(rise_indices_up(i), up_data(i, rise_indices_up(i)),100, C{i}, 'filled', 'HandleVisibility', 'off')
    end
    title("Upstream")
    xlabel("Time points (ns)")
    ylabel("Photomultiplier signal (V)")
    legend('FontSize', 14)
    
    % down data
    ax2 = nexttile;
    hold on
    for i = 1:length(screens)
        plot(down_data(i, :), 'Color', C{i}, 'DisplayName', [screens{i}], 'LineWidth', 2)
        scatter(rise_indices_down(i), down_data(i, rise_indices_down(i)),100, C{i}, 'filled', 'HandleVisibility', 'off')
    end
    title("Downstream")
    xlabel("Time (ns)")
    ylabel("Photomultiplier signal (V)")
    legend('FontSize', 14)

    axis(ax1, [100 1000 -0.05 0.2])
    axis(ax2, [100 1000 0 0.7])    

%     savefig(f_waveforms, ['Corrector magnet data/BLM_', date, '_Corrector_Magnets_Signal_CFD.fig'])
    exportgraphics(f_waveforms, ['BTV screen data/BLM_', date, '_BTV_Screens_Waveforms_All_CFD.png'])
end

