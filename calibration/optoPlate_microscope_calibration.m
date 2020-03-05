clearvars;clc; close all;
%%
amp_thresh = 0.05; % Fraction of max intensity threshold for segmenting wells
min_peak_dist = 2;
num_wells = 48;
%% 
input_values = [];
input_values = repmat(20:20:240,4,1);
input_values = reshape(input_values',48,1);

%% Load
[filenames, path] = uigetfile('.csv','Select files','Multiselect','On');

if ~iscell(filenames)
    filenames = {filenames};
end

nFiles = numel(filenames);

%%
R = {'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H'};
C = num2cell(1:12);
C = cellfun(@(x) sprintf('%02d',x),C,'UniformOutput',false);
C = string(C);
[c, r] = ndgrid(1:numel(C),1:numel(R));

well_map = [R(r(:)).' C(c(:)).'];
well_map = join(well_map);
well_map = strrep(well_map,' ','');
well_map = reshape(well_map,12,8)';

well_map(1:2:end,:) = flip(well_map(1:2:end,:),2);
well_list = reshape(well_map',96,1);

%%
close all
measurements = {};
cmap = lines(num_wells);

for f = 1:nFiles
    file = filenames{f};
    
    if contains(file,'LED')
        LED = regexp(file,'LED01|LED02|LED00','match');
        LED = regexp(LED,'\d*','match');
        LED = str2double(LED{:});
    else
        LED = 0;
    end
    
    
    well_set = regexp(file,'_WELLS\d*','match');
    well_set = string(regexp(well_set,'\d*','match'));
    well_set = str2double(well_set{:});
    
    
    
    if contains(file,'ROUND')
        cal_round = regexp(file,'ROUND\d*_','match');
        cal_round = string(regexp(cal_round,'\d*','match'));
        cal_round = str2double(cal_round{:});
    else
        cal_round = 0;
    end
    
    opts = detectImportOptions([path file]);
    opts = setvartype(opts, 'char');
    opts.Delimiter = {' ',',',';'};
    measurements_raw = table();
    measurements_raw = readtable([path file],opts);
    nSamples = size(measurements_raw,1);
    
    measurements_temp = table();
    measurements_temp.Round(1:nSamples,1) = cal_round;
    measurements_temp.LED(1:nSamples,1) = LED;
    measurements_temp.Well_set(1:nSamples,1) = well_set;
    measurements_temp.Sample(:,1) = (1:nSamples)';
    measurements_temp.Irradiance_raw(:,1) =  str2double(measurements_raw{:,6});
    
    % Preprocess measurement data by thresholding and background subtraction
    time = measurements_temp.Sample';
    irradiance = measurements_temp.Irradiance_raw;
    
    irradiance_BG = median(irradiance(irradiance<amp_thresh*max(irradiance))); % Calculate background intensity
    irradiance = irradiance - irradiance_BG; % Subtract out background intensity
    irradiance(irradiance<amp_thresh*max(irradiance)) = nan; % Threshold to exclude intensity data from outside wells
    
    % Create binary irradiance signal for peak finding
    npad = 5;
    irradiance_binary = zeros(length(irradiance) + npad,1); % Zero pad end of binary signal (if light left on at end)
    irradiance_binary(irradiance>0) = 1;
    
    % Find and count peaks in masked signal to identify wells
    [pks, locs, width] = findpeaks(irradiance_binary,'NPeaks',num_wells,'MinPeakDistance',min_peak_dist); % Find peaks from binary
    locs = locs + round(width/2); % Center peaks
    [val,idx] = min(abs(time-locs));
    well_idx = time(idx)';
    
    if numel(pks)~=num_wells
        disp(['Warning: ' num2str(numel(pks)) ' peaks detected'])
    end
    
    irradiance_binary = irradiance_binary(1:end-npad);
    
    % Calculate intensities for each identified well
    for j = 1:num_wells
        % Exclude outliers (acquired when moving sensor to well)
        irradiance_temp = irradiance(well_idx==j);
        outliers = irradiance_temp(isoutlier(irradiance_temp));
        irradiance(ismember(irradiance,outliers) & well_idx==j) = nan;
    end
    
    measurements_temp.Irradiance = irradiance;
    measurements_temp.Well_idx = well_idx;
    
    if well_set==1
        wells_used = well_list(2:2:end);
    elseif well_set==2
        wells_used = well_list(1:2:end);
    end
    
    idx2well = table();
    idx2well.Well_idx(1:num_wells,1) = 1:num_wells;
    idx2well.Well = wells_used;
    
    measurements_temp = join(measurements_temp,idx2well);
    measurements{f,1} = measurements_temp;
end

measurements = vertcat(measurements{:});
measurements = sortrows(measurements,{'LED','Well'},{'Ascend','Ascend'});

%%
LED = grpstats(measurements,{'Well','LED'},{'nanmax'},'DataVars','Irradiance');
LED.Properties.RowNames={}; LED.GroupCount = [];
idx = contains(LED.Properties.VariableNames,'Irradiance');
LED.Properties.VariableNames(idx) = {'Irradiance'};

if cal_round==0 && ~isempty(input_values)
    
    LED.input_values = input_values;
    
elseif cal_round~=0 % Calculate calibration values
    
    % Interleave LED intensities following 96 well layout
    maxCal = 255;
    
    % Format intensities for optoPlate
    intensities(:,1) = LED.Irradiance(LED.LED==1);
    intensities(:,2) = LED.Irradiance(LED.LED==2);
    
    % Format intensities for display
    intensities_display(1:2:191) = intensities(:,1);
    intensities_display(2:2:192) = intensities(:,2);
    intensities_display = reshape(intensities_display,24,8)';
    intensities_display = intensities_display;
    
    % Scale intensities by calibration values from previous round (if applicable)
    if cal_round == 1
        intensities_round_1 = intensities;
        save([path 'intensities_round_1'],'intensities_round_1');
        cal_previous = ones([96, 2])*255;
        minIntensity = min(intensities(:));
        a = 1;
    else
        % Load previous values
        cal_previous = load([path 'cal_round_' num2str(cal_round - 1)]);
        cal_previous = cal_previous.cal;
        
        intensities_round_1 = load([path 'intensities_round_1']);
        intensities_round_1 = intensities_round_1.intensities_round_1;
        minIntensity = min(intensities_round_1(:));
        a = 0.6;
    end
    
    % Calculate calibration values
    cal = cal_previous/maxCal - a*(intensities - minIntensity)./intensities_round_1;
    cal = round(cal*maxCal);
    
    cal(cal>255) = 255;
    cal(cal<0) = 0;
    
    % Reformat calibration values for display
    cal_display(1:2:191) = cal(:,1);
    cal_display(2:2:192) = cal(:,2);
    cal_display = reshape(cal_display,24,8)';
    
    % Save calibration values
    save([path 'cal_round_' num2str(cal_round)],'cal');
end


%% Plot
close all
figure('Position',[100 100 1200 800])

if cal_round==0 && ~isempty(input_values)
    clear g; close all; figure('Position',[100 100 1200 800])
    g = gramm('x',LED.input_values,'y',LED.Irradiance,'subset',~isnan(LED.Irradiance));
    g.stat_summary('type','std','geom',{'point','black_errorbar'});
    g.set_title('Irradiance vs input value');
    g.set_names('x','Input value','y', ['Intensity' newline '(mean ± std)']);
    g.stat_glm('disp_fit',true)
    g.draw();
    
    glm = fitglm(LED.input_values,LED.Irradiance); disp(glm)
    rsquared = glm.Rsquared.Ordinary; disp(rsquared)
    
elseif cal_round~=0
    clear g; close all; figure('Position',[100 100 1200 800])
    
    ymax = 1.25*max(LED.Irradiance);
    rowlist = 'A':'H';
    column_list = string(cellfun(@(x) sprintf('%02d',x),num2cell(1:12),'UniformOutput',false));
    xlabeldisp(1:2:23) = string(1:12);
    xlabeldisp(2:2:24) = repmat("",1,12);
    
    % Heatmap of intensities following 96-well layout
    subplot(2,1,1);
    h = heatmap(intensities_display);
    h.YDisplayLabels = cellstr(rowlist(:));
    h.XDisplayLabels = xlabeldisp;
    h.Title = 'Mean LED intensity';
    
    % Heatmap of calibration values following 96-well layout
    subplot(2,1,2);
    h = heatmap(cal_display);
    h.YDisplayLabels = cellstr(rowlist(:));
    h.XDisplayLabels = xlabeldisp;
    h.Title = ['Calibration values: round ' num2str(cal_round)];
    savefig(gcf,[path 'heatmap_round_' num2str(cal_round)]);
    
    % Plot irradiance
    clear g; figure
    g = gramm('x',cellstr(LED.Well),'y',LED.Irradiance,...
        'color',cellstr(regexp(LED.Well,'[a-zA-Z]*','match')),'subset',~isnan(LED.Irradiance));
    g.facet_grid(LED.LED,[]);
    g.geom_point();
    g.set_title(['Irradiance per well: round ' num2str(cal_round)]);
    g.axe_property('XTickLabelRotation',60,'YLim',[0 ymax],'Xlim',[0 97]);
    g.set_names('x','Well','y', ['Intensity' newline '(mean ± std)'],'Row','LED','Color','Row','Marker','Orientation');
    g.draw();
    savefig(gcf,[path 'intensities_round_' num2str(cal_round)]);
end

%% Plate stats
if cal_round~=0
    optoPlate_stats = table();
    optoPlate_stats.cal_round = num2str(cal_round);
    optoPlate_stats.mean = mean(LED.Irradiance);
    optoPlate_stats.std = std(LED.Irradiance);
    optoPlate_stats.CV = 100*optoPlate_stats.std/optoPlate_stats.mean;
    optoPlate_stats.max = max(LED.Irradiance);
    optoPlate_stats.min = min(LED.Irradiance);
    
    optoPlate_stats
end

%%
if cal_round~=0
    measurements_out.round = cal_round;
    measurements_out.measurements = measurements;
    measurements_out.LED = LED;
    measurements_out.cal = cal;
    measurements_out.optoPlate = optoPlate_stats;
    
    save([path 'measurements_round_' num2str(cal_round)],'measurements_out');
end