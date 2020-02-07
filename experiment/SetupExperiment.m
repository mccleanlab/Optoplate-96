import visualization.*

led.intensity = 0; 
led.periods = 0;
led.offset = 0;
led.t_interpulse = 0;
led.t_pulse = 0;

experimnet_data = repmat(led,8,12);
length = 1;
% Loop through the leds
for colum = 1:8
    for row = 1:12
        % Intensity of the LEDs in a well from 0 to 255
        experimnet_data(colum, row).intensity = randi([0, 255], [1, length]);
        % The number of periods as a interger from 1 to 65536
        experimnet_data(colum, row).periods = randi([0, 255], [1, length]);
        % The number of periods as a interger from 1 to 65536
        experimnet_data(colum, row).offset = randi([0, 255], [1, length]);
        
        % The duration in seconds of the low section of the pulse modulated
        % signal, from 1 to 65536
        experimnet_data(colum, row).t_interpulse = randi([1, 255], [1, length]);
        % The duration in seconds of the high section of the pulse modulated
        % signal, from 1 to 65536
        experimnet_data(colum, row).t_pulse = randi([1, 3], [1, length]);
    end
end

promt = 'Input experiment name:  ';
user_entry = input(promt, 's');
file_name = ['experiment_files/', date , '-', user_entry, '.mat'];
save(file_name, 'experimnet_data');
plotLedSelector(experimnet_data);
