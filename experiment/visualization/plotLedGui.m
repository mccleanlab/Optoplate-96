%% plotLedGui
%   Plots the light intensity pattern of one LED and displays a GUI for selecting LED to plot
% Function configurations
%   - plotLedGui() - Open file explorer and select experiment
%   - plotLedGui(experimnet_data) - Give an experiment created from
%       createExperiment.m
% Parameteres
% - experimnet_data [struct] struct created by createExperiment.m 
function[] = plotLedGui(varargin)
    switch length(varargin)
        case 0
            [file, path] = uigetfile('experiment_files/*.mat','Select LED experiment file');
            experimnet_data = load([path, file]);
            experimnet_data = experimnet_data.experiment;
        case 1
            experimnet_data = varargin{1};
        otherwise
            error('Invalid number of input parameters');
    end
    letters = 'ABCDEFGH';
    
    %Dimensions of buttons
    width = 30;
    height = 25;
    padding = 5;
    
    %Dimensions of navigation window
    totWidth = (width+padding)*12;
    totHeight = (height+padding)*8+ 30;
    fig = uifigure('Name', 'Select LED', 'Position',[10 50 totWidth+20 totHeight+20]);
    f_plot = figure();
    selected_led = 1;
    selected_x = 1;
    selected_y = 1;
    btn_event(1, 1)
    for led = 1:size(experimnet_data.amplitudes, 1)
         uibutton(fig,'push','Text', ['LED', num2str(led)],...
             'Position',[10+(led-1)*(40+padding), 5, 40, 25],...
             'ButtonPushedFcn', @(btn,event) led_btn_event(led));
    end
    for x = 1:12
       for y = 1:8
        uibutton(fig,'push',...
                   'Text', [letters(y), num2str(x)],...
                   'Position',[10+(x-1)*(width+padding), totHeight+10 - y*(height+padding), width, height],...
                   'ButtonPushedFcn', @(btn,event)  btn_event(x,y) );
       end
    end
    
    function led_btn_event(led)
        selected_led = led;
        btn_event(selected_x, selected_y)
    end
    function btn_event(x, y)
        selected_x = x;
        selected_y = y;
        figure(f_plot);
        plotLedPattern(experimnet_data.amplitudes(selected_led, y, x), experimnet_data.pulse_numbs(selected_led, y, x), experimnet_data.pulse_start_times(selected_led, y, x), experimnet_data.pulse_high_times(selected_led, y, x), experimnet_data.pulse_low_times(selected_led, y, x), experimnet_data.subpulse_high_times(selected_led, y, x), experimnet_data.subpulse_low_times(selected_led, y, x));
        title(['LED', num2str(selected_led), ' ', letters(y), num2str(x)]);
end
end




