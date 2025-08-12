classdef BLM_GUI_APP < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure   
        CalibrateButton                 matlab.ui.control.Button        
        MeasurementLabel                 matlab.ui.control.Label
        UpstreamSensibilityButtonGroup  matlab.ui.container.ButtonGroup
        AutosetButton_2                 matlab.ui.control.ToggleButton
        mVdivButton_14                  matlab.ui.control.ToggleButton
        mVdivButton_13                  matlab.ui.control.ToggleButton
        mVdivButton_12                  matlab.ui.control.ToggleButton
        mVdivButton_11                  matlab.ui.control.ToggleButton
        mVdivButton_10                  matlab.ui.control.ToggleButton
        mVdivButton_9                   matlab.ui.control.ToggleButton
        mVdivButton_8                   matlab.ui.control.ToggleButton
        ResetScopeButton                matlab.ui.control.Button
        LightModeButton                 matlab.ui.control.Button
        SetOscilloscopeSensibilityLabel  matlab.ui.control.Label
        DownstreamSensibilityButtonGroup  matlab.ui.container.ButtonGroup
        AutosetButton                   matlab.ui.control.ToggleButton
        mVdivButton_7                   matlab.ui.control.ToggleButton
        mVdivButton_6                   matlab.ui.control.ToggleButton
        mVdivButton_5                   matlab.ui.control.ToggleButton
        mVdivButton_4                   matlab.ui.control.ToggleButton
        mVdivButton_3                   matlab.ui.control.ToggleButton
        mVdivButton_2                   matlab.ui.control.ToggleButton
        mVdivButton                     matlab.ui.control.ToggleButton
        DistanceTextArea_2              matlab.ui.control.TextArea
        SaveTextArea                    matlab.ui.control.TextArea
        DistanceTextArea                matlab.ui.control.TextArea
        OnOffRockerSwitch               matlab.ui.control.RockerSwitch
        SavePlotsButton                 matlab.ui.control.Button
        ForceQuitButton                 matlab.ui.control.Button
        PositionPlotAxesPart1           matlab.ui.control.UIAxes
        PositionPlotAxesPart2           matlab.ui.control.UIAxes
        CLEARBeamlineAxesPart1          matlab.ui.control.UIAxes
        CLEARBeamlineAxesPart2          matlab.ui.control.UIAxes
        LegendAxes                      matlab.ui.control.UIAxes
        UIAxes1                         matlab.ui.control.UIAxes
        UIAxes2                         matlab.ui.control.UIAxes
        UIAxes3                         matlab.ui.control.UIAxes
        UIAxes4                         matlab.ui.control.UIAxes

    end 

    % Properties that correspond to app function
    properties (Access = public)

        % Operation parameters
        idx_meas = 1 % current measurement index
        nb_meas = 100000 % total number of measurements to take 
        time_pts = 1000 % number of time points per measurement (each point every 1ns)
        decimation_factor = 10 % decimate the data for faster running by this factor
        total_time

        % Hardware control
        monitorMTV % Oscilloscope monitor

        % App closing and plotting on and off
        stop_request = false % stop_request becomes true when OnOffRockerSwitch switches to "Stop" 

        % Images 
        image1 % CLEAR Beamline part 1
        image2 % CLEAR Beamline part 2
        image3 % LEGEND
        dark_light_mode = 'dark'
        plot_rise_index_colour = 'cyan'
        plot_beam_loss_colour = [0 1 1 0.5]

        % Calibration properties (used in Convert_fiber_to_beam_dist)
        gradient
        offset


    end
    


    % Callbacks that handle component events
    methods (Access = private)

        function Plot_signal_beam_loss(app)
            % Main app function which calls Acquire_smoothed_signal and plots the upstream and downstream
            % signals. Calls Find_rise_time_CFD.m to find the points of rise
            % in both waveforms using the constant fraction descriminator
            % approach. Calculates the distance of loss down the beam by
            % calling Find_fiber_loss_dist_combined_readout.m then
            % Convert_fiber_to_beam_dist.m. Plots the indication of this
            % disteance on the CLEAR Beamline maps. 

            % come out of function if app has been deleted
            if ~isvalid(app)
                return
            end

            % also come out of the function if the stop_request has been
            % satisfied
            if app.stop_request
                return
            end
             
            [Gun_charge, ~, THz_charge, THz2_charge] = Read_BCM; % Read_BCM gets the charge at the gun, THz and THz2. 

            total_beam_length = 36.38;
            % refr_idx = 1.465;
            
            app.total_time = matlabJapc.staticGetSignal('SCT.USER.SETUP','CA.SCOPE10/TimeBase#value') * 1e9 ; % gets the total time in ns from the left of the OASIS viewer to the right side (e.g. set by 100ns/div x 10 = 1000ns = 1us)

            if strcmpi(app.OnOffRockerSwitch.Value,'Start') && app.idx_meas <= app.nb_meas && mod(app.idx_meas, 1) == 0

                display(['Meas: ', num2str(app.idx_meas), ' Charge Gun: ', num2str(round(Gun_charge,3)),' Charge THz: ', num2str(round(THz_charge,3)),' Charge THz2: ', num2str(round(THz2_charge,3))])
                % disp(['Meas: ' num2str(app.idx_meas)])
  
                time_plot = linspace(0, app.total_time, app.time_pts); % time points for plotting, determined by the total time shown and the amount of time points we take.
                % for faster plotting, can use a lower app.time_pts

                gun = round(Gun_charge,3);
                THz = round(THz_charge,3) * 1000;
                THz2 = round(THz2_charge,3) * 1000;
                THz_percent = THz/(gun * 10)  ;
                THz2_percent = THz2/(gun * 10) ;

                app.MeasurementLabel.Text = sprintf('Measurement number: %s \nCharge at Gun: %s nC \nCharge at THz: %s pC (%0.2s %%)\nCharge at THz2: %s pC (%0.2s %%)', num2str(app.idx_meas), num2str(gun), num2str(THz), num2str(THz_percent), num2str(THz2), num2str(THz2_percent));
                % app.MeasurementLabel.Text = {'Measurement number: ', num2str(app.idx_meas) 'Charge at Gun (A): ', num2str(round(Gun_charge,3)), 'Charge at THz (A): ', num2str(round(THz_charge,3)), 'Charge at THz2 (A): ', num2str(round(THz2_charge,3)), 'Beam loss (%): ', num2str(100 - round(THz_charge,3)/round(Gun_charge,3) * 100)};                        

                [up_data, down_data, smooth_up_data, smooth_down_data] = Acquire_smoothed_signal(app); % acquire upstream and downstream signal and averaged signal
                % [up_data, down_data, smooth_up_data, smooth_down_data] = Acquire_saved_signal("22072025-16:38:18") ; % acquires dry run saved data for given screen number
                % [up_data, down_data, smooth_up_data, smooth_down_data] = Acquire_screen_saved_signal(27072025, 215); 


                loss_idx_up = Find_rise_time_CFD(smooth_up_data);
                loss_idx_down = Find_rise_time_CFD(smooth_down_data);

                % Find the distance along the beamline where the
                % signal is lost (first)
                fiber_loss_dist = Find_fiber_loss_dist_combined_readout_eff_refr_idx(loss_idx_up, loss_idx_down);
                beam_loss_dist = Convert_fiber_to_beam_dist(app, fiber_loss_dist);

                % reducing plot complexity and increase speed
                set(app.UIAxes1, 'NextPlot', 'replacechildren')


                % plot downstream signal and beam loss points
                plot(app.UIAxes1,down_data,'magenta');
                hold(app.UIAxes1, 'on')

                % plot upstream signal and beam loss points
                plot(app.UIAxes2,up_data,'g');
                hold(app.UIAxes2, 'on')

                % plot downstream signal and beam loss points
                plot(app.UIAxes3,smooth_down_data,'magenta');
                hold(app.UIAxes3, 'on')

                % plot upstream signal and beam loss points
                plot(app.UIAxes4,smooth_up_data,'g');
                hold(app.UIAxes4, 'on')

                % plot the beam loss points (only if they are
                % within a physical index range)
                if loss_idx_up > 0 && loss_idx_up <= 1000
                    scatter(app.UIAxes2,loss_idx_up,up_data(loss_idx_up), app.plot_rise_index_colour,'filled')
                    scatter(app.UIAxes4,loss_idx_up,smooth_up_data(loss_idx_up), app.plot_rise_index_colour,'filled')
                end

                if loss_idx_down > 0 && loss_idx_down <= 1000
                    scatter(app.UIAxes1,loss_idx_down,down_data(loss_idx_down),app.plot_rise_index_colour,'filled')
                    scatter(app.UIAxes3,loss_idx_down,smooth_down_data(loss_idx_down),app.plot_rise_index_colour,'filled')
                end

                hold(app.UIAxes1, 'off')
                hold(app.UIAxes2, 'off')
                hold(app.UIAxes3, 'off')
                hold(app.UIAxes4, 'off')


                % plot(app.UIAxes,[beam_loss_pix,beam_loss_pix],[-0.25,1],'LineWidth',3,"Color",[1 0 1])
                hold(app.PositionPlotAxesPart1, 'off')
                hold(app.PositionPlotAxesPart2, 'off')

                if 0 <= beam_loss_dist && beam_loss_dist < 21.48
                    % Convert this distance into pixels
                    beam_loss_pix = Distance_to_pixels(beam_loss_dist);
                    % plot the line of beam loss point for the first part of the beamline.
                    cla(app.PositionPlotAxesPart2)
                    % plot(app.UIAxes,[beam_loss_pix,beam_loss_pix],[-0.95,1],'LineWidth',3,"Color",[1 0 1 0.5])
                    plot(app.PositionPlotAxesPart1,[beam_loss_pix,beam_loss_pix],[-1,1],'LineWidth',10,"Color",app.plot_beam_loss_colour)                          
                elseif beam_loss_dist >= 21.48 && beam_loss_dist <= 22.5 
                    % Convert this distance into pixels
                    beam_loss_pix = Distance_to_pixels(beam_loss_dist);                    
                    % plot the line of beam loss point for the second part of the beamline.
                    cla(app.PositionPlotAxesPart1)
                    cla(app.PositionPlotAxesPart2)
                    plot(app.PositionPlotAxesPart1,[beam_loss_pix(1),beam_loss_pix(1)],[-1,1],'LineWidth',10,"Color",app.plot_beam_loss_colour)
                    plot(app.PositionPlotAxesPart2,[beam_loss_pix(2),beam_loss_pix(2)],[-1,1],'LineWidth',10,"Color",app.plot_beam_loss_colour)
                elseif beam_loss_dist < total_beam_length
                    % Convert this distance into pixels
                    beam_loss_pix = Distance_to_pixels(beam_loss_dist);                    
                    % plot the line of beam loss point for the second part of the beamline.
                    cla(app.PositionPlotAxesPart1)
                    plot(app.PositionPlotAxesPart2,[beam_loss_pix,beam_loss_pix],[-1,1],'LineWidth',10,"Color",app.plot_beam_loss_colour)     
                else
                    cla(app.PositionPlotAxesPart2)
                    cla(app.PositionPlotAxesPart1)
                end

                app.DistanceTextArea_2.Value = sprintf('%0.2f m', beam_loss_dist);
                

            end


            if app.idx_meas > app.nb_meas
                disp('Finished')
                app.idx_meas = app.nb_meas + 10^20;
                app.OnOffRockerSwitch.ValueIndex = 1;
                app.monitorMTV.stop()
            end

            app.idx_meas = app.idx_meas + 1;

        end




        % Code that executes after component creation
        function startupFcn(app)
            % Initialise and preallocate 
            app.OnOffRockerSwitch.Value = 'Stop';       
            app.idx_meas = 1;

            parent_folder = fileparts(cd); % get the parent folder of this script
            addpath(fullfile(parent_folder, 'BLM_Analysis')); % add path with Analysis functions
            addpath(fullfile(parent_folder, 'BLM_GUI_APP')); % add path with GUI app

            % addpath /nfs/cs-ccr-nfs6/vol29/Linux/data/clear/MatLab/Operation/Gun_Energy
            % addpath /nfs/cs-ccr-nfs6/vol29/Linux/data/clear/MatLab/Operation/Gun_Energy

            try
                matlabJapc.staticINCAify('CTF')
            catch
                disp('OK')
            end
       
            % Initialise the OASIS viewer of the oscciloscope signals:

            matlabJapc.staticSetSignal('SCT.USER.SETUP','CA.SCOPE10.CH01/Sensibility#value', 0.05) % sets to 5mV/div view
            matlabJapc.staticSetSignal('SCT.USER.SETUP','CA.SCOPE10.CH02/Sensibility#value', 0.05) % sets to 5mV/div view
            
            % Start monitoring the triggering of the scope. This will
            % callbak to the plotting function and will be started and
            % stopped by the rocker switch.

            % app.monitorMTV = matlabJapcMonitor('SCT.USER.SETUP',{['CA.SCOPE10.CH02','/Acquisition']}, @(data)Plot_signal_beam_loss(app)); % create monitorMTV object with callback to the plotting function (doesn't start plotting yet)
            app.monitorMTV = matlabJapcMonitor('SCT.USER.SETUP',{['CX.SMEAS-BPMP','/Acquisition']}, @(data)Plot_signal_beam_loss(app)); % create monitorMTV object with callback to the plotting function (doesn't start plotting yet)
            
            % Set the gradient and offset (used in the
            % Convert_fiber_to_beam_dist.m function) to the last saved
            % parameters from Saved_calibration_params.mat
            app.gradient = load('Calibration saved data/Saved_calibration_params.mat', 'm').m;
            app.offset = load('Calibration saved data/Saved_calibration_params.mat', 'c').c;


        end


        % Value changed function: OnOffRockerSwitch
        function OnOffRockerSwitchValueChanged(app, ~)
            
            try 
                value = app.OnOffRockerSwitch.Value;
    
                if strcmpi(value, 'Start')
                    
                    disp(' ')
                    disp('Starting')
                    app.stop_request = false;

                    % Everytime new data arrives to matlabJapcMonitor, the
                    % callback Plot_signal_beam_loss is called. So plotting
                    % will run continuosly for as long as the monitor is
                    % active:

                    matlabJapc.staticSetSignal('','CX.SMEAS-BPMP/OutEnable#outEnabled', 1)
                    app.monitorMTV.start();
                    % matlabJapcMonitor('SCT.USER.SETUP',{['CA.SCOPE10.CH02','/Acquisition']}, @(data)Plot_signal_beam_loss(app)).start(); % create monitorMTV object with callback to the plotting function (doesn't start plotting yet)
            

                elseif strcmpi(value, 'Stop')                    

                    disp(' ')
                    disp('Stopping')
                    app.monitorMTV.stop() ;
                    app.stop_request = true;                    

                end

            catch ME
                disp('Error in rocker switch callback: ');
                disp(ME.message)
            end

            
        end


        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            
            disp(' ')
            disp('Closing')
            close all

            app.stop_request = true;
            app.OnOffRockerSwitch.Value = 'Stop';            
            app.monitorMTV.stop()
            delete(app.UIFigure)
            disp('Closed')
           
        end


        % Button pushed function: ForceQuitButton
        function ForceQuitButtonPushed(app, event)
           
            disp(' ')
            disp('Force Closing')
            close all
            
            try
                app.stop_request = true;
                app.OnOffRockerSwitch.Value = 'Stop';            
                app.monitorMTV.stop()
            catch
            end
            
            delete(app)
            disp('Force Closed')
            
        end

        % Button pushed function: SavePlotsButton
        function SavePlotsButtonPushed(app, event)
            % Function saves the upstream and downstream raw and smoothed
            % data to a txt file. Also saves a screenshot of the position
            % along the beamline where loss occured. 
            [up_data, down_data, smooth_up_data, smooth_down_data] = Acquire_smoothed_signal(app);
            T = table(up_data, down_data, smooth_up_data, smooth_down_data);
            parent_folder = fileparts(cd); % get the parent folder of this script
            writetable(T, [parent_folder, '/BLM_Analysis/Raw BLM data/BLM_GUI_data_', char(datetime('now', 'Format', 'ddMMyyyy-HH:mm:ss')), '.txt']);
            exportapp(app.UIFigure, [parent_folder, '/BLM_Analysis/Raw BLM data/BLM_GUI_data_', char(datetime('now', 'Format', 'ddMMyyyy-HH:mm:ss')),'.jpg']);
            disp(' ')
            disp('BLM data saved.');
            app.SaveTextArea.Visible = 'on';            
            app.SaveTextArea.Value = {'' ; 'Plots Saved.' ; ''};
            pause(1)
            app.SaveTextArea.Visible = 'off';
        end



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

            % m = 1.1587;
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


        % Selection changed function: UpstreamSensibilityButtonGroup
        function UpstreamSensibilityChanged(app, event)
            selectedButton = app.UpstreamSensibilityButtonGroup.SelectedObject.Text;

            if strcmp(selectedButton, 'Auto set') % if Autoset is clicked
                Autoset_oscilloscope('CA.SCOPE10.CH01') % Autoset function for channel 1
            else
                selectedButton(end-5:end) = [];
                sensibility = str2double(selectedButton)*0.01;
                matlabJapc.staticSetSignal('SCT.USER.SETUP','CA.SCOPE10.CH01/Sensibility#value', sensibility)           
            end
        
        end



        % Selection changed function: DownstreamSensibilityButtonGroup
        function DownstreamSensibilityChanged(app, event)
            selectedButton = app.DownstreamSensibilityButtonGroup.SelectedObject.Text;
            if strcmp(selectedButton, 'Auto set') % if Autoset is clicked
                Autoset_oscilloscope('CA.SCOPE10.CH02') % Autoset function for channel 2
            else
                selectedButton(end-5:end) = [];
                sensibility = str2double(selectedButton)*0.01;
                matlabJapc.staticSetSignal('SCT.USER.SETUP','CA.SCOPE10.CH02/Sensibility#value', sensibility)           
            end

        end


        % Button pushed function: ResetScopeButton
        function ResetScopeButtonPressed(~, ~)
            
            disp(' ')
            disp('Resetting scope')
            matlabJapc.staticSetSignal('','CX.SMEAS-BPMP/OutEnable#outEnabled', 0)
            pause(2)
            matlabJapc.staticSetSignal('','CX.SMEAS-BPMP/OutEnable#outEnabled', 1)
            waitfor(matlabJapc.staticGetSignal('','CX.SMEAS-BPMP/OutEnable#outEnabled'))
            disp('Scope turned off and on')
        end

 

    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.149 0.149 0.149];
            app.UIFigure.Position = [1000 100 800 1050];            
            app.UIFigure.Name = 'Beam Loss Monitor GUI';
            app.UIFigure.Resize = 'Off';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create UIAxes4
            app.UIAxes4 = uiaxes(app.UIFigure);
            title(app.UIAxes4, 'Smoothed Upstream Signal')
            app.UIAxes4.Title.Color = [1 1 1];
            xlabel(app.UIAxes4, 'Index')
            ylabel(app.UIAxes4, 'Signal (V)')
            app.UIAxes4.XColor = [1 1 1];
            app.UIAxes4.YColor = [1 1 1];
            app.UIAxes4.Color = [0 0 0];
            app.UIAxes4.FontSize = 10;
            app.UIAxes4.Position = [250 15 220 190];

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.UIFigure);
            title(app.UIAxes3, 'Smoothed Downstream Signal')
            app.UIAxes3.Title.Color = [1 1 1];            
            xlabel(app.UIAxes3, 'Index')
            ylabel(app.UIAxes3, 'Signal (V)')
            app.UIAxes3.XColor = [1 1 1];
            app.UIAxes3.YColor = [1 1 1];
            app.UIAxes3.Color = [0 0 0];
            app.UIAxes3.FontSize = 10;
            app.UIAxes3.Position = [15 15 220 190];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.UIFigure);
            title(app.UIAxes2, 'Raw Upstream Signal')
            app.UIAxes2.Title.Color = [1 1 1];            
            xlabel(app.UIAxes2, 'Index')
            ylabel(app.UIAxes2, 'Signal (V)')
            app.UIAxes2.XColor = [1 1 1];
            app.UIAxes2.YColor = [1 1 1];
            app.UIAxes2.Color = [0 0 0];
            app.UIAxes2.FontSize = 10;
            app.UIAxes2.Position = [250 210 220 190];

            % Create UIAxes1
            app.UIAxes1 = uiaxes(app.UIFigure);
            title(app.UIAxes1, 'Raw Downstream Signal')
            app.UIAxes1.Title.Color = [1 1 1];            
            xlabel(app.UIAxes1, 'Index')
            ylabel(app.UIAxes1, 'Signal (V)')
            app.UIAxes1.XColor = [1 1 1];
            app.UIAxes1.YColor = [1 1 1];
            app.UIAxes1.Color = [0 0 0];
            app.UIAxes1.FontSize = 10;
            app.UIAxes1.Position = [15 210 220 190];

            % Create LegendAxes
            app.LegendAxes = uiaxes(app.UIFigure);
            title(app.LegendAxes, 'Legend')
            app.LegendAxes.Title.Color = [1 1 1];              
            app.LegendAxes.XColor = 'none';
            app.LegendAxes.XTick = [];
            app.LegendAxes.YColor = 'none';
            app.LegendAxes.YTick = [];
            app.LegendAxes.ZColor = 'none';
            app.LegendAxes.Color = 'none';
            app.LegendAxes.FontSize = 14;
            app.LegendAxes.Position = [15 410 455 95];

            % Create CLEARBeamlineAxesPart2
            app.CLEARBeamlineAxesPart2 = uiaxes(app.UIFigure);
            title(app.CLEARBeamlineAxesPart2, 'CLEAR Beamline Part 2')
            app.CLEARBeamlineAxesPart2.Title.Color = [1 1 1];              
            app.CLEARBeamlineAxesPart2.FontWeight = 'bold';        
            app.CLEARBeamlineAxesPart2.XColor = 'none';
            app.CLEARBeamlineAxesPart2.XTick = [];
            app.CLEARBeamlineAxesPart2.YColor = 'none';
            app.CLEARBeamlineAxesPart2.YTick = [];
            app.CLEARBeamlineAxesPart2.ZColor = 'none';
            app.CLEARBeamlineAxesPart2.Color = 'none';
            app.CLEARBeamlineAxesPart2.GridColor = 'none';
            app.CLEARBeamlineAxesPart2.MinorGridColor = 'none';
            app.CLEARBeamlineAxesPart2.FontSize = 16;
            app.CLEARBeamlineAxesPart2.Position = [15 510 770 250];
            

            % Create CLEARBeamlineAxesPart1
            app.CLEARBeamlineAxesPart1 = uiaxes(app.UIFigure);
            title(app.CLEARBeamlineAxesPart1, 'CLEAR Beamline Part 1')
            app.CLEARBeamlineAxesPart1.Title.Color = [1 1 1];              
            app.CLEARBeamlineAxesPart1.FontWeight = 'bold';           
            app.CLEARBeamlineAxesPart1.XColor = 'none';
            % app.CLEARBeamlineAxesPart1.XColor = [1 1 1];
            % app.CLEARBeamlineAxesPart1.YColor = [1 1 1];
            app.CLEARBeamlineAxesPart1.XTick = [];
            app.CLEARBeamlineAxesPart1.YColor = 'none';
            app.CLEARBeamlineAxesPart1.YTick = [];
            app.CLEARBeamlineAxesPart1.ZColor = 'none';
            app.CLEARBeamlineAxesPart1.Color = 'none';
            % app.CLEARBeamlineAxesPart1.Color = [1 1 1];
            app.CLEARBeamlineAxesPart1.MinorGridColor = 'none';
            app.CLEARBeamlineAxesPart1.FontSize = 16;
            app.CLEARBeamlineAxesPart1.Position = [15 755 770 280];

            % Load in images into CLEARBeamlineAxesPart1 and 2
            app.image1 = imread('Images/CLEAR_Beamline_Dark_1.png');
            app.image2 = imread('Images/CLEAR_Beamline_Dark_2.png');
            app.image3 = imread('Images/CLEAR_Legend_Dark.png');            
            imshow(app.image1,'Parent',app.CLEARBeamlineAxesPart1, 'Interpolation','bilinear'); 
            imshow(app.image2,'Parent',app.CLEARBeamlineAxesPart2, 'Interpolation','bilinear'); 
            imshow(app.image3,'Parent',app.LegendAxes, 'Interpolation','bilinear');             
            app.CLEARBeamlineAxesPart1.XLim = [0 width(app.image1)];
            app.CLEARBeamlineAxesPart2.XLim = [0 width(app.image2)];
            app.LegendAxes.XLim = [0 width(app.image3)];

            % Create PositionPlotAxesPart2
            app.PositionPlotAxesPart2 = uiaxes(app.UIFigure);
            app.PositionPlotAxesPart2.FontWeight = 'bold';
            app.PositionPlotAxesPart2.XLim = [0 width(app.image2)];
            app.PositionPlotAxesPart2.YLim = [0 1];
            app.PositionPlotAxesPart2.XColor = 'none';
            app.PositionPlotAxesPart2.XTick = [];
            app.PositionPlotAxesPart2.YColor = 'none';
            app.PositionPlotAxesPart2.YTick = [];
            app.PositionPlotAxesPart2.ZColor = 'none';
            app.PositionPlotAxesPart2.Color = 'none';
            app.PositionPlotAxesPart2.GridColor = 'none';
            app.PositionPlotAxesPart2.MinorGridColor = 'none';
            app.PositionPlotAxesPart2.FontSize = 16;
            app.PositionPlotAxesPart2.Position = [15 528 770 218];

            % Create PositionPlotAxesPart1
            app.PositionPlotAxesPart1 = uiaxes(app.UIFigure);
            app.PositionPlotAxesPart1.XLim = [0 width(app.image1)];
            app.PositionPlotAxesPart1.YLim = [0 1];            
            app.PositionPlotAxesPart1.XColor = 'none';
            app.PositionPlotAxesPart1.XTick = [];
            app.PositionPlotAxesPart1.YColor = 'none';
            app.PositionPlotAxesPart1.YTick = [];
            app.PositionPlotAxesPart1.ZColor = 'none';
            app.PositionPlotAxesPart1.Color = 'none';
            app.PositionPlotAxesPart1.MinorGridColor = 'none';
            app.PositionPlotAxesPart1.FontSize = 16;
            app.PositionPlotAxesPart1.Position = [15 770 770 245];


            % Create SavePlotsButton
            app.SavePlotsButton = uibutton(app.UIFigure, 'push');
            app.SavePlotsButton.ButtonPushedFcn = createCallbackFcn(app, @SavePlotsButtonPushed, true);
            app.SavePlotsButton.WordWrap = 'on';
            app.SavePlotsButton.BackgroundColor = [0.4667 0.6745 0.1882];
            app.SavePlotsButton.FontSize = 16;
            app.SavePlotsButton.FontWeight = 'bold';
            app.SavePlotsButton.FontColor = [1 1 1];
            app.SavePlotsButton.Position = [700 265 85 60];
            app.SavePlotsButton.Text = 'Save Plots';


            % Create DistanceTextArea
            app.DistanceTextArea = uitextarea(app.UIFigure);
            app.DistanceTextArea.Editable = 'off';
            app.DistanceTextArea.HorizontalAlignment = 'center';
            app.DistanceTextArea.FontSize = 20;
            app.DistanceTextArea.FontWeight = 'bold';
            app.DistanceTextArea.FontColor = [1 1 1];
            app.DistanceTextArea.BackgroundColor = [0.149 0.149 0.149];
            app.DistanceTextArea.Position = [488 405 297 32];
            app.DistanceTextArea.Value = {'Distance to beam loss:'};

            % Create DistanceTextArea_2
            app.DistanceTextArea_2 = uitextarea(app.UIFigure);
            app.DistanceTextArea_2.Editable = 'off';
            app.DistanceTextArea_2.HorizontalAlignment = 'center';
            app.DistanceTextArea_2.FontSize = 40;
            app.DistanceTextArea_2.FontColor = [1 1 1];
            app.DistanceTextArea_2.BackgroundColor = [0 0 0];
            app.DistanceTextArea_2.Position = [488 342 298 55];
            app.DistanceTextArea_2.Value = {'0'};

            % Create DownstreamSensibilityButtonGroup
            app.DownstreamSensibilityButtonGroup = uibuttongroup(app.UIFigure);
            app.DownstreamSensibilityButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @DownstreamSensibilityChanged, true);
            app.DownstreamSensibilityButtonGroup.ForegroundColor = [1 1 1];
            app.DownstreamSensibilityButtonGroup.TitlePosition = 'centertop';
            app.DownstreamSensibilityButtonGroup.Title = 'Downstream';
            app.DownstreamSensibilityButtonGroup.BackgroundColor = [0.149 0.149 0.149];
            app.DownstreamSensibilityButtonGroup.Position = [485 15 100 210];

            % Create mVdivButton
            app.mVdivButton = uitogglebutton(app.DownstreamSensibilityButtonGroup);
            app.mVdivButton.Text = '5mV/div';
            app.mVdivButton.BackgroundColor = [0.149 0.149 0.149];
            app.mVdivButton.FontColor = [1 1 1];
            app.mVdivButton.Position = [10 160 80 20];
            app.mVdivButton.Value = true;

            % Create mVdivButton_2
            app.mVdivButton_2 = uitogglebutton(app.DownstreamSensibilityButtonGroup);
            app.mVdivButton_2.Text = '10mV/div';
            app.mVdivButton_2.BackgroundColor = [0.149 0.149 0.149];
            app.mVdivButton_2.FontColor = [1 1 1];
            app.mVdivButton_2.Position = [10 140 80 20];

            % Create mVdivButton_3
            app.mVdivButton_3 = uitogglebutton(app.DownstreamSensibilityButtonGroup);
            app.mVdivButton_3.Text = '20mV/div';
            app.mVdivButton_3.BackgroundColor = [0.149 0.149 0.149];
            app.mVdivButton_3.FontColor = [1 1 1];
            app.mVdivButton_3.Position = [10 120 80 20];

            % Create mVdivButton_4
            app.mVdivButton_4 = uitogglebutton(app.DownstreamSensibilityButtonGroup);
            app.mVdivButton_4.Text = '50mV/div';
            app.mVdivButton_4.BackgroundColor = [0.149 0.149 0.149];
            app.mVdivButton_4.FontColor = [1 1 1];
            app.mVdivButton_4.Position = [10 100 80 20];

            % Create mVdivButton_5
            app.mVdivButton_5 = uitogglebutton(app.DownstreamSensibilityButtonGroup);
            app.mVdivButton_5.Text = '100mV/div';
            app.mVdivButton_5.BackgroundColor = [0.149 0.149 0.149];
            app.mVdivButton_5.FontColor = [1 1 1];
            app.mVdivButton_5.Position = [10 80 80 20];

            % Create mVdivButton_6
            app.mVdivButton_6 = uitogglebutton(app.DownstreamSensibilityButtonGroup);
            app.mVdivButton_6.Text = '200mV/div';
            app.mVdivButton_6.BackgroundColor = [0.149 0.149 0.149];
            app.mVdivButton_6.FontColor = [1 1 1];
            app.mVdivButton_6.Position = [10 60 80 20];

            % Create mVdivButton_7
            app.mVdivButton_7 = uitogglebutton(app.DownstreamSensibilityButtonGroup);
            app.mVdivButton_7.Text = '500mV/div';
            app.mVdivButton_7.BackgroundColor = [0.149 0.149 0.149];
            app.mVdivButton_7.FontColor = [1 1 1];
            app.mVdivButton_7.Position = [10 40 80 20];

            % Create AutosetButton
            app.AutosetButton = uitogglebutton(app.DownstreamSensibilityButtonGroup);
            app.AutosetButton.Text = 'Auto set';
            app.AutosetButton.BackgroundColor = [0.149 0.149 0.149];
            app.AutosetButton.FontColor = [1 1 1];
            app.AutosetButton.Position = [10 10 80 30];

            % Create SetOscilloscopeSensibilityLabel
            app.SetOscilloscopeSensibilityLabel = uilabel(app.UIFigure);
            app.SetOscilloscopeSensibilityLabel.FontWeight = 'bold';
            app.SetOscilloscopeSensibilityLabel.FontColor = [1 1 1];
            app.SetOscilloscopeSensibilityLabel.Position = [503 226 165 22];
            app.SetOscilloscopeSensibilityLabel.Text = 'Set Oscilloscope Sensibility';

            % Create LightModeButton
            app.LightModeButton = uibutton(app.UIFigure, 'push');
            app.LightModeButton.ButtonPushedFcn = createCallbackFcn(app, @DarkLightModePressed, true);
            app.LightModeButton.WordWrap = 'on';
            app.LightModeButton.BackgroundColor = [0.9294 0.6941 0.1255];
            app.LightModeButton.FontSize = 16;
            app.LightModeButton.FontWeight = 'bold';
            app.LightModeButton.FontColor = [0.149 0.149 0.149];
            app.LightModeButton.Position = [700 115 85 60];
            app.LightModeButton.Text = 'Light Mode';

            % Create ResetScopeButton
            app.ResetScopeButton = uibutton(app.UIFigure, 'push');
            app.ResetScopeButton.ButtonPushedFcn = createCallbackFcn(app, @ResetScopeButtonPressed, true);                
            app.ResetScopeButton.WordWrap = 'on';
            app.ResetScopeButton.BackgroundColor = [0.6353 0.0784 0.1843];
            app.ResetScopeButton.FontSize = 16;
            app.ResetScopeButton.FontWeight = 'bold';
            app.ResetScopeButton.FontColor = [1 1 1];
            app.ResetScopeButton.Position = [700 190 85 60];
            app.ResetScopeButton.Text = 'Reset Scope';

            % Create UpstreamSensibilityButtonGroup
            app.UpstreamSensibilityButtonGroup = uibuttongroup(app.UIFigure);
            app.UpstreamSensibilityButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @UpstreamSensibilityChanged, true);            
            app.UpstreamSensibilityButtonGroup.ForegroundColor = [1 1 1];
            app.UpstreamSensibilityButtonGroup.TitlePosition = 'centertop';
            app.UpstreamSensibilityButtonGroup.Title = 'Upstream';
            app.UpstreamSensibilityButtonGroup.BackgroundColor = [0.149 0.149 0.149];
            app.UpstreamSensibilityButtonGroup.Position = [585 15 100 210];

            % Create mVdivButton_8
            app.mVdivButton_8 = uitogglebutton(app.UpstreamSensibilityButtonGroup);
            app.mVdivButton_8.Text = '5mV/div';
            app.mVdivButton_8.BackgroundColor = [0.149 0.149 0.149];
            app.mVdivButton_8.FontColor = [1 1 1];
            app.mVdivButton_8.Position = [11 160 80 20];
            app.mVdivButton_8.Value = true;

            % Create mVdivButton_9
            app.mVdivButton_9 = uitogglebutton(app.UpstreamSensibilityButtonGroup);
            app.mVdivButton_9.Text = '10mV/div';
            app.mVdivButton_9.BackgroundColor = [0.149 0.149 0.149];
            app.mVdivButton_9.FontColor = [1 1 1];
            app.mVdivButton_9.Position = [11 140 80 20];

            % Create mVdivButton_10
            app.mVdivButton_10 = uitogglebutton(app.UpstreamSensibilityButtonGroup);
            app.mVdivButton_10.Text = '20mV/div';
            app.mVdivButton_10.BackgroundColor = [0.149 0.149 0.149];
            app.mVdivButton_10.FontColor = [1 1 1];
            app.mVdivButton_10.Position = [11 120 80 20];

            % Create mVdivButton_11
            app.mVdivButton_11 = uitogglebutton(app.UpstreamSensibilityButtonGroup);
            app.mVdivButton_11.Text = '50mV/div';
            app.mVdivButton_11.BackgroundColor = [0.149 0.149 0.149];
            app.mVdivButton_11.FontColor = [1 1 1];
            app.mVdivButton_11.Position = [11 100 80 20];

            % Create mVdivButton_12
            app.mVdivButton_12 = uitogglebutton(app.UpstreamSensibilityButtonGroup);
            app.mVdivButton_12.Text = '100mV/div';
            app.mVdivButton_12.BackgroundColor = [0.149 0.149 0.149];
            app.mVdivButton_12.FontColor = [1 1 1];
            app.mVdivButton_12.Position = [11 80 80 20];

            % Create mVdivButton_13
            app.mVdivButton_13 = uitogglebutton(app.UpstreamSensibilityButtonGroup);
            app.mVdivButton_13.Text = '200mV/div';
            app.mVdivButton_13.BackgroundColor = [0.149 0.149 0.149];
            app.mVdivButton_13.FontColor = [1 1 1];
            app.mVdivButton_13.Position = [11 60 80 20];

            % Create mVdivButton_14
            app.mVdivButton_14 = uitogglebutton(app.UpstreamSensibilityButtonGroup);
            app.mVdivButton_14.Text = '500mV/div';
            app.mVdivButton_14.BackgroundColor = [0.149 0.149 0.149];
            app.mVdivButton_14.FontColor = [1 1 1];
            app.mVdivButton_14.Position = [11 40 80 20];

            % Create AutosetButton_2
            app.AutosetButton_2 = uitogglebutton(app.UpstreamSensibilityButtonGroup);
            app.AutosetButton_2.Text = 'Auto set';
            app.AutosetButton_2.BackgroundColor = [0.149 0.149 0.149];
            app.AutosetButton_2.FontColor = [1 1 1];
            app.AutosetButton_2.Position = [11 10 80 30];

            % Create CalibrateButton
            app.CalibrateButton = uibutton(app.UIFigure, 'push');
            app.CalibrateButton.ButtonPushedFcn = createCallbackFcn(app, @CalibrateButtonPushed, true);
            app.CalibrateButton.WordWrap = 'on';
            app.CalibrateButton.BackgroundColor = [0.7176 0.2745 1];
            app.CalibrateButton.FontSize = 16;
            app.CalibrateButton.FontWeight = 'bold';
            app.CalibrateButton.Position = [702 450 85 62];
            app.CalibrateButton.Text = 'Calibrate';

            % Create MeasurementLabel
            app.MeasurementLabel = uilabel(app.UIFigure);
            app.MeasurementLabel.FontSize = 14;
            app.MeasurementLabel.FontColor = [1 1 1];
            app.MeasurementLabel.Position = [488 257 197 78];
            app.MeasurementLabel.Text = {'Measurement number: '; 'Charge Gun: '; 'Charge (THz): '; 'Chage (THz2):'};

            % Create OnOffRockerSwitch
            app.OnOffRockerSwitch = uiswitch(app.UIFigure, 'rocker');
            app.OnOffRockerSwitch.Items = {'Stop', 'Start'};
            app.OnOffRockerSwitch.Orientation = 'horizontal';
            app.OnOffRockerSwitch.ValueChangedFcn = createCallbackFcn(app, @OnOffRockerSwitchValueChanged, true);
            app.OnOffRockerSwitch.FontSize = 20;
            app.OnOffRockerSwitch.FontWeight = 'bold';
            app.OnOffRockerSwitch.FontColor = [1 1 1];
            app.OnOffRockerSwitch.Position = [531 457 108 48];
            app.OnOffRockerSwitch.Value = 'Stop';

            % Create SaveTextArea
            app.SaveTextArea = uitextarea(app.UIFigure);
            app.SaveTextArea.Editable = 'off';
            app.SaveTextArea.HorizontalAlignment = 'center';
            app.SaveTextArea.FontSize = 75;
            app.SaveTextArea.FontWeight = 'bold';
            app.SaveTextArea.BackgroundColor = [0.5 0.5 0.5];
            app.SaveTextArea.FontColor = [1 1 1];
            app.SaveTextArea.Visible = 'off';
            app.SaveTextArea.Position = [-8 -7 820 1066];    

            % Create ForceQuitButton
            app.ForceQuitButton = uibutton(app.UIFigure, 'push');
            app.ForceQuitButton.ButtonPushedFcn = createCallbackFcn(app, @ForceQuitButtonPushed, true);
            app.ForceQuitButton.WordWrap = 'on';
            app.ForceQuitButton.BackgroundColor = [0 0 0];
            app.ForceQuitButton.FontSize = 16;
            app.ForceQuitButton.FontWeight = 'bold';
            app.ForceQuitButton.FontColor = [1 1 1];
            app.ForceQuitButton.Position = [700 15 85 85];
            app.ForceQuitButton.Text = 'Force Quit';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = BLM_GUI_APP

            % add path to the app folder
            parent_folder = fileparts(cd); % get the parent folder of this script
            addpath(fullfile(parent_folder)); % add path with GUI app
            
            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end     

