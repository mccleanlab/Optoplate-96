addpath('visualization');
import visualization.*


led.intensity = 0; 
led.periods = 0;
led.offset = 0;
led.t_interpulse = 0;
led.t_pulse = 0;

intens = 100;

experiment_data = repmat(led,8,12);
length = 1;
% Loop through the leds
for colum = 1:8
    for row = 1:12
        % Intensity of the LEDs in a well from 0 to 255
        experiment_data(colum, row).intensity = 122;
        %if mod(colum, 2) == 1
        %    experiment_data(colum, row).intensity = ((row)/2)*20*(1-mod(row,2));
        %else
        %    experiment_data(colum, row).intensity = (((row+1)/2)*20+120)*mod(row,2); 
        %end
        % The number of periods as a interger from 1 to 65536
        experiment_data(colum, row).periods = 1;
        % The number of periods as a interger from 1 to 65536
        experiment_data(colum, row).offset = 1;
        
        % The duration in seconds of the low section of the pulse modulated
        % signal, from 1 to 65536
        experiment_data(colum, row).t_interpulse = 1;
        % The duration in seconds of the high section of the pulse modulated
        % signal, from 1 to 65536
        experiment_data(colum, row).t_pulse = 65532;
    end
end

promt = 'Input experiment name:  ';
user_entry = input(promt, 's');
file_name = ['experiment_files/', date , '-', user_entry, '.mat'];
save(file_name, 'experiment_data');
plotLedSelector(experiment_data);
