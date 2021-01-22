function data_out = get_led_patterns(experiment)

% Assuming LED 1 and 2 are same, show only LED 1
led = 1;

% Get experiment parameters
amplitudes = experiment.amplitudes;
pulse_numbs = experiment.pulse_numbs;
pulse_start_times = experiment.pulse_start_times;
pulse_high_times = experiment.pulse_high_times;
pulse_low_times = experiment.pulse_low_times;
subpulse_high_times = experiment.subpulse_high_times;
subpulse_low_times = experiment.subpulse_low_times;

% Get rid of subpulses (too fine to plot)
subpulse_high_times = pulse_high_times;
subpulse_low_times = pulse_low_times;

% Create 96 well plate map
R = {'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H'};
C = num2cell(1:12);
C = cellfun(@(x) sprintf('%02d',x),C,'UniformOutput',false);
C = string(C);
[c, r] = ndgrid(1:numel(C),1:numel(R));
well_map = [R(r(:)).' C(c(:)).'];
well_map = join(well_map);
well_map = strrep(well_map,' ','');
well_map = reshape(well_map,12,8)';

% Initialize cell array to store LED intensity vs time
data_out = cell(96,5);
idx = 1;

for row = 1:8
    for col = 1:12
        
        % Get well name from 96 well plate mapmap
        well_temp = well_map(row,col);        
        
        % Get intensity and time info for well
           [intensity_temp, time_temp] = generateLedPattern(...
            amplitudes(led,row,col), pulse_numbs(led,row,col), pulse_start_times(led,row,col),...
            pulse_high_times(led,row,col), pulse_low_times(led,row,col),subpulse_high_times(led,row,col),...
            subpulse_low_times(led,row,col));
        
        % If well not empty, save info to cell array
%         if sum(time_temp)>0
            data_out{idx,1} = well_temp;
            data_out{idx,2} = regexp(well_temp,'[A-Z]','match');
            data_out{idx,3} = regexp(well_temp,'\d*','match');
            data_out{idx,4} = time_temp;
            data_out{idx,5} = intensity_temp;
%         end
        idx = idx + 1;
    end
end

% Delete empty rows and convert cell array to table
loc=cellfun('isempty', data_out(:,1));
data_out = cell2table(data_out,'VariableNames',{'well','row','column','time','intensity'});

% Clean up table
data_out(loc,:) = [];
data_out.well = string(data_out.well);
toc
