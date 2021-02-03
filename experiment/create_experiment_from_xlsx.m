%% Setup
clearvars; close all; clc
addpath('visualization');
global xlsx_folder % Make global to send to uiputfile() in createExperiment()

%% Flip wells along x-axis if mounting optoPlate upside-down on microscope
flip_horizontal = true;
wait_for_serial = true;

%% Load xlsx file with optoPlate configuration
[file, xlsx_folder] =  uigetfile('.xlsx','Select plate map','MultiSelect','on');
opts = detectImportOptions([xlsx_folder file]);
opts = setvartype(opts, 'char');
opts.Sheet = 'optoPlate_config';
opts.DataRange = 'A1';
optoPlate_config = readtable([xlsx_folder file], opts);

% Loop through possible LEDs and get optoPlate configuration
for n = 1:3
    % Get amplitudes
    [i,j] = find(strcmp(['LED' num2str(n) '_amplitudes'],optoPlate_config{:,:}));
    amplitudes_temp = str2double(optoPlate_config{(i+1:i+8),(j+1:j+12)});
    if flip_horizontal==true
        amplitudes_temp = fliplr(amplitudes_temp);
    end
    if ~isnan(amplitudes_temp)
        amplitudes(n,:,:) = amplitudes_temp;
    end
    
    % Get pulse start times
    [i,j] = find(strcmp(['LED' num2str(n) '_pulse_start_times'],optoPlate_config{:,:}));
    pulse_start_times_temp = str2double(optoPlate_config{(i+1:i+8),(j+1:j+12)});
    if flip_horizontal==true
        pulse_start_times_temp = fliplr(pulse_start_times_temp);
    end
    if ~isnan(pulse_start_times_temp)
        pulse_start_times(n,:,:) = pulse_start_times_temp;
    end
    
    % Get number of pulses
    [i,j] = find(strcmp(['LED' num2str(n) '_pulse_numbs'],optoPlate_config{:,:}));
    pulse_numbs_temps = str2double(optoPlate_config{(i+1:i+8),(j+1:j+12)});
    if flip_horizontal==true
        pulse_numbs_temps = fliplr(pulse_numbs_temps);
    end
    if ~isnan(pulse_numbs_temps)
        pulse_numbs(n,:,:) = pulse_numbs_temps;
    end
    
    % Get pulse high times
    [i,j] = find(strcmp(['LED' num2str(n) '_pulse_high_times'],optoPlate_config{:,:}));
    pulse_high_times_temp = str2double(optoPlate_config{(i+1:i+8),(j+1:j+12)});
    if flip_horizontal==true
        pulse_high_times_temp = fliplr(pulse_high_times_temp);
    end
    if ~isnan(pulse_high_times_temp)
        pulse_high_times(n,:,:) = pulse_high_times_temp;
    end
    
    % Get pulse low times
    [i,j] = find(strcmp(['LED' num2str(n) '_pulse_low_times'],optoPlate_config{:,:}));
    pulse_low_times_temp = str2double(optoPlate_config{(i+1:i+8),(j+1:j+12)});
    if flip_horizontal==true
        pulse_low_times_temp = fliplr(pulse_low_times_temp);
    end
    if ~isnan(pulse_low_times_temp)
        pulse_low_times(n,:,:) = pulse_low_times_temp;
    end
    
    % Get subpulse high times
    [i,j] = find(strcmp(['LED' num2str(n) '_subpulse_high_times'],optoPlate_config{:,:}));
    subpulse_high_times_temp = str2double(optoPlate_config{(i+1:i+8),(j+1:j+12)});
    if flip_horizontal==true
        subpulse_high_times_temp = fliplr(subpulse_high_times_temp);
    end
    if ~isnan(subpulse_high_times_temp)
        subpulse_high_times(n,:,:) = subpulse_high_times_temp;
    end
    
    % Get subpulse low times
    [i,j] = find(strcmp(['LED' num2str(n) '_subpulse_low_times'],optoPlate_config{:,:}));
    subpulse_low_times_temp = str2double(optoPlate_config{(i+1:i+8),(j+1:j+12)});
    if flip_horizontal==true
        subpulse_low_times_temp = fliplr(subpulse_low_times_temp);
    end
    if ~isnan(subpulse_low_times_temp)
        subpulse_low_times(n,:,:) = subpulse_low_times_temp;
    end
end


%% Create and save experiment file from optoPlate configuration
if exist('subpulse_high_times','var') == 1 && exist('subpulse_low_times','var') == 1 % Create experiment with subpulses
    experiment = createExperiment(amplitudes, pulse_numbs, pulse_start_times, pulse_high_times, pulse_low_times,subpulse_high_times, subpulse_low_times,wait_for_serial);
else % Create experiment without subpulses
    experiment = createExperiment(amplitudes, pulse_numbs, pulse_start_times, pulse_high_times, pulse_low_times,wait_for_serial);
end

%% Plot experiment
% plotLedGui(experiment);