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

%% generateLedPattern
%   Returns a, the light intensities of one LED over time t
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
function [a, t] = generateLedPattern(amplitude,... 
                                    pulse_numb, pusle_start_time,...
                                    pulse_high_time, pulse_low_time,... 
                                    subpulse_high_time, subpulse_low_time)
    pulse_a = [0];
    pulse_t = [0];
    if subpulse_high_time >= pulse_high_time 
        pulse_a = [pulse_a, amplitude, amplitude, 0];
        pulse_t = [pulse_t, 0,  subpulse_high_time, subpulse_high_time];
    else
        numb_subpulses = floor(pulse_high_time/(subpulse_high_time + subpulse_low_time));
        % Make one subpulse
        subpulse_a = [amplitude, amplitude, 0, 0];
        subpulse_t = [0,subpulse_high_time, subpulse_high_time, subpulse_high_time + subpulse_low_time];
        % Repeat the subpulse into one pulse
        for i = 1:numb_subpulses
           pulse_a = [pulse_a, subpulse_a];
           pulse_t = [pulse_t, (pulse_t(end)+subpulse_t)];
        end
        % Handle edge cases of subpulse in pulse
        if pulse_t(end) ~= pulse_high_time && pulse_t(end)+subpulse_high_time > pulse_high_time
            pulse_a = [pulse_a, amplitude, amplitude, 0];
            pulse_t = [pulse_t, pulse_t(end), pulse_high_time, pulse_high_time];
        elseif pulse_t(end)+subpulse_high_time < pulse_high_time
            pulse_a = [pulse_a, amplitude, amplitude, 0, 0];
            pulse_t = [pulse_t, pulse_t(end), pulse_t(end)+subpulse_high_time, pulse_t(end)+subpulse_high_time, pulse_high_time];
        end
    end
    % Add low phase of pusle
    pulse_a = [pulse_a, 0];
    pulse_t = [pulse_t, pulse_t(end)+ pulse_low_time]; 
    % Create final output
    a = [0, 0];
    t = [0, pusle_start_time];
    % Repeat pusle into final output
    for i = 1:pulse_numb
       a = [a, pulse_a];
       t = [t, t(end) + pulse_t];
    end
end
