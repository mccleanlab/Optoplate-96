%% Example - OptoPlate
% This code provide an example on how to create a experiment file for the
% OptoPlate configured with LEDs of one color.

addpath('visualization');

subPulses = false; % Enable/disable subpulses

% Set a nonzero amplitude on every other LED
amplitudes= zeros(8, 12);
for i = 1:8
   for j = 1:12
       amplitudes(i, j) = mod(i+j, 2)*20;
   end
end

% Loop through the pulses 5 times
pulse_numbs = ones(8, 12)* 5; 
% Wait 2 sec before starting pulse sequence
pusle_start_times = ones(8, 12)*2;
% Let LED be high for 10 seconds
pulse_high_times = ones(8, 12)*10;
% Pause for 4 second between each pulse
pulse_low_times = ones(8, 12)*4;

if subPulses
    % During LED high time, let the LED be on for 1 sec and off for 2 sec
    subpulse_high_times = ones(8, 12)*1;
    subpulse_low_times = ones(8, 12)*2;
    
    % Create and save experiment
    ex = createExperiment(amplitudes, pulse_numbs, pusle_start_times, pulse_high_times, pulse_low_times,subpulse_high_times, subpulse_low_times);
    % Plot experiment
    plotLedGui(ex);
else
    % Create and save experiment
    ex = createExperiment(amplitudes, pulse_numbs, pusle_start_times, pulse_high_times, pulse_low_times);
    % Plot experiment
    plotLedGui(ex);
end

