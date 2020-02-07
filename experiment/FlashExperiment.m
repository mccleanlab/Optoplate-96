
[file, path] = uigetfile('experiment_files/*.mat','Select LED pattern data');

experimnet_data = load([path, file]);

experimnet_data = experimnet_data.experimnet_data;

if(size(experimnet_data(1).intensity,1) > 25)
error('The number of phases exceeds 25. Arduino Micro does not have enough storage space')
end
fileID = fopen('arduino/src/experiment_config.h','w');

fprintf(fileID,'/* This is an auto generated file.\nFind the generator in ../Matlab/ExperimentGenerator.*/\n\n');

fprintf(fileID,'#ifndef _EXPERIMENT_CONFIG_H\n#define _EXPERIMENT_CONFIG_H\n\n');
fprintf(fileID, '#define PHASE_NUMB %i\n', length(experimnet_data(1).intensity));
fprintf(fileID,'#include "LED.h"\n#include <Arduino.h>\n\n');

fprintf(fileID, 'const uint8_t intensities[][PHASE_NUMB] PROGMEM = {\n');
for i = (1:96)
    fprintf(fileID, '\t{');
    fprintf(fileID, '%4i,',  experimnet_data(ceil(i/12), mod(i-1,12)+1).intensity);
    fprintf(fileID, '},\n');
end
fprintf(fileID, '};\n\n');
 
 
fprintf(fileID, 'const uint8_t periods[][PHASE_NUMB] PROGMEM = {\n');
for i = (1:96)
    fprintf(fileID, '\t{');
    fprintf(fileID, '%4i,',  experimnet_data(ceil(i/12), mod(i-1,12)+1).periods);
    fprintf(fileID, '},\n');
 end
 fprintf(fileID, '};\n\n');
 

fprintf(fileID, 'const uint16_t offset[][PHASE_NUMB] PROGMEM = {\n');
for i = (1:96)
    fprintf(fileID, '\t{');
    fprintf(fileID, '%6i,',  experimnet_data(ceil(i/12), mod(i-1,12)+1).offset);
    fprintf(fileID, '},\n');
end
fprintf(fileID, '};\n');
 
fprintf(fileID, 'const uint16_t tInterpulse[][PHASE_NUMB] PROGMEM = {\n');
for i = (1:96)
    fprintf(fileID, '\t{');
    fprintf(fileID, '%6i,',  experimnet_data(ceil(i/12), mod(i-1,12)+1).t_interpulse);
    fprintf(fileID, '},\n');
 end
 fprintf(fileID, '};\n');
 
  
  fprintf(fileID, 'const uint16_t tPulse[][PHASE_NUMB] PROGMEM = {\n');
 
 for i = (1:96)
    fprintf(fileID, '\t{');
    fprintf(fileID, '%6i,',  experimnet_data(ceil(i/12), mod(i-1,12)+1).t_pulse);
    fprintf(fileID, '},\n');
 end
 fprintf(fileID, '};\n');
      
 fprintf(fileID,'#endif\n');
  
 fclose(fileID);
 
 status = system('cd arduino & platformio run --target upload');
 
 
 
 
 