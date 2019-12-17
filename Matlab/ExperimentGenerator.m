
[file, path] = uigetfile('.mat','Select LED pattern data');

phaseData = load([path file]);

phaseData = phaseData.phaseData;

if(size(phaseData(1).intensity,1) > 25)
error('The number of phases exceeds 25. Arduino Micro does not have enough storage space')
end
fileID = fopen('../src/experiment_config.h','w');

fprintf(fileID,'/* This is an auto generated file.\nFind the generator in ../Matlab/ExperimentGenerator.*/\n\n');

fprintf(fileID,'#ifndef _EXPERIMENT_CONFIG_H\n#define _EXPERIMENT_CONFIG_H\n\n');
fprintf(fileID, '#define PHASE_NUMB %i\n', length(phaseData(1).intensity));
fprintf(fileID,'#include "LED.h"\n#include <Arduino.h>\n\n');

fprintf(fileID, 'const uint8_t intensities[][PHASE_NUMB] PROGMEM = {\n');
for i = (1:96)
    fprintf(fileID, '\t{');
    fprintf(fileID, '%4i,',  phaseData(i).intensity);
    fprintf(fileID, '},\n');
end
fprintf(fileID, '};\n\n');
 
 
fprintf(fileID, 'const uint8_t periods[][PHASE_NUMB] PROGMEM = {\n');
for i = (1:96)
    fprintf(fileID, '\t{');
    fprintf(fileID, '%4i,',  phaseData(i).periods);
    fprintf(fileID, '},\n');
 end
 fprintf(fileID, '};\n\n');
 

fprintf(fileID, 'const uint16_t offset[][PHASE_NUMB] PROGMEM = {\n');
for i = (1:96)
    fprintf(fileID, '\t{');
    fprintf(fileID, '%6i,',  phaseData(i).offset);
    fprintf(fileID, '},\n');
end
fprintf(fileID, '};\n');
 
fprintf(fileID, 'const uint16_t tInterpulse[][PHASE_NUMB] PROGMEM = {\n');
for i = (1:96)
    fprintf(fileID, '\t{');
    fprintf(fileID, '%6i,',  phaseData(i).tInterpulse);
    fprintf(fileID, '},\n');
 end
 fprintf(fileID, '};\n');
 
  
  fprintf(fileID, 'const uint16_t tPulse[][PHASE_NUMB] PROGMEM = {\n');
 
 for i = (1:96)
    fprintf(fileID, '\t{');
    fprintf(fileID, '%6i,',  phaseData(i).tPulse);
    fprintf(fileID, '},\n');
 end
 fprintf(fileID, '};\n');
      
 fprintf(fileID,'#endif\n');
  
 fclose(fileID);
 
 status = system('cd ../ & platformio run --target upload');
 
 
 
 
 