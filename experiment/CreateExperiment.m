%% createExperiment
%   creates a .mat file with experiment data that can be flashed by
%   FlashExperiment.m. Also returns the experiment
% Parameters
% - amplitudes[8 by 12 matrix of unsigned 8 bit integer] - light intensity of
%       each LED, 255 - max light intensity and 0 - no light
% - pulse_numbs [8 by 12 matrix of unsigned 16 bit integer] - number of pulses
%       for each LED
% - pusle_start_times [8 by 12 matrix of unsigned 16 bit integer] - time in
%       seconds before sequence of pulses starts
% - pulse_high_times [8 by 12 matrix of unsigned 16 bit integer] - time in
%       seconds for high phase of pulse
% - pulse_low_times [8 by 12 matrix of unsigned 16 bit integer] - time in
%       seconds for low phase of pulse
% - subpulse_high_times [8 by 12 matrix of unsigned 16 bit integer] - time in
%       seconds for high phase of subpulse
% - subpulse_low_times [8 by 12 matrix of unsigned 16 bit integer] - time in
%       seconds for low phase of subpulse
function experiment = createExperiment( amplitudes,... 
                                        pulse_numbs, pusle_start_times,...
                                        pulse_high_times, pulse_low_times,...
                                        subpulse_high_times, subpulse_low_times)
    experiment.amplitudes= amplitudes; 
    experiment.pulse_numbs = pulse_numbs;
    experiment.pusle_start_times = pusle_start_times;
    experiment.pulse_high_times = pulse_high_times;
    experiment.pulse_low_times = pulse_low_times;
    experiment.subpulse_high_times = subpulse_high_times;
    experiment.subpulse_low_times = subpulse_low_times;
    
    fn = fieldnames(experiment);
    max_value = [255, 65535, 65535, 65535, 65535, 65535, 65535];
    for k=1:numel(fn)
        % Test input parameter matrix size
        if ~isequal(size(experiment.(fn{k})), [8, 12])
            error(['Error: input parameter "', fn{k}, '" is not a 8 by 12 matrix.'])
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
    
    [file_name,path] = uiputfile('experiment_files/.mat');
    save([path, file_name], 'experiment');

end