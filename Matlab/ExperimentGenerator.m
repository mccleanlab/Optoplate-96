clear all; 

led.intens = 0;
led.duration = 0;
phaseData = repmat(led,1,96);
for i = (1:96)
    phaseData(i).intens = randi([0, 255], [9,1]);
    phaseData(i).duration = randi([0, 255], [9,1]);
    
end
 save('phaseData.mat', 'phaseData');
 
 load('phaseData.mat')
 fileID = fopen('experiment_config.h','w');
 fprintf(fileID,'#ifndef _EXPERIMENT_CONFIG_H\n#define _EXPERIMENT_CONFIG_H\n\n');
 fprintf(fileID,'#include "LED.h"\n\n');
 
 fprintf(fileID, 'uint8_t intensities[][%d] = {\n', size(phaseData(1).intens,1));
 
 for i = [1:96]
    fprintf(fileID, '\t{');
    fprintf(fileID, '%i,',  phaseData(i).intens);
    fprintf(fileID, '},\n');
 end
 fprintf(fileID, '};\n\n');
 
  fprintf(fileID, 'uint16_t durations[][%d] = {\n', size(phaseData(1).duration, 1));
 
 for i = [1:96]
    fprintf(fileID, '\t{');
    fprintf(fileID, '%i,',  phaseData(i).duration);
    fprintf(fileID, '},\n');
 end
 fprintf(fileID, '};\n');
 
   fprintf(fileID, 'LED leds[] = {\n');
 
 for i = (1:96)
    fprintf(fileID, '\tLED(& intensities[%i], & durations[%i]),\n', i, i);
 end
 fprintf(fileID, '};\n\n');
 
  fprintf(fileID,'#endif\n');
  
 fclose(fileID);
 
 
 
 