
%% Load calibration file
[file, path] = uigetfile('.mat','Select calibration data');

calibrationData = load([path file]);

fileID = fopen('arduino/src/calibration_config.h','w');

fprintf(fileID,'/* This is an auto generated file.\nFind the generator in ../Matlab/Calibration.*/\n\n');

fprintf(fileID,'#ifndef _CALIBRATION_CONFIG_H\n#define _CALIBRATION_CONFIG_H\n\n');
fprintf(fileID,'#include <Arduino.h>\n\n');

fprintf(fileID, 'const uint8_t calibration_data[96][2] = {\n');

for i = (1:96)
    fprintf(fileID, '\t{');
    fprintf(fileID, '%4i,',  calibrationData.cal(i, 1));
    fprintf(fileID, '%4i,',  calibrationData.cal(i, 2));
    fprintf(fileID, '},\n');
end

fprintf(fileID, '};\n\n');
fprintf(fileID,'#endif\n');

fclose(fileID);
 
status = system('cd arduino & platformio run --target upload');
 
 