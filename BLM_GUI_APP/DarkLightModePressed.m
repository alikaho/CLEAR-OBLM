% Button pushed function: LightModeButton
function DarkLightModePressed(app, event)
    
    if strcmp(app.dark_light_mode, 'dark') % if currently in dark mode
        app.UIFigure.Color = [0.9412 0.9412 0.9412];

        app.LightModeButton.BackgroundColor = [0 0.4471 0.7412];
        app.LightModeButton.FontColor = [1 1 1];          
        app.LightModeButton.Text = 'Dark Mode';

        app.CLEARBeamlineAxesPart2.Title.Color = [0 0 0];                
        app.CLEARBeamlineAxesPart1.Title.Color = [0 0 0];                
        app.PositionPlotAxesPart1.Title.Color = [0 0 0];                
        app.PositionPlotAxesPart2.Title.Color = [0 0 0];       
        app.LegendAxes.Title.Color = [0 0 0];                  

        app.image1 = imread('Images/CLEAR_Beamline_Light_1.png');
        app.image2 = imread('Images/CLEAR_Beamline_Light_2.png');
        app.image3 = imread('Images/CLEAR_Legend_Light.png');
        imshow(app.image1,'Parent',app.CLEARBeamlineAxesPart1); 
        imshow(app.image2,'Parent',app.CLEARBeamlineAxesPart2);
        imshow(app.image3,'Parent',app.LegendAxes);               

        app.UIAxes1.Title.Color = [0 0 0];
        app.UIAxes1.XColor = [0 0 0];
        app.UIAxes1.YColor = [0 0 0];
        app.UIAxes1.Color = [1 1 1];
        app.UIAxes2.Title.Color = [0 0 0];
        app.UIAxes2.XColor = [0 0 0];
        app.UIAxes2.YColor = [0 0 0];                
        app.UIAxes2.Color = [1 1 1];
        app.UIAxes3.Title.Color = [0 0 0];                
        app.UIAxes3.XColor = [0 0 0];
        app.UIAxes3.YColor = [0 0 0];
        app.UIAxes3.Color = [1 1 1];
        app.UIAxes4.Title.Color = [0 0 0];                
        app.UIAxes4.XColor = [0 0 0];
        app.UIAxes4.YColor = [0 0 0];
        app.UIAxes4.Color = [1 1 1];            

        app.OnOffRockerSwitch.FontColor = [0 0 0];                  
        app.DistanceTextArea.FontColor = [0 0 0];
        app.DistanceTextArea.BackgroundColor = [1 1 1];
        app.DistanceTextArea_2.FontColor = [0 0 0];
        app.DistanceTextArea_2.BackgroundColor = [1 1 1];
        app.MeasurementLabel.FontColor = [0 0 0];
        app.DownstreamSensibilityButtonGroup.BackgroundColor = [1 1 1];
        app.UpstreamSensibilityButtonGroup.BackgroundColor = [1 1 1];
        app.DownstreamSensibilityButtonGroup.ForegroundColor = [0 0 0];
        app.UpstreamSensibilityButtonGroup.ForegroundColor = [0 0 0];   
        app.SetOscilloscopeSensibilityLabel.FontColor = [0 0 0];

        allDownstreamButtons = app.DownstreamSensibilityButtonGroup.Children;
        set(allDownstreamButtons, 'BackgroundColor', [1 1 1])
        set(allDownstreamButtons, 'FontColor', [0 0 0])

        allUpstreamButtons = app.UpstreamSensibilityButtonGroup.Children;
        set(allUpstreamButtons, 'BackgroundColor', [1 1 1])
        set(allUpstreamButtons, 'FontColor', [0 0 0])

        app.plot_rise_index_colour = 'blue';
        app.plot_beam_loss_colour = [0 0 1 0.5];

        app.dark_light_mode = 'light';                

    else % if currently light mode and changing to dark mode
        app.UIFigure.Color = [0.149 0.149 0.149];  

        app.LightModeButton.BackgroundColor = [0.9294 0.6941 0.1255];
        app.LightModeButton.FontColor = [0 0 0];        
        app.LightModeButton.Text = 'Light Mode';

        app.CLEARBeamlineAxesPart2.Title.Color = [1 1 1];                
        app.CLEARBeamlineAxesPart1.Title.Color = [1 1 1];                
        app.PositionPlotAxesPart1.Title.Color = [1 1 1];                
        app.PositionPlotAxesPart2.Title.Color = [1 1 1];
        app.LegendAxes.Title.Color = [1 1 1];  

        app.image1 = imread('Images/CLEAR_Beamline_Dark_1.png');
        app.image2 = imread('Images/CLEAR_Beamline_Dark_2.png');
        app.image3 = imread('Images/CLEAR_Legend_Dark.png');
        imshow(app.image1,'Parent',app.CLEARBeamlineAxesPart1); 
        imshow(app.image2,'Parent',app.CLEARBeamlineAxesPart2);
        imshow(app.image3,'Parent',app.LegendAxes);                 
        
        app.UIAxes1.Title.Color = [1 1 1];
        app.UIAxes1.XColor = [1 1 1];
        app.UIAxes1.YColor = [1 1 1];
        app.UIAxes1.Color = [0 0 0];
        app.UIAxes2.Title.Color = [1 1 1];
        app.UIAxes2.XColor = [1 1 1];
        app.UIAxes2.YColor = [1 1 1];                
        app.UIAxes2.Color = [0 0 0];
        app.UIAxes3.Title.Color = [1 1 1];                
        app.UIAxes3.XColor = [1 1 1];
        app.UIAxes3.YColor = [1 1 1];
        app.UIAxes3.Color = [0 0 0];
        app.UIAxes4.Title.Color = [1 1 1];                
        app.UIAxes4.XColor = [1 1 1];
        app.UIAxes4.YColor = [1 1 1];
        app.UIAxes4.Color = [0 0 0];                         

        app.OnOffRockerSwitch.FontColor = [1 1 1];                
        app.DistanceTextArea.FontColor = [1 1 1];
        app.DistanceTextArea.BackgroundColor = [0.149 0.149 0.149];
        app.DistanceTextArea_2.FontColor = [1 1 1];
        app.DistanceTextArea_2.BackgroundColor = [0 0 0];
        app.MeasurementLabel.FontColor = [1 1 1];
        app.DownstreamSensibilityButtonGroup.BackgroundColor = [0.149 0.149 0.149];
        app.UpstreamSensibilityButtonGroup.BackgroundColor = [0.149 0.149 0.149];
        app.DownstreamSensibilityButtonGroup.ForegroundColor = [1 1 1];
        app.UpstreamSensibilityButtonGroup.ForegroundColor = [1 1 1];            
        app.SetOscilloscopeSensibilityLabel.FontColor = [1 1 1];

        allDownstreamButtons = app.DownstreamSensibilityButtonGroup.Children;
        set(allDownstreamButtons, 'BackgroundColor', [0.149 0.149 0.149])
        set(allDownstreamButtons, 'FontColor', [1 1 1])

        allUpstreamButtons = app.UpstreamSensibilityButtonGroup.Children;
        set(allUpstreamButtons, 'BackgroundColor', [0.149 0.149 0.149])
        set(allUpstreamButtons, 'FontColor', [1 1 1])
        
        app.plot_rise_index_colour = 'cyan';
        app.plot_beam_loss_colour = [0 1 1 0.5];
        
        app.dark_light_mode = 'dark';                   


    end


end