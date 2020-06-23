%% FlashExperiment
% This script loads an experiment .mat file and will flash any available OptoPLate with the experiment.  

% Load experiment
[file, path] = uigetfile('experiment_files/*.mat','Select LED experiment file');

experiment = load([path, file]);
experiment = experiment.experiment;

%Number of individual LED in each well
led_numb =  size(experiment.amplitudes, 1); 

% Create header file
fileID = fopen('arduino/src/experiment_config.h','w');

fprintf(fileID,'/* This is an automatically generated file.\nGenerated using ../Matlab/FlashExperiment.m */\n\n');

% Tell the compiler to only include the header file once
fprintf(fileID,'#ifndef _EXPERIMENT_CONFIG_H\n#define _EXPERIMENT_CONFIG_H\n\n');

fprintf(fileID,'#include "LED.h"\n#include <Arduino.h>\n\n');
fprintf(fileID,'#define NUMB_WELL_LEDS %i\n', led_numb);
fprintf(fileID,'#define NUMB_WELLS %i\n\n', 96);

% Save the experiment parameters as arrays PROGMEM to save memory
fprintf(fileID, 'const uint8_t amplitudes[NUMB_WELL_LEDS][96] PROGMEM = {');
for led = 1:led_numb
    fprintf(fileID, '\n{\n');
    for i = (1:96)
        fprintf(fileID, '%4i,',  experiment.amplitudes(led, ceil(i/12), mod(i-1,12)+1));
    end
    fprintf(fileID, '\n},');
end
fprintf(fileID, '\n};\n\n');

fprintf(fileID, 'const uint16_t pulseNumbs[NUMB_WELL_LEDS][96] PROGMEM = {');
for led = 1:led_numb
    fprintf(fileID, '\n{\n');
    for i = (1:96)
        fprintf(fileID, '%6i,',  experiment.pulse_numbs(led, ceil(i/12), mod(i-1,12)+1));
    end
    fprintf(fileID, '\n},');
end
fprintf(fileID, '\n};\n\n');


fprintf(fileID, 'const uint16_t pusleStartTimes[NUMB_WELL_LEDS][96] PROGMEM = {');
for led = 1:led_numb
    fprintf(fileID, '\n{\n');
    for i = (1:96)
        fprintf(fileID, '%6i,',  experiment.pulse_start_times(led, ceil(i/12), mod(i-1,12)+1));
    end
    fprintf(fileID, '\n},');
end
fprintf(fileID, '\n};\n\n');


fprintf(fileID, 'const uint16_t pulseHighTimes[NUMB_WELL_LEDS][96] PROGMEM = {');
for led = 1:led_numb
    fprintf(fileID, '\n{\n');
    for i = (1:96)
        fprintf(fileID, '%6i,',  experiment.pulse_high_times(led, ceil(i/12), mod(i-1,12)+1));
    end
    fprintf(fileID, '\n},');
end
fprintf(fileID, '\n};\n\n');

fprintf(fileID, 'const uint16_t pulseLowTimes[NUMB_WELL_LEDS][96] PROGMEM = {');
for led = 1:led_numb
    fprintf(fileID, '\n{\n');
    for i = (1:96)
        fprintf(fileID, '%6i,',  experiment.pulse_low_times(led, ceil(i/12), mod(i-1,12)+1));
    end
    fprintf(fileID, '\n},');
end
fprintf(fileID, '\n};\n\n');


fprintf(fileID, 'const uint16_t subpulseHighTimes[NUMB_WELL_LEDS][96] PROGMEM = {');
for led = 1:led_numb
    fprintf(fileID, '\n{\n');
    for i = (1:96)
        fprintf(fileID, '%6i,',  experiment.subpulse_high_times(led, ceil(i/12), mod(i-1,12)+1));
    end
    fprintf(fileID, '\n},');
end
fprintf(fileID, '\n};\n\n');

fprintf(fileID, 'const uint16_t subpulseLowTimes[NUMB_WELL_LEDS][96] PROGMEM = {');
for led = 1:led_numb
    fprintf(fileID, '\n{\n');
    for i = (1:96)
        fprintf(fileID, '%6i,',  experiment.subpulse_low_times(led, ceil(i/12), mod(i-1,12)+1));
    end
    fprintf(fileID, '\n},');
end
fprintf(fileID, '\n};\n\n');


% Close the compiler protector
fprintf(fileID,'#endif //_EXPERIMENT_CONFIG_H \n');

fclose(fileID);

% Go to Arduino folder and flash the code with the experiment
status = system('cd arduino & platformio run --target upload');




