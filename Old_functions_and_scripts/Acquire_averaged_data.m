function [avg_up_data, avg_down_data, Fiber_up, Fiber_down] = Acquire_averaged_data(app)
    % This function acquires the raw upstream and downstream signals
    % both for singular measurements of 1000 time samples, and also
    % the averaged and smoothed (using Sgolayfilt) data for
    % upstream and downstream.

    Fiber_down = zeros(10, app.time_pts);
    Fiber_up = zeros(10, app.time_pts);


    for i = 1:10
        Fiber_down_all = matlabJapc.staticGetSignal('SCT.USER.SETUP','CA.SCOPE10.CH02/Acquisition') ;
        Fiber_up_all = matlabJapc.staticGetSignal('SCT.USER.SETUP','CA.SCOPE10.CH01/Acquisition') ;      
        Fiber_down(i, :) = double(Fiber_down_all.value) .* Fiber_down_all.sensitivity + Fiber_down_all.offset;
        Fiber_up(i, :) = double(Fiber_up_all.value) .* Fiber_up_all.sensitivity + Fiber_up_all.offset;
        plot(Fiber_up(i,:), "Color",[0 0 1 0.1])
        plot(Fiber_down(i,:), "Color",[0 1 0 0.1])
        hold on
        pause(0.5)
    end


    avg_down_data = mean(Fiber_down(1:10, :));
    avg_up_data = mean(Fiber_up(1:10, :));

    plot(avg_up_data, "Color",[1 0 0])   
    plot(avg_down_data, "Color",[1 0 0])   



end
