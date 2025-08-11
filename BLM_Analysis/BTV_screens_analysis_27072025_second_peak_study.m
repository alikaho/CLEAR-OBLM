% Script analyses the BLM signals from all screens, focusing on the second peak position

close all
date = num2str(27072025);
refr_idx = 1.465; % silicon refractive index for fiber distance of around 60m. See effective refractive index to see full accounting of fiber distance/attenuation/wavelength etc. 

parent_folder = fileparts(cd); % get the parent folder of this script
addpath(fullfile(parent_folder, 'BLM_GUI_APP')); % add path with GUI app


% Manually looking at where the second peak is in the data
rise_index_up = 545; 
distance = ( Find_fiber_loss_dist_upstream(refr_idx, rise_index_up) - 22.3236 ) / 1.0922 ; % find the distance travelled by the second peak upstream
fprintf("Distance travelled by second peak upstream: %.3f m\n", distance);


