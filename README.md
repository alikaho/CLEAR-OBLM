# Optical Beam Loss Monitor Graphical User Interface for CLEAR 2025

## Description
Graphical User Interface which visualises beam loss positions in real time along the CLEAR beamline (before 2025 summer shutdown). 130m long silica optical fiber is placed approx 40cm above the beamline. Cherenkov photons are produced in the fiber when secondary particles due to beamlosses move through the fiber at speeds higher than the phase velocity of light in the fiber. The photons are picked up by SiPMs at the upstream and downstream ends of the fiber. This GUI uses the time difference of the upstream and downstream signals to determine where along the beam the beam loss occurred. 

## Usage
All functions and scripts to run the GUI are found in BLM_GUI_APP. To start the GUI, run BLM_GUI_APP.m in matlab (2024 version). Path to matlab 2024 used:
    [cwo-2008-ctf2] /acc/oper/Linux/mcr/matlab > matlabr2024b_JAPC.sh
NB. matlab 2022 will blur the GUI graphics. 

- Stop/Start button will give live display of the beam loss location.
- Save and load plots for dry runs. To exit dry runs, press Stop/Start button again. 
- Use Set Oscilloscope Sensibility to avoid clipping of the waveforms/low resolution of the waveforms.
- Calibrate button should only need to be used when the fiber has been moved/fiber lengths with respect to the beamline have changed. It will place in 6 screens along the beamline, record the loss location and plot this position against the known position of the screens. The user is asked whether to use the new calibration parameters or keep the previous calibration.
- Reset scope button stops and starts the scope trigger (nb. this needs to be fixed)


Scripts used for analysing the dry runs/saved beam loss data are in BLM_Analysis. 
E.g. run BTV_screens_analysis_27072025.m 
For running the BLM_Analysis scripts, exportgraphics will give an error when running matlab 2024 version because opengl needs to be disabled to work with JAVA11. So, for producing plots on the technical network, use matlab 2022.


## Future
- Currently can only figure out how to turn the OASIS viewer trigger CX.SMEAS-BPMC-TS on and off, not the "Scope status" (top right corner) on and off. This means the Reset scope button doesn't work unless the "Scope status" is already ON.

- Need to work out how to get a better dpi image of the maps showing in MATLAB

- Make sure the code is not affected by the time/div setting on OASIS viewer, nor the Number of Points (can be accessed in Scope1-> CA>SCOPE10.CHO01-AS -> Channel Options -> Number of points)

- Second fiber along second part of CLEAR beamline in September will need to be added to the GUI. 

- Possible energy dependence of screens (?) needs to be taken into account

- Monty's work: Reconstruction of beam position based on position of loss for magnets kicking in different directions


## Authors and acknowledgment
Alika Ho, based on original GUI by Alexander Christie. With lots of help from Montague King and Pierre Korysko.


## Support
alika.ho@queens.ox.ac.uk

If you have run out of energy or time for your project, put a note at the top of the README saying that development has slowed down or stopped completely. Someone may choose to fork your project or volunteer to step in as a maintainer or owner, allowing your project to keep going. You can also make an explicit request for maintainers.








        
