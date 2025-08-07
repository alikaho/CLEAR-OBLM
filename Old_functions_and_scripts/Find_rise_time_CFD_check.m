%% Testing the Find_rise_time_CFD function


% Call in the saved data
Fiber_up_saved = table2array(readtable("Calibration saved data/Saved_620_up.txt"));
Fiber_down_saved = table2array(readtable("Calibration saved data/Saved_620_down.txt"));
plot(Fiber_up_saved)
hold on
plot(Fiber_down_saved)

size(Fiber_up_saved)

% use the CFD rise time function
rise_idx_up = Find_rise_time_CFD(Fiber_up_saved);
rise_idx_down = Find_rise_time_CFD(Fiber_down_saved);
scatter(rise_idx_up, Fiber_up_saved(rise_idx_up))
scatter(rise_idx_down, Fiber_down_saved(rise_idx_down))

