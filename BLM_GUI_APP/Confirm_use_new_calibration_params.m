function use_calibration_params = Confirm_use_new_calibration_params(app)

    % app.SaveTextArea.Value = ' ';
    % app.SaveTextArea.Visible = 'on'; 
    % 
    % app.CheckTextArea.Visible = 'on';
    % app.ConfirmScreenButtonGroup.Visible = 'on';
    % app.YescontinueButton.Visible = 'on';
    % app.NoButton.Visible = 'on';
    
    answer = uiconfirm(app.UIFigure, 'Would you like to use the new calibration parameters? ', 'Confirm', 'Options', {'Yes', 'No, use previous parameters'}, 'DefaultOption', 2);

    if strcmp(answer, 'Yes')
        use_calibration_params = true;
    else if strcmp(answer, 'No, use previous parameters')
        use_calibration_params = false;
    end
       
      
end
