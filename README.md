# CLEAR OBLM
Optical Beam Loss Monitor Graphical User Interface for CLEAR 2025
Original code developed by Alexander Christie 2022, New GUI Alika Ho 2025
Theory and analysis from Monty King.

## Description
Graphical User Interface which visualises beam loss positions in real time along the CLEAR beamline. 
130m long fiber placed approx 40cm above the CLEAR Beamline 2025. 


## Usage
All functions and scripts to run the GUI are found in BLM_GUI_APP. To start the GUI, run BLM_GUI_APP.m in matlab (2024 version). Path to matlab 2024 used:
    [cwo-2008-ctf2] /acc/oper/Linux/mcr/matlab > matlabr2024b_JAPC.sh
NB. matlab 2022 will blur the GUI graphics. 

Scripts used for analysing the beam loss saved data are in BLM_Analysis. 
E.g. run BTV_screens_analysis_27072025.m 



## Support
Tell people where they can go to for help. It can be any combination of an issue tracker, a chat room, an email address, etc.

## Roadmap
If you have ideas for releases in the future, it is a good idea to list them in the README.

## Contributing
State if you are open to contributions and what your requirements are for accepting them.

For people who want to make changes to your project, it's helpful to have some documentation on how to get started. Perhaps there is a script that they should run or some environment variables that they need to set. Make these steps explicit. These instructions could also be useful to your future self.

You can also document commands to lint the code or run tests. These steps help to ensure high code quality and reduce the likelihood that the changes inadvertently break something. Having instructions for running tests is especially helpful if it requires external setup, such as starting a Selenium server for testing in a browser.

## Authors and acknowledgment
Show your appreciation to those who have contributed to the project.

## License
For open source projects, say how it is licensed.

## Project status
If you have run out of energy or time for your project, put a note at the top of the README saying that development has slowed down or stopped completely. Someone may choose to fork your project or volunteer to step in as a maintainer or owner, allowing your project to keep going. You can also make an explicit request for maintainers.





************************

Graphical User Interface for Optical Beam Loss Monitor Fiber installed along CLEAR Beamline


************************


Everything to run the GUI can be found in BLM_GUI_APP. To start the GUI, run BLM_GUI_APP.m in matlab (2024 version).
nb. matlab 2022 will blur the GUI graphics. Path to matlab 2024 used:
    [cwo-2008-ctf2] /acc/oper/Linux/mcr/matlab > matlabr2024b_JAPC.sh

For running the BLM_Analysis scripts, exportgraphics will give an error when running matlab 2024 version because opengl needs to be disabled to work with JAVA11. 


        
array([-1.22850073e-09,  5.05237755e-07, -9.22909293e-05,  1.46923503e+00])

