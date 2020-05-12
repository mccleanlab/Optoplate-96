# OptoPlate-96
This repository contains the code and files to calibrate and operate the [OptoPlate-96](https://www.bugajlab.com/optoplate-96). The original repository for the OptoPlate-96 can be found [here](https://github.com/BugajLab/optoPlate-96/). 
This repository was created from to provide these two features for the OptoPlate:
- MATLAB interface for operation of the OptoPlate-96.
- Functionality for calibration of the light intensities of the LEDs.
- Supports two levles of pulses to reduse the risk of light poisoning.
- Visualisaztion of light patterns before experiment.
## Installation:

- Install MATLAB
- Install Microsoft's Visual Studio Code and PlatformIO IDE by following these [instructions](https://platformio.org/install/ide?install=vscode)
- Install Platformio Shell Commands
  - In Windows Search, search for and then select: System (Control Panel)
  - Click the Advanced system settings link.
  - Click Environment Variables. In the section System Variables, find the PATH environment variable and select it. Click Edit. If the PATH environment variable does not exist, click New.
  - In the Edit enviroment variable window window create a new Path and paste `C:\Users\UserName\.platformio\penv\Scripts`. Make sure the new Path is on the top. 
  - Click OK. Close all remaining windows by clicking OK.

## Getting Started
If the OptoPlate has never been used before, it must be flashed with calibration values. Ideally the calibration procedure should be followed to calibrate the OptoPlate to ensure consistent light intensities in the different wells. However, the OptoPlate will function with the default calibration values.
To flash the default calibration values make sure the OptoPlate is connected to the PC with an USB cable annd run the file calibration/FlashCalibration.m and select calibration/calibration_files/cal_round_0.mat. For instructions on how to calibrate the OptoPlate see this article. 

To create an experiment, follow this procedure:
Create following matrices:
- amplitudes [8 by 12 matrix of unsigned 8 bit integer] - light intensity of each LED, 255 - max light intensity and 0 - no light
- pulse_numbs [8 by 12 matrix of unsigned 16 bit integer] - number of pulses for each LED
- pusle_start_times [8 by 12 matrix of unsigned 16 bit integer] - time in seconds before sequence of pulses starts
- pulse_high_times [8 by 12 matrix of unsigned 16 bit integer] - time in seconds for high phase of pulse
- pulse_low_times [8 by 12 matrix of unsigned 16 bit integer] - time in seconds for low phase of pulse
- subpulse_high_times [8 by 12 matrix of unsigned 16 bit integer] - time in seconds for high phase of subpulse
- subpulse_low_times [8 by 12 matrix of unsigned 16 bit integer] - time in seconds for low phase of subpulse
Each cell in the matrices coresponds to one light well on the OptoPlate.
![Timing Diagram](https://github.com/EdvardGrodem/Optoplate-96/blob/NewPWM/timingDiagram.png)
Create an experiment file by calling the function experiment/createExperiment.m
Make sure the OptoPlate is connected to the computer via an USB cable. Run the script experiment/FlashExperiment.m and select the experiment file.
The experiment will start immediately and will continue as long as the Arduino on the OptoPlate gets power either through the USB cable or the 7V input. If power is cut to the Arduino, the experiment will reset. The experiment will also reset if the reset button on the Arduino is pressed.

