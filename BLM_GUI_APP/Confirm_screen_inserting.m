function calibration_confirm = Confirm_screen_inserting(app)

    % app.SaveTextArea.Value = ' ';
    % app.SaveTextArea.Visible = 'on'; 
    % 
    % app.CheckTextArea.Visible = 'on';
    % app.ConfirmScreenButtonGroup.Visible = 'on';
    % app.YescontinueButton.Visible = 'on';
    % app.NoButton.Visible = 'on';
    
    answer = uiconfirm(app.UIFigure, 'Calibration of the beam loss position monitor requires inserting and removing screens 390, 620, 730 and 810. Are you sure you want to continue? ', 'Confirm', 'Options', {'Yes, continue', 'No'}, 'DefaultOption', 2);

    if strcmp(answer, 'Yes, continue')
        calibration_confirm = true;
    else if strcmp(answer, 'No')
        calibration_confirm = false;
    end
       
      
end
