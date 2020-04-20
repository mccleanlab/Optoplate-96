%% FlashExperiment
% This script loads an experiment .mat file and will flash any available OptoPLate with the experiment.  

% Load experiment
[file, path] = uigetfile('experiment_files/*.mat','Select LED experiment file');

experiment = load([path, file]);
experiment = experiment.experiment;

% Create header file
fileID = fopen('arduino/src/experiment_config.h','w');

fprintf(fileID,'/* This is an auto generated file.\nGenerated using ../Matlab/FlashExperiment.m */\n\n');

% Tell the compiler to only include the header file once
fprintf(fileID,'#ifndef _EXPERIMENT_CONFIG_H\n#define _EXPERIMENT_CONFIG_H\n\n');

fprintf(fileID,'#include "LED.h"\n#include <Arduino.h>\n\n');

% Save the experiment parameters as arrays PROGMEM to save storage space
fprintf(fileID, 'const uint8_t amplitudes[] PROGMEM = {\n');
for i = (1:96)
    fprintf(fileID, '%4i,',  experiment.amplitudes(ceil(i/12), mod(i-1,12)+1));
end
fprintf(fileID, '\n};\n\n');

fprintf(fileID, 'const uint16_t pulseNumbs[] PROGMEM = {\n');
for i = (1:96)
    fprintf(fileID, '%6i,',  experiment.pulse_numbs(ceil(i/12), mod(i-1,12)+1));
end
fprintf(fileID, '\n};\n\n');

fprintf(fileID, 'const uint16_t pusleStartTimes[] PROGMEM = {\n');
for i = (1:96)
    fprintf(fileID, '%6i,',  experiment.pusle_start_times(ceil(i/12), mod(i-1,12)+1));
end
fprintf(fileID, '\n};\n\n');

fprintf(fileID, 'const uint16_t pulseHighTimes[] PROGMEM = {\n');
for i = (1:96)
    fprintf(fileID, '%6i,',  experiment.pulse_high_times(ceil(i/12), mod(i-1,12)+1));
end
fprintf(fileID, '\n};\n\n');

fprintf(fileID, 'const uint16_t pulseLowTimes[] PROGMEM = {\n');
for i = (1:96)
    fprintf(fileID, '%6i,',  experiment.pulse_low_times(ceil(i/12), mod(i-1,12)+1));
end
fprintf(fileID, '\n};\n\n');

fprintf(fileID, 'const uint16_t subpulseHighTimes[] PROGMEM = {\n');
for i = (1:96)
    fprintf(fileID, '%6i,',  experiment.subpulse_high_times(ceil(i/12), mod(i-1,12)+1));
end
fprintf(fileID, '\n};\n\n');

fprintf(fileID, 'const uint16_t subpulseLowTimes[] PROGMEM = {\n');
for i = (1:96)
    fprintf(fileID, '%6i,',  experiment.subpulse_low_times(ceil(i/12), mod(i-1,12)+1));
end
fprintf(fileID, '\n};\n\n');

% Close the compiler protector
fprintf(fileID,'#endif //_EXPERIMENT_CONFIG_H \n');

fclose(fileID);

% Go to Arduino folder and flash the code with the experiment
status = system('cd arduino & platformio run --target upload');




