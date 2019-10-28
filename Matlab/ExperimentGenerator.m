
 load('phaseData.mat')
 if(size(phaseData(1).intensity,1) > 60)
    error('The number of phases exceeds 60. Arduino Micro does not have enough storage space')
 end
 fileID = fopen('../src/experiment_config.h','w');
 fprintf(fileID,'#ifndef _EXPERIMENT_CONFIG_H\n#define _EXPERIMENT_CONFIG_H\n\n');
 fprintf(fileID, '#define PHASE_NUMB %i\n', size(phaseData(1).intensity,1));
 fprintf(fileID,'#include "LED.h"\n\n');
 
 fprintf(fileID, 'const uint8_t intensities[][PHASE_NUMB] PROGMEM = {\n');
 
 for i = [1:96]
    fprintf(fileID, '\t{');
    fprintf(fileID, '%4i,',  phaseData(i).intensity);
    fprintf(fileID, '},\n');
 end
 fprintf(fileID, '};\n\n');
 
 fprintf(fileID, 'const uint16_t durations[][PHASE_NUMB] PROGMEM = {\n');
 
 for i = [1:96]
    fprintf(fileID, '\t{');
    fprintf(fileID, '%6i,',  phaseData(i).duration);
    fprintf(fileID, '},\n');
 end
 fprintf(fileID, '};\n');
 
 fprintf(fileID, 'LED leds[] = {\n');
 
 for i = (1:96)
    fprintf(fileID, '\tLED(intensities[%i], durations[%i], %i),\n', i, i, size(phaseData(1).intensity,1));
 end
 fprintf(fileID, '};\n\n');
 
 fprintf(fileID,'#endif\n');
  
 fclose(fileID);
 
 status = system('cd ../ & platformio run --target upload');
 
 
 
 
 