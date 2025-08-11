function Copy_and_rename_data(table, date)
    % Copies the data from the Raw BLM data folder and renames to put into
    % BTV screen data folder
    % WARNING: 27072025 had more complicated data than just screen names (e.g. screen types/ BHB400 with and without 420) so these were done manually. DO NOT USE THIS FUNCTION ON THE 27072025 DATA! 

    % Call the lookup table between timestamps and screen names
    unsorted_lookup = readtable(table);
    lookup = sortrows(unsorted_lookup, 2); % sorts by magnet values
    timestamps = lookup{:, 1};
    screens = lookup{:, 2};
    
    % Copy files from the raw data folder to this folder and rename with the
    % screen name (will need to change date of the recorded data)

    % copy jpg filesp+ offsetre
    for i = 1:length(timestamps)
        copyfile("Raw BLM data/BLM_GUI_data_" + date + "-" + char(timestamps(i)) + ".jpg", "BTV screen data/BLM_GUI_data_" + date + "_BTV_" + screens(i) + ".jpg")
    end
    
end
