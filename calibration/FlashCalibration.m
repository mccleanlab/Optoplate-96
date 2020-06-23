
%% Load calibration file
[file, path] = uigetfile('.mat','Select calibration data');

calibration_data = load([path file]);


fileID = fopen('arduino/src/calibration_config.h','w');

fprintf(fileID,'/* This is an auto generated file.\nFind the generator in ../Matlab/Calibration.*/\n\n');

fprintf(fileID,'#ifndef _CALIBRATION_CONFIG_H\n#define _CALIBRATION_CONFIG_H\n\n');
fprintf(fileID,'#include <Arduino.h>\n\n');

numb_leds = size(calibration_data.cal, 2);

fprintf(fileID, 'const uint8_t calibration_data[96][%i] = {\n', numb_leds);

for i = (1:96)
    fprintf(fileID, '\t{');
    for led = 1:numb_leds
        fprintf(fileID, '%4i,',  calibration_data.cal(i, led));
    end
    fprintf(fileID, '},\n');
end

fprintf(fileID, '};\n\n');
fprintf(fileID,'#endif\n');

fclose(fileID);
 
status = system('cd arduino & platformio run --target upload');
 
 