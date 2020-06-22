% This file creates a checker pattern that stays on for 10 seconds, off for
% 1 second, and repeats this 5 times.
addpath('visualization');

subPulses = false; % Enable/disable subpulses

amplitudes= zeros(2, 8, 12); % Turn every other LED on
for k = 1:2
    for i = 1:8
       for j = 1:12
           amplitudes(k, i, j) = mod(i+j, 2)*20;
       end
    end
end

amplitudes= ones(2, 8, 12)*10; % Turn every other LED on


% Loop through the pulses 5 times
pulse_numbs = ones(2, 8, 12)* 5; 
% Wait 2 sec before starting pulse sequence
pusle_start_times = ones(2, 8, 12)*2;
% Let LED be high for 10 seconds
pulse_high_times = ones(2, 8, 12)*10;
% Pause for 1 second between each pulse
pulse_low_times = ones(2, 8, 12)*1;

if subPulses
    % During LED high time, let the LED be on for 1 sec and off for 2 sec
    subpulse_high_times = ones(2, 8, 12)*1;
    subpulse_low_times = ones(2, 8, 12)*2;
    
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

