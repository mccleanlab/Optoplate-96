%% plotLedPattern
%   Plots the LED light intensities of one LED
% Parameters
% - amplitude[unsigned 8 bit integer] - light intensity of
%       each LED, 255 - max light intensity and 0 - no light
% - pulse_numb [unsigned 16 bit integer] - number of pulses for each LED
% - pusle_start_time [unsigned 16 bit integer] - time in seconds before 
%       sequence of pulses starts
% - pulse_high_time [unsigned 16 bit integer] - time in seconds for high 
%       phase of pulse
% - pulse_low_time [unsigned 16 bit integer] - time in seconds for low 
%       phase of pulse
% - subpulse_high_time [unsigned 16 bit integer] - time in seconds for high
%       phase of subpulse
% - subpulse_low_time [unsigned 16 bit integer] - time in seconds for low 
%       phase of subpulse
function plotLedPattern(amplitude,... 
                        pulse_numb, pusle_start_time,...
                        pulse_high_time, pulse_low_time,... 
                        subpulse_high_time, subpulse_low_time)
    [a, t] = generateLedPattern(amplitude, pulse_numb, pusle_start_time, pulse_high_time, pulse_low_time, subpulse_high_time, subpulse_low_time);
    plot(t,a);
end

