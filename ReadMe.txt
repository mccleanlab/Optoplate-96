
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
	The Calibration.m script must be run so that the OptoPlate has been flashed  before the OptoPlate can be used.
	Create a phaseData.mat file in the folder named Matlab, with the following structure:
		led.intensity = 0;
		led.periods = 0;
		led.offset = 0;
		led.tInterpulse = 0;
		led.tPulse = 0;
		phaseData = repmat(led,1,96);

		phases = 25;

		for i = (1:96)
			phaseData(i).intensity = ones([phases, 1])*1;
			phaseData(i).periods = ones([phases, 1])*100;
			phaseData(i).offset = ones([phases, 1])*2;
			
			phaseData(i).tInterpulse = ones([phases, 1])*3;
			phaseData(i).tPulse = ones([phases, 1])*1000;
		end

		save('phaseData.mat', 'phaseData');
		
	Intensity must contain 8 bit unsigned integers from 0 to 255.
	Periods must contain 8 bit unsigned integers from 0 to 255.
	Offset must contain 16 bit unsigned integers from 0 to 65535.
	tInterpulse must contain 16 unsigned integers fro 1 to 65535 and the unit is seconds.
	tPulse must contain 16 unsigned integers fro 1 to 65535  and the unit is seconds.

	When a LED has gone through all of its phases it will be shut off.

	See OptoPlateTimingDiagram.png

 Flash microcontroller:
	Make sure the microcontroller is connected to the PC with a USB cable
	Run the file ExperimentGenerator.m
	Do science!







	
