%% createExperiment
%   creates a .mat file with experiment data that can be flashed by
%   FlashExperiment.m. Also returns the experiment. n is the number of
%   individual LEDs on the OptoPlate. If only 1 color is used, 2
%   dimensional can be used, if 2 or 3 colors is used all the matrixes must
%   3 dimensional.
% Function configurations
%   - createExperiment(amplitudes, pulse_numbs, pusle_start_times,
%   pulse_high_times, pulse_low_times, wait_for_signal[optional]) - Create experiment with only one level of pulses
%
%   - createExperiment(amplitudes, pulse_numbs, pusle_start_times,
%   pulse_high_times, pulse_low_times, subpulse_high_times,
%   subpulse_low_times, wait_for_signal[optional]) - Create experiment with two levle of pulses
%
% Parameters
% - amplitudes [(n by) 8 by 12 matrix of unsigned 8 bit integer] - light intensity of
%       each LED, 255 - max light intensity and 0 - no light
% - pulse_numbs [(n by) 8 by 12 matrix of unsigned 16 bit integer] - number of pulses
%       for each LED
% - pusle_start_times [(n by) 8 by 12 matrix of unsigned 16 bit integer] - time in
%       seconds before sequence of pulses starts
% - pulse_high_times [(n by) 8 by 12 matrix of unsigned 16 bit integer] - time in
%       seconds for high phase of pulse
% - pulse_low_times [(n by) 8 by 12 matrix of unsigned 16 bit integer] - time in
%       seconds for low phase of pulse
% - subpulse_high_times [(n by) 8 by 12 matrix of unsigned 16 bit integer] - time in
%       seconds for high phase of subpulse
% - subpulse_low_times [(n by) 8 by 12 matrix of unsigned 16 bit integer] - time in
%       seconds for low phase of subpulse
% - wait_for_signal [boolean] - if set to true the OptoPlate will wait for the stating code 0xC4 
%       to be sent over Serial before starting the experiment. A function
%       that does this can be found in OptoPlateDriver


function experiment = createExperiment(varargin)

global xlsx_folder

switch length(varargin)
    % Include subpulses
    case 7
        experiment.amplitudes= varargin{1};
        experiment.pulse_numbs = varargin{2};
        experiment.pulse_start_times = varargin{3};
        experiment.pulse_high_times = varargin{4};
        experiment.pulse_low_times = varargin{5};
        experiment.subpulse_high_times = varargin{6};
        experiment.subpulse_low_times = varargin{7};
        experiment.wait_for_serial = false;
    case 8
        experiment.amplitudes= varargin{1};
        experiment.pulse_numbs = varargin{2};
        experiment.pulse_start_times = varargin{3};
        experiment.pulse_high_times = varargin{4};
        experiment.pulse_low_times = varargin{5};
        experiment.subpulse_high_times = varargin{6};
        experiment.subpulse_low_times = varargin{7};
        experiment.wait_for_serial = varargin{8};
    % Only pulses
    case 5
        experiment.amplitudes= varargin{1};
        experiment.pulse_numbs = varargin{2};
        experiment.pulse_start_times = varargin{3};
        experiment.pulse_high_times = varargin{4};
        experiment.pulse_low_times = varargin{5};
        experiment.subpulse_high_times = varargin{4};
        experiment.subpulse_low_times = varargin{4};
        experiment.wait_for_serial = false;
    case 6
        experiment.amplitudes= varargin{1};
        experiment.pulse_numbs = varargin{2};
        experiment.pulse_start_times = varargin{3};
        experiment.pulse_high_times = varargin{4};
        experiment.pulse_low_times = varargin{5};
        experiment.subpulse_high_times = varargin{4};
        experiment.subpulse_low_times = varargin{4};
        experiment.wait_for_serial = varargin{6};
    otherwise
        error('Error: Invalid number of input parameters');
end
fn = fieldnames(experiment); 
fn(8) = [];%Test all parameres except for wait_for_serial
multi_led = true;
if(ismatrix(experiment.amplitudes))
    multi_led = false;
    for k=1:numel(fn)
        experiment.(fn{k}) = reshape(experiment.(fn{k}), [1, 8, 12]);
    end
end
led_numb = size(experiment.amplitudes, 1);
if(led_numb > 3)
    error('Error: input parameter "amplitudes" cannot be bigger then 3 by 8 by 12');
end
max_value = [255, 65535, 65535, 65535, 65535, 65535, 65535];
for k=1:numel(fn)
    % Test input parameter matrix size
    if multi_led && ~isequal(size(experiment.(fn{k})), [led_numb, 8, 12])
        error(['Error: input parameter "', fn{k}, '" is not an ', num2str(led_numb), ' by 8 by 12 matrix.'])
    elseif ~multi_led && ~isequal(size(experiment.(fn{k})), [1, 8, 12])
        error(['Error: input parameter "', fn{k}, '" is not an 8 by 12 matrix.'])
        % Test input parameter for nonintegers
    elseif ~isequal(floor(experiment.(fn{k})), experiment.(fn{k}))
        error(['Error: input parameter "' fn{k}, '" is not a matrix of integers.'])
        % Test input parameter for values outside of range
    elseif any(experiment.(fn{k}) > max_value(k), 'all')
        error(['Error: input parameter "' fn{k}, '" contanin value(s) greater then ', num2str(max_value(k)), '.'])
    elseif any(experiment.(fn{k}) < 0, 'all')
        error(['Error: input parameter "' fn{k}, '" contanin value(s) smaller then 0.'])
    end
end

if exist('xlsx_folder','var')
    [file_name,path] = uiputfile(fullfile(xlsx_folder,'\*.mat'));
else
    [file_name,path] = uiputfile('experiment_files/.mat');
end

save([path, file_name], 'experiment');

end
