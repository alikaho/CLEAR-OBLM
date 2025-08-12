function [up_data, down_data, smooth_up_data, smooth_down_data] = Acquire_screen_saved_signal(date, screen)
% Calls back the txt file from 16072025 saved data from BTV screen data for a given
% screen number

    parent_folder = fileparts(cd); % get the parent folder of this script
    addpath(fullfile(parent_folder, 'BLM_Analysis')); % add path with Analysis

    all_data = table2array(readtable(parent_folder + "/BLM_Analysis/BTV screen data/BLM_GUI_data_" + num2str(date) + "_BTV_" + num2str(screen) + ".txt"));

    up_data = all_data(1:1000);
    down_data = all_data(1001:2000);
    smooth_up_data = all_data(2001:3000);
    smooth_down_data = all_data(3001:4000);

    
end