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
            experimnet_data = varargin(1);
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
    totHeight = (height+padding)*8;
    fig = uifigure('Name', 'Select LED', 'Position',[10 50 totWidth+20 totHeight+20]);
    f_plot = figure();

    btn_event(f_plot, experimnet_data, 1, 1)
    for x = 1:12
       for y = 1:8
        uibutton(fig,'push',...
                   'Text', [letters(y), num2str(x)],...
                   'Position',[10+(x-1)*(width+padding), totHeight+10 - y*(height+padding), width, height],...
                   'ButtonPushedFcn', @(btn,event)  btn_event(f_plot, experimnet_data, x,y) );
       end
    end
end

function btn_event(f_plot, experimnet_data, x, y)
    letters = 'ABCDEFGH';
    figure(f_plot);
    plotLedPattern(experimnet_data.amplitude(y, x), experimnet_data.pulse_numb(y, x), experimnet_data.pusle_start_time(y, x), experimnet_data.pulse_high_time(y, x), experimnet_data.pulse_low_time(y, x), experimnet_data.subpulse_high_time(y, x), experimnet_data.subpulse_low_time(y, x));
    title([letters(y), num2str(x)]);
end


