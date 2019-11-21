
OptoPlate-96

Installation:

 Install MATLAB

 Install Microsoft's Visual Studio Code and PlatformIO IDE

	Go to this link and follow the instructions:
	https://platformio.org/install/ide?install=vscode

 Install Platformio Shell Commands

	In Search, search for and then select: System (Control Panel)
	Click the Advanced system settings link.
	Click Environment Variables. In the section System Variables, find the PATH environment variable and select it. Click Edit. If the PATH environment variable does not exist, click New.
	In New System Variable window paste C:\Users\UserName\.platformio\penv\Scripts . Make sure the new Path is on the top. 
	Click OK. Close all remaining windows by clicking OK.

Use:

 Datastructure of experiment:
	Create a phaseData.mat file in the folder named Matlab, with the following structure:
		led.intensity = 0;
		led.duration = 0;
		phaseData = repmat(led,1,96);
		width = 14;

		for i = (1:96)
			phaseData(i).intensity = ones([width, 1])*255;
			phaseData(i).periods = ones([width, 1])*3;
			phaseData(i).offset = ones([width, 1])*5;
			phaseData(i).tInterpulse = ones([width, 1])*0;
			phaseData(i).tPulse = ones([width, 1])*1;
		end
 	save('phaseData.mat', 'phaseData');
		
	Intensity must be a 8 bit unsigned integer from 0 to 255.
	Durations must be a 8 bit unsigned integer from 0 to 255.
	Duration in seconds for each intensity is specified in the corresponding duration.
	Durations must be a 16 bit unsigned integer from 0 to 65535.
	All intensities vectors and duration must be of equal length.
	If a LED comes to a phase with 0s in duration, that LED will turn off and remain off.
	When a LED has gone trought all it's phases the LED loops back to phase 1

 Flash microcontroller:
	Make sure the microcontroller is connected to the PC with a USB cable
	Run the file ExperimentGenerator.m
	Do science!







	
