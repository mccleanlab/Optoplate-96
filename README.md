# OptoPlate-96
This repository contains the code  to calibrate and operate the [optoPlate-96](https://www.bugajlab.com/optoplate-96).
To construct the optoPlate, see the original repository for the optoPlate-96 that can be found [here](https://github.com/BugajLab/optoPlate-96/). 
This repository was created to provide these features for the optoPlate-96:
- MATLAB interface for operation of the optoPlate-96.
- Functionality for calibration of the light intensities of the LEDs.
- Supports two levels of pulses to reduce the risk of phototoxicity.
- Visualisaztion of light patterns before an experiment.

## Installation:

- Install MATLAB
- Install Microsoft's Visual Studio Code and PlatformIO IDE by following these [instructions](https://platformio.org/install/ide?install=vscode)
- Install Platformio Shell Commands
  - In Windows Search, search for and then select: System (Control Panel)
  - Click the Advanced system settings link.
  - Click Environment Variables. In the section System Variables, find the PATH environment variable and select it. Click Edit. If the PATH environment variable does not exist, click New.
  - In the Edit enviroment variable window, create a new Path and paste `C:\Users\UserName\.platformio\penv\Scripts`. Make sure the new Path is on the top of the list. 
  - Click OK. Close all remaining windows by clicking OK.
You should now be able to flash the optoPlate-96 from your computer.

## Getting Started
If the optoPlate-96 has never been used before, it must be flashed with calibration values. Ideally the calibration procedure should be followed to calibrate the optoPlate to ensure consistent light intensities in the different wells. However, the optoPlate-96 will function with the default calibration values.
To flash the default calibration values, make sure the optoPlate is connected to the PC with an USB cable annd run the file calibration/FlashCalibration.m and select calibration/calibration_files/cal_round_0.mat. For instructions on how to calibrate the optoPlate see this article. 

To create an experiment, follow this procedure:
Create the following matrices:
- amplitudes [8 by 12 matrix of unsigned 8 bit integer] - light intensity of each LED, 255 - max light intensity and 0 - no light
- pulse_numbs [8 by 12 matrix of unsigned 16 bit integer] - number of pulses for each LED
- pusle_start_times [8 by 12 matrix of unsigned 16 bit integer] - time in seconds before sequence of pulses starts
- pulse_high_times [8 by 12 matrix of unsigned 16 bit integer] - time in seconds for high phase of pulse
- pulse_low_times [8 by 12 matrix of unsigned 16 bit integer] - time in seconds for low phase of pulse
- subpulse_high_times [8 by 12 matrix of unsigned 16 bit integer] - time in seconds for high phase of subpulse
- subpulse_low_times [8 by 12 matrix of unsigned 16 bit integer] - time in seconds for low phase of subpulse
Each cell in the matrices corresponds to a light well on the OptoPlate. For example, (1,1) is well A01 and (8,12) is well H12
![Timing Diagram](https://github.com/EdvardGrodem/Optoplate-96/blob/master/timingDiagram.png)
Create and save an experiment file by calling the function experiment/createExperiment.m
Make sure the OptoPlate is connected to the computer via an USB cable. Run the script experiment/FlashExperiment.m and select the experiment file.
The experiment will start immediately and will continue as long as the Arduino on the OptoPlate has power either through the USB cable or the 7V input. If power is cut to the Arduino, the experiment will reset. The experiment will also reset if the reset button on the Arduino is pressed.

