% Button pushed function: CalibrateButton
function CalibrateButtonPushed(app, ~)

    % come out of function if app has been deleted
    if ~isvalid(app)
        return
    end

    calibration_confirm = Confirm_screen_inserting(app);

    if calibration_confirm
        disp('Calibration going ahead')
    else 
        return
    end

    app.SaveTextArea.Visible = 'on';
    app.SaveTextArea.Value = {'' ; 'Beginning Calibration ... ' ; ''};
    disp('Beginning Calibration')


    screen_names = [215, 235, 390, 540, 620, 730, 810]; % nb that 540 is controlled with CAS.BTV0420, and screen 235 is actually controlled by CA.BTV0125
    BTV = {'CA.BTV0215', 'CA.BTV0125', 'CA.BTV0390','CAS.BTV0420', 'CA.BTV0620', 'CA.BTV0730','CA.BTV0810'};
    BTV_in = [int32(1), int32(1), int32(2), int32(1), int32(1), int32(1), int32(1)]; %int32(2) looks like "SECOND", int32(1) looks like "FIRST"
    screen_distances = zeros(length(screen_names), 1);
    screen_distances([1,3:7]) = Get_screen_distances(screen_names([1,3:7])); % Screen 540 has distance recorded, but 235 doesn't so what is here is an estimate
    screen_distances(2) = 7.07; % approximate (+- 0.3m) distance to screen 235
    % screen_distances = [20.6 26.04 29.75 32.55]; % would like to call these directly from the lookup table
    rise_indices_up = zeros(1, length(screen_names));
    rise_indices_down = zeros(1, length(screen_names));
    avg_up_data = zeros(length(screen_names), 1000);
    avg_down_data = zeros(length(screen_names), 1000);
    up_data_all = zeros(length(screen_names), 10, 1000);
    down_data_all = zeros(length(screen_names), 10, 1000);


    % Take out all screens beforehand 
    for i = 1:length(screen_names)
        matlabJapc.staticSetSignal('', [BTV{i},'/Setting#screenSelect'],int32(0)); % Sets screen out to ZERO
    end

    pause(2)

    % put in screen 540 and autoset the oscilloscope to this data
    % (540 gives the largest signal from previous measurements)

    app.SaveTextArea.Value = {''; 'Placing in screen 540 for autosetting oscilloscope'; '';};
    matlabJapc.staticSetSignal('', ['CAS.BTV0420','/Setting#screenSelect'],int32(1)); % Puts in 540 screen
    pause(2)          
    app.SaveTextArea.Value = {''; 'Autosetting upstream oscilloscope ';};                
    Autoset_oscilloscope('CA.SCOPE10.CH01') % Autoset the downstream scope signal
    app.SaveTextArea.Value = {''; 'Autosetting downstream oscilloscope ';};                
    Autoset_oscilloscope('CA.SCOPE10.CH02') % Autoset the upstream scope signal
    pause(2)
    matlabJapc.staticSetSignal('', ['CAS.BTV0420','/Setting#screenSelect'],int32(0)); % Takes out 540 screen

    for i = 1:length(screen_names)
        app.SaveTextArea.Value = {''; ['Placing in screen ' num2str(screen_names(i))]; '';};
        matlabJapc.staticSetSignal('', [BTV{i},'/Setting#screenSelect'],BTV_in(i)); % Puts in screen
        pause(3)

        app.SaveTextArea.Value = {''; ['Acquiring calibration data for screen ' num2str(screen_names(i))]; '';};                
        figs_signal = figure(i);
        figs_signal.Position = [i*310 100 300 300];
        [avg_up_data(i, :), avg_down_data(i, :), up_data_all(i, :, :), down_data_all(i, :, :)] = Acquire_averaged_data(app);

        % Find the rise time and plot on the figure
        rise_indices_up(i) = Find_rise_time_CFD(avg_up_data(i,:)) ;
        rise_indices_down(i) = Find_rise_time_CFD(avg_down_data(i,:)) ;
        scatter(rise_indices_up(i), avg_up_data(i, rise_indices_up(i)))
        scatter(rise_indices_down(i), avg_down_data(i, rise_indices_down(i)))

        app.SaveTextArea.Value = {''; ['Taking out screen ' num2str(screen_names(i))]; '';};
        matlabJapc.staticSetSignal('', [BTV{i},'/Setting#screenSelect'],int32(0)); % Sets screen out to ZERO
        pause(3)

        % check if screen is out before continuing - will have to
        % see because can't use continue here I don't think
        savefig(figs_signal, ['Calibration saved data/BLM_GUI_screen_', num2str(screen_names(i)), '_calibration_data_', char(datetime('now', 'Format', 'ddMMyyyy-HH:mm:ss')), '.fig'])     


    end


    % Find and plot the reconstructed positions against the real
    % positions of the screens
    app.SaveTextArea.Value = {''; 'Reconstructing positions ... ' ; '';};


    reconstructed_positions = Find_fiber_loss_dist_combined_readout_eff_refr_idx(rise_indices_up, rise_indices_down);

    fig_fitting = figure(5);
    fig_fitting.Position = [1800 500 500 500];

    plot(screen_distances, reconstructed_positions, '.', 'MarkerSize', 20)
    title("Reconstructed positions against known BTV screen distances")
    subtitle("Constant Fraction Discriminator (CFD) method")
    xlabel("BTV screen distances (m)")
    ylabel("Reconstructed screen positions (m)")
    text(screen_distances, reconstructed_positions, sprintfc('  %d', screen_names))
    hold on            


    % fit with straight line
    fit = polyfit(screen_distances, reconstructed_positions, 1);
    m = fit(1); % fitting gradient
    c = fit(2); % fitting offset

    % plot straight line
    screen_distances_plot = [screen_distances(1),screen_distances(end)];
    expected_screen_distances =  m * screen_distances_plot + c;

    plot(screen_distances_plot, expected_screen_distances, 'LineWidth', 2)
    text(screen_distances_plot(1) + 5, expected_screen_distances(1) + 1, [' Fit: y = ' num2str(m) 'x + ' num2str(c)])

    distances_rms = m * screen_distances + c;
    rms = rmse(distances_rms, reconstructed_positions); % find root mean squared error between the predicted rise indices and the observed rise indices
    text(screen_distances_plot(1) + 5, expected_screen_distances(1) + 0.75, ['RMS value = ' num2str(rms)])


    % Save all the calibration data and plot
    all_data = table(up_data_all, down_data_all);
    avg_data = table(avg_up_data, avg_down_data);
    writetable(all_data, ['Calibration saved data/BLM_GUI_calibration_all_data_', char(datetime('now', 'Format', 'ddMMyyyy-HH:mm:ss')), '.txt']);
    writetable(avg_data, ['Calibration saved data/BLM_GUI_calibration_averaged_data_', char(datetime('now', 'Format', 'ddMMyyyy-HH:mm:ss')), '.txt']);            
    savefig(fig_fitting, ['Calibration saved data/BLM_GUI_calibration_fit_', char(datetime('now', 'Format', 'ddMMyyyy-HH:mm:ss')), '.fig'])                 

    disp(' ')
    disp('Calibration data saved.');
    app.SaveTextArea.Visible = 'on';            
    app.SaveTextArea.Value = {'' ; 'Calibration data saved.' ; ''};
    pause(1)

    % m = 1.1587; Old calibration parameters
    % c = -15.4938;

    % Check whether user would like to use the new calibration
    % parameters or not
    use_calibration_params = Confirm_use_new_calibration_params(app);
    if use_calibration_params
        save('Calibration saved data/Saved_calibration_params.mat', 'm', 'c')
        app.gradient = m;
        app.offset = c;
        disp('New calibration paramaters saved')
    else
        disp('Keeping old calibration parameters')
    end

    app.SaveTextArea.Visible = 'off';
    close all


end
