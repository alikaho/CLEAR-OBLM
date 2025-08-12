function [up_data, down_data, smooth_up_data, smooth_down_data] = Acquire_saved_signal(date_time)
% Calls back the txt file from Raw BLM data from a certain date and time
    disp('wjhofiw')
    parent_folder = fileparts(cd) % get the parent folder of this script
    % addpath(fullfile(parent_folder, 'BLM_Analysis')); % add path with GUI app

    all_data = table2array(readtable(parent_folder + "BLM_Analysis/Raw BLM data/BLM_GUI_data_" + date_time + ".txt"));

    up_data = all_data(1:1000);
    down_data = all_data(1001:2000);
    smooth_up_data = all_data(2001:3000);
    smooth_down_data = all_data(3001:4000);

    
end