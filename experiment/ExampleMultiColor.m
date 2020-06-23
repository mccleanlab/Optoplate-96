%% Example Multi-Color - OptoPlate
% This code provide an example on how to create a experiment file for the
% OptoPlate configured with 3 different LED colors in each well. 
% The experiment will turn on the three LEDs in the well in turn in a blinking pattern


addpath('visualization');

subPulses = true; % Enable/disable subpulses
dim = 3;

% Set all amplitudes to 20
amplitudes= ones(dim, 8, 12)*20; 

% Loop through the pulses 5 times
pulse_numbs = ones(dim, 8, 12)* 5; 
% Wait 2 sec before starting pulse sequence
pulse_start_times = zeros(dim, 8, 12);
for i = 1:dim
    pulse_start_times(i, :, :) = ones(1,8, 12)*i;
end
% Let LED be high for 10 seconds
pulse_high_times = ones(dim, 8, 12)*10;
% Pause for 1 second between each pulse
pulse_low_times = ones(dim, 8, 12)*4;

if subPulses
    % During LED high time, let the LED be on for 1 sec and off for 2 sec
    subpulse_high_times = ones(dim, 8, 12)*1;
    subpulse_low_times = ones(dim, 8, 12)*3;
    
    % Create and save experiment
    ex = createExperiment(amplitudes, pulse_numbs, pulse_start_times, pulse_high_times, pulse_low_times,subpulse_high_times, subpulse_low_times);
    % Plot experiment
    plotLedGui(ex);
else
    % Create and save experiment
    ex = createExperiment(amplitudes, pulse_numbs, pulse_start_times, pulse_high_times, pulse_low_times);
    % Plot experiment
    plotLedGui(ex);
end

