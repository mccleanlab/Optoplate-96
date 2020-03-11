clearvars; close all; clc;

addpath('visualization');
import visualization.*


led.intensity = 0; 
led.periods = 0;
led.offset = 0;
led.t_interpulse = 0;
led.t_pulse = 0;

intens = 118;

experiment_data = repmat(led,8,12);
length = 1;
checker = 2;
% Loop through the leds
for row = 1:8
    for column = 1:12
        % Intensity of the LEDs in a well from 0 to 255
        %experiment_data(colum2, row).intensity = 122;
        if checker == 2 
            if mod(row, 2) == 1
                experiment_data(row, column).intensity = intens*(1-mod(column,2));
            else
                experiment_data(row, column).intensity = intens*mod(column,2); 
            end
        else
            if mod(row, 2) == 1
                experiment_data(row, column).intensity = intens*(mod(column,2));
            else
                experiment_data(row, column).intensity = intens*(1-mod(column,2)); 
            end
        end
        
%         if checker == 2 
%             if mod(row, 2) == 1
%                 experiment_data(row, column).intensity = ((column)/2)*20*(1-mod(column,2));
%             else
%                 experiment_data(row, column).intensity = (((column)/2)*20+120)*mod(column,2); 
%             end
%         else
%             if mod(row, 2) == 1
%                 experiment_data(row, column).intensity = ((column)/2)*20*(mod(column,2));
%             else
%                 experiment_data(row, column).intensity = (((column)/2)*20+120)*(1-mod(column,2)); 
%             end
%         end
        % The number of periods as a interger from 1 to 65536
        experiment_data(row, column).periods = 1;
        % The number of periods as a interger from 1 to 65536
        experiment_data(row, column).offset = 1;
        
        % The duration in seconds of the low section of the pulse modulated
        % signal, from 1 to 65536
        experiment_data(row, column).t_interpulse = 1;
        % The duration in seconds of the high section of the pulse modulated
        % signal, from 1 to 65536
        experiment_data(row, column).t_pulse = 65532;
    end
end

prompt = 'Input experiment name:  ';
user_entry = input(prompt, 's');
file_name = ['experiment_files/', date , '-', user_entry, '.mat'];
save(file_name, 'experiment_data');
plotLedSelector(experiment_data);
