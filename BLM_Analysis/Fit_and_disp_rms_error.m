function [gradient, offset] = Fit_and_disp_rms_error(screen_distances, reconstructed_positions)
    % Fits a straight line to the reconstructed positions and displays the fit and RMS errors in bracket format
    % Inputs:
    %   screen_distances: vector of screen distances
    %   reconstructed_positions: vector of reconstructed positions  
    % Outputs:
    %   gradient: gradient of the fitted line for use in calibration
    %   offset: offset of the fitted line for use in calibration and also plotting display
    
    % fit data with straight line
    fit = polyfit(screen_distances, reconstructed_positions, 1);
    gradient = fit(1);
    offset = fit(2);

    % plot straight fit line
    screen_distances_plot = [screen_distances(1),screen_distances(end)];
    expected_screen_distances =  gradient * screen_distances_plot;
    plot(screen_distances_plot, expected_screen_distances, 'LineWidth', 2)

    % find the rms error between the predicted rise indices and the observed rise indices
    distances_rms = gradient * screen_distances + offset;
    rms = rmse(distances_rms, reconstructed_positions); % find root mean squared error between the predicted rise indices and the observed rise indices

    % find this as a percentage error and convert into gradient and offset errors
    percent_error = rms/ mean(screen_distances) * 100; % calculate the root mean squared percentage error
    gradient_error = round(abs(percent_error * gradient / 100),1, 'significant'); % calculate the gradient error
    offset_error = round(abs(percent_error * offset / 100),1, 'significant'); % calculate the offset error
    
    % reduce the gradient and offset to the significant figures of the gradient and offset errors
    gradient = round(gradient, -floor(log10(gradient_error))); % round the gradient to the significant figures of the gradient error     
    offset = round(offset, -floor(log10(offset_error))); % round the gradient to the significant figures of the gradient error

    % display the leading digit of the gradient and offset errors
    offset_error_disp = leadingDigit(offset_error); % leading digit of the offset error
    gradient_error_disp = leadingDigit(gradient_error); % leading digit of the gradient error

    % display the fit and rms values on the plot
    text(screen_distances_plot(1) + 15, expected_screen_distances(1) + 10, [' Fit: y = ' num2str(gradient) '(' num2str(gradient_error_disp) ')' 'x + ' num2str(offset) '(' num2str(offset_error_disp) ')'])
    text(screen_distances_plot(1) + 15, expected_screen_distances(1) + 8, ['RMS value = ' num2str(rms)])

end