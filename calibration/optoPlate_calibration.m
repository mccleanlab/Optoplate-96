% This version allows for measurements from multiple images (eg, taken at
% different angles) to be averaged when calculating LED intensity in order
% to account for differences in intensity due to LED position vs camera

clearvars; clc; close all
%%
gamma = 0.4;
hull_thresh = 1.5;
radius_search = [12 20];
radius_fixed = 12;
displaySegmentedImages = 0;

%% Load and collect images for left (1) and right (2) LEDs
[filenames, path] = uigetfile('.scn','Select images','Multiselect','On');

if ~iscell(filenames)
    filenames = {filenames};
end

nFiles = numel(filenames);

for f = 1:nFiles
    file = filenames{f};
    
    side = regexp(file,'LED01|LED02','match');
    side = regexp(side,'\d*','match');
    side = str2double(side{:});
    
    orientation = regexp(file,'_\d*DEG','match');
    orientation = string(regexp(orientation,'\d*','match'));
    orientation = str2double(orientation{:});
    
    cal_round = regexp(file,'_ROUND\d*','match');
    cal_round = string(regexp(cal_round,'\d*','match'));
    cal_round = str2double(cal_round{:});
    
    im0 = bfopen([path file]);
    im0 = im0{1}{1};
    im0 = imrotate(im0,-orientation);
    
    im{f,1} = file;
    im{f,2} = cal_round;
    im{f,3} = side;
    im{f,4} = orientation;
    im{f,5} = im0;
end

% Load reference image
imref = imread('im_ref.tif');
disp(['Calibration round = ' num2str(cal_round)]);

%% Delete previous excel file (if applicable)
warning('off','MATLAB:xlswrite:AddSheet');

if exist(['\measurements_round_' num2str(1) '.xlsx'])~=0
    delete(['measurements_round_' num2str(1) '.xlsx']);
end

%% Register loaded images to reference image
tic
% Simplify reference image for registration
imref_hull = imbinarize(imref);
imref_hull = im2double(bwconvhull(imref_hull));

% Initialize variables
[optimizer, metric] = imregconfig('multimodal');

% Simplify LED images and register to reference image
for f = 1:nFiles
    % Simplify image
    im2reg = im{f,5};
    im2reg_hull = imbinarize(im2reg,hull_thresh*graythresh(im2reg));
    im2reg_hull = im2double(bwconvhull(im2reg_hull));
    
    % Initial registration of simplified images
    xform = imregtform(im2reg_hull,imref_hull,'similarity',optimizer,metric);
    imreg = imwarp(im2reg,xform,'OutputView',imref2d(size(imref_hull)));
    
    % Secondary registration
    im2reg_hull = imbinarize(imreg);
    im2reg_hull = im2double(bwconvhull(im2reg_hull));
    
    xform = imregtform(im2reg_hull,imref_hull,'similarity',optimizer,metric);
    imreg = imwarp(imreg,xform,'OutputView',imref2d(size(imref_hull)));
    
    im{f,6} = imreg;
    im{f,7} = xform;
    
end
toc

%% Find and measure LEDs from registered images
measurements = {};
LED0 = table();

% Cycle through left (1) and right (2) images
for f = 1:nFiles
    % Specify image to measure
    im2measure = im{f,6};
    
    % Find LEDs as bright circles
    im2circle = imadjust(im2measure,[],[],gamma);
    im2circle = imbinarize(imbilatfilt(im2circle));
    
    LED0 = table();
    [LED0.center, LED0.radius, LED0.metric] = imfindcircles(im2circle,radius_search,'ObjectPolarity','bright','Sensitivity',0.85,'Method','TwoStage');
    
    LED0 = splitvars(LED0,'center','NewVariableNames',{'center_x','center_y'});
    LED0.radius(:) = radius_fixed;
    LED0.side(:) = im{f,3};
    LED0.orientation(:) = im{f,4};
    
    % Pick 96 best circles
    LED0 = sortrows(LED0,'metric');
    LED0 = LED0(1:96,:);
    
    % Sort into 96-well format
    LED0 = sortrows(LED0,'center_y','ascend');
    rowlist = 'A':'H';
    column_list = string(cellfun(@(x) sprintf('%02d',x),num2cell(1:12),'UniformOutput',false));
    
    for i = 1:8
        idx = (1:12) + 12*(i-1);
        LED0(idx,:) = sortrows(LED0(idx,:),'center_x','ascend');
        LED0.row(idx) = string(rowlist(i));
        LED0.column(idx) = column_list;
    end
    
    LED0.well = strcat(LED0.row,LED0.column);
    
    % Measure wells
    [h, w] = size(im2measure);
    theta = 0:0.1:2*pi;
    mask_x = (LED0.radius*cos(theta) + LED0.center_x)';
    mask_y = (LED0.radius*sin(theta) + LED0.center_y)';
    
    for i = 1:96
        mask = poly2mask(mask_x(:,i),mask_y(:,i),h,w);
        m = numel(mask(mask==1));
        
        measurements0 = table();
        measurements0.well = repmat(LED0.well(i),m,1);
        measurements0.row = repmat(LED0.row(i),m,1);
        measurements0.column = repmat(LED0.column(i),m,1);
        measurements0.side = repmat(im{f,3},m,1);
        measurements0.orientation = repmat(im{f,4},m,1);
        measurements0.center_x = repmat(LED0.center_x(i),m,1);
        measurements0.center_y = repmat(LED0.center_y(i),m,1);
        measurements0.radius = repmat(LED0.radius(i),m,1);
        measurements0.intensities = double(im2measure(mask));
        measurements{f,i} = measurements0;
    end
end

% Create big table for plotting
measurements = vertcat(measurements{:});

%% Create table with average LED intensity per orientation, then take median well
LED = grpstats(measurements,{'well','row','column','side'},{'median'},'DataVars','intensities');
LED.Properties.RowNames={}; LED.GroupCount = [];
idx = contains(LED.Properties.VariableNames,'intensities');
LED.Properties.VariableNames(idx) = {'intensity'};

%% Calculate calibration values
% Interleave LED intensities following 96 well layout
maxCal = 255;

% Format intensities for optoPlate
intensities(:,1) = LED.intensity(LED.side==1);
intensities(:,2) = LED.intensity(LED.side==2);

% Format intensities for display
intensities_display(1:2:191) = intensities(:,1);
intensities_display(2:2:192) = intensities(:,2);
intensities_display = reshape(intensities_display,24,8)';
intensities_display = round(intensities_display);

% Scale intensities by calibration values from previous round (if applicable)
if cal_round == 1
    intensities_round_1 = intensities;
    save('intensities_round_1','intensities_round_1');
    cal_previous = ones([96, 2])*255;
    minIntensity = min(intensities(:));
    a = 1;
else
    % Load previous values
    cal_previous = load(['cal_round_' num2str(cal_round - 1)]);
    cal_previous = cal_previous.cal;
    
    intensities_round_1 = load('intensities_round_1');
    intensities_round_1 = intensities_round_1.intensities_round_1;
    minIntensity = min(intensities_round_1(:));
    a = 1;
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
save(['cal_round_' num2str(cal_round)],'cal');


%% Plot
close all
figure('Position',[100 100 1200 800])

ymax = 1.25*max(LED.intensity);
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
savefig(gcf,['heatmap_round_' num2str(cal_round)]);

% Plot intensity per orientation
clear g; figure
g = gramm('x',cellstr(measurements.well),'y',measurements.intensities,'color',cellstr(measurements.row),...
    'group',measurements.orientation,'marker',measurements.orientation);
g.facet_grid(measurements.side,[]);
g.stat_summary('type','std','geom',{'point'});
g.set_title(['Mean intensity per orientation: round ' num2str(cal_round)]);
g.axe_property('XTickLabelRotation',60,'YLim',[0 ymax]);
g.set_names('x','Well','y', ['Intensity' newline '(mean ± std)'],'Row','LED','Color','Row','Marker','Orientation');
g.draw();
savefig(gcf,['intensities_per_orientation_round_' num2str(cal_round)]);

% Plot intensity
clear g; figure
g = gramm('x',cellstr(LED.well),'y',LED.intensity,'color',cellstr(LED.row));
g.facet_grid(LED.side,[]);
g.stat_summary('type','std','geom',{'point'});
g.no_legend();
g.set_title(['Mean intensity: round ' num2str(cal_round)]);
g.axe_property('XTickLabelRotation',60,'YLim',[0 ymax]);
g.set_names('x','Well','y', ['Intensity' newline '(mean ± std)'],'Row','LED');
g.draw();
savefig(gcf,['intensities_round_' num2str(cal_round)]);

%% Show measured wells
% if displaySegmentedImages==1
cmap = [255 93 105; 7 182 75; 0 169 255]/255;
cdata = {};

for f = 1:nFiles
    im_out = im{f,6};
    
    measurements0 = measurements(measurements.side==im{f,3} & measurements.orientation==im{f,4},:);
    measurements0.intensities = [];
    measurements0 = unique(measurements0,'Stable');
    
    fig = figure('Name',['LED ' num2str(im{f,3}) ' ' num2str(im{f,4}) '°']); hold on
    imshow(imadjust(im_out),[]);
    viscircles([measurements0.center_x,measurements0.center_y],measurements0.radius,'LineWidth',0.2,'Color',cmap(3,:));
    
    for i = 1:96
        text(measurements0.center_x(i),measurements0.center_y(i), measurements0.well(i),'HorizontalAlignment','center','VerticalAlignment','middle','Color',cmap(1,:));
    end
    
% end
end
%% Plate stats
optoPlate = table();
optoPlate.cal_round = num2str(cal_round);
optoPlate.mean = mean(LED.intensity);
optoPlate.std = std(LED.intensity);
optoPlate.CV = 100*optoPlate.std/optoPlate.mean;
optoPlate.max = max(LED.intensity);
optoPlate.min = min(LED.intensity);

optoPlate
%%
measurements_out.round = cal_round;
measurements_out.measurements = measurements;
measurements_out.LED = LED;
measurements_out.cal = cal;
measurements_out.optoPlate = optoPlate;

save(['measurements_round_' num2str(cal_round)],'measurements_out');

%% Clean up
% clearvars -except im LED measurements cal cal_out
% autoArrangeFigures()