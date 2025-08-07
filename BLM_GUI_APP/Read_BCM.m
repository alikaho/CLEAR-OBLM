function [newptchargeBCM_Gun, newptchargeBCM_Vesper, newptchargeBCM_THz, newptchargeBCM_THz2] = Read_BCM

BCM_sensitivity = [2.085  4.18  8.35  10.42  20.97 20.95 41.9  105.0] ; % in [V/nC] from self calibration pulse
BCM_Vesper_offset = [0.005  0.0014 0.01  0.000    0.005 0.005 0.002 0.003] ; % in [nC] from no laser beam September 06, 2016
BCM_Gun_offset    = [-0.000  -0.005 -0.003  -0.004  -0.004 -0.005 -0.005 0.002] ; % in [V] from scope high impedance
BCM_THz_offset    = [-0.000  -0.005 -0.003  -0.004  -0.004 -0.005 -0.005 0.002] ;
BCM_THz2_offset    = [-0.000  -0.00 -0.00  -0.00  -0.00 -0.00 -0.00 0.00] ;

BCM1_data = matlabJapc.staticGetSignal('SCT.USER.SETUP','CE.SCOPE61.CH01/Acquisition') ; 
BCM2_data = matlabJapc.staticGetSignal('SCT.USER.SETUP','CE.SCOPE61.CH02/Acquisition') ;
BCM3_data = matlabJapc.staticGetSignal('SCT.USER.SETUP','CE.SCOPE61.CH03/Acquisition') ;
BCM4_data = matlabJapc.staticGetSignal('SCT.USER.SETUP','CE.SCOPE61.CH04/Acquisition') ;

BCM_gain = matlabJapc.staticGetSignal('SCT.USER.SETUP','CA.BCM01GAIN/Setting#enumValue') ;


% BCM5_data = dati.values{5} ;  % Laser analog power meter

BCM1_value_n = double(BCM1_data.value) * BCM1_data.sensitivity + BCM1_data.offset ;
BCM2_value_n = double(BCM2_data.value) * BCM2_data.sensitivity + BCM2_data.offset ;
BCM3_value_n = double(BCM3_data.value) * BCM3_data.sensitivity + BCM3_data.offset ;
BCM4_value_n = double(BCM4_data.value) * BCM4_data.sensitivity + BCM4_data.offset ;

% BCM5_value_n = double(BCM5_data.value) * BCM5_data.sensitivity + BCM5_data.offset ;

   
switch BCM_gain
    case '6dB'
        indx = 1 ;
    case '12dB'
        indx = 2 ;
    case '18dB'
        indx = 3 ;
    case '20dB'
        indx = 4 ;
    case '26dB1'
        indx = 5 ;
    case '26dB2'
        indx = 6 ;
    case '32dB'
        indx = 7 ;
    case '40dB'
        indx = 8 ;
end

newptchargeBCM_Gun    = mean(BCM1_value_n(20:60)) / BCM_sensitivity(indx) * 10 ; % This factor 10 is coming from the ICT type and was forgotten during 1 year
newptchargeBCM_Vesper = mean(BCM2_value_n(20:60)) / BCM_sensitivity(indx) * 10 + BCM_Vesper_offset(indx) ;
newptchargeBCM_THz    = mean(BCM3_value_n(20:60)) / BCM_sensitivity(indx) * 10 + BCM_THz_offset(indx) ;
newptchargeBCM_THz2    = mean(BCM4_value_n(20:60)) / BCM_sensitivity(indx) * 10 + BCM_THz2_offset(indx) ;



end



    
