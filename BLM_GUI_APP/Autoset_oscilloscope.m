function Autoset_oscilloscope(channel)
    % Function autosets the oscilloscope channel settings of sensibility
    % and offset so that the signal's halfway point sits on the zero of the
    % OASIS view and the whole signal is the largest it can be while still
    % fitting inside of the OASIS viewer.

    % all units done in mV unless otherwise stated

    % INITIALISE %%%%%%%%%%%%%%%%%%%%%%

    % initialise the offset such that the range can actually be calculated
    % - would like to find a way to do this better. But in general if the
    % signal is completely off the screen then the scope can't give
    % anything about the signal.

    if strcmp(channel, 'CA.SCOPE10.CH01')
        matlabJapc.staticSetSignal('SCT.USER.SETUP','CA.SCOPE10.CH01/Offset#value', -114 / 1000 ) % initialise offset to -141mV
    elseif strcmp(channel, 'CA.SCOPE10.CH02')
        matlabJapc.staticSetSignal('SCT.USER.SETUP','CA.SCOPE10.CH02/Offset#value', -9.8 / 1000) % initialise offset to -9.8mV
    end

    % also initialise the sensibility to be very coarse - just so the
    % signal is definitely not off the viewing screen and we can take
    % maximum and minimum values confidently. 
    matlabJapc.staticSetSignal('SCT.USER.SETUP',[channel, '/Sensibility#value'], 2) % initialise sensibility to 500mV/div 

    pause(3) % need pauses because otherwise the OASIS viewer takes too long to change between settings
    disp('Initialised sensibility and offset to read signal.')


    % GET DATA %%%%%%%%%%%%%%%%%%%%
    data = matlabJapc.staticGetSignal('SCT.USER.SETUP', [channel, '/Acquisition']) ;

    data_values = (double(data.value) * data.sensitivity + data.offset) * 1000 ; % this gives a value in mV
    max_data = max(data_values) ;
    min_data = min(data_values) ;

    range = (max_data - min_data) ; % range from the maximum to the minimum in mV
    middle = (max_data + min_data) /2 ; % middle of the signal in mV

    disp('Signal recorded')

    % SET OFFSET AND SENSIBILITY %%%%%%%%%%%%%%%%%
    matlabJapc.staticSetSignal('SCT.USER.SETUP',[channel, '/Offset#value'], - 1*middle / 1000) % nb offset must be set in units of volts, ie 1 corresponds to 1V = 1000mV    

    pause(2)
    disp('Offset chosen')

    if range <= 50 % if the range is less than 500mV then set the sensibility to 5mV (10 divisions across the scope screen)
        matlabJapc.staticSetSignal('SCT.USER.SETUP',[channel, '/Sensibility#value'], 0.05)  % nb sensibility is given in units of 10 times volts for some reason - 0.05 corresponds to 5mV = 0.005V     
    elseif range <= 100
        matlabJapc.staticSetSignal('SCT.USER.SETUP',[channel, '/Sensibility#value'], 0.1)
    elseif range <= 200
        matlabJapc.staticSetSignal('SCT.USER.SETUP',[channel, '/Sensibility#value'], 0.2)
    elseif range <= 500
        matlabJapc.staticSetSignal('SCT.USER.SETUP',[channel, '/Sensibility#value'], 0.5)
    elseif range <= 1000
        matlabJapc.staticSetSignal('SCT.USER.SETUP',[channel, '/Sensibility#value'], 1)
    elseif range <= 2000
        matlabJapc.staticSetSignal('SCT.USER.SETUP',[channel, '/Sensibility#value'], 2)
    else
        matlabJapc.staticSetSignal('SCT.USER.SETUP',[channel, '/Sensibility#value'], 5)                    
    end
    
    pause(1)
    disp('Sensibility chosen')
    disp('Autoset of scope settings complete.')

end

