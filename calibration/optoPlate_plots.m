clearvars; clc; close all
%%
LED_round_1 = load([pwd '\measurements\' 'measurements_round_1.mat']);
LED_round_1 = LED_round_1.measurements_out.LED;
LED_round_1.round(:,1) = 1;

LED_round_3 = load([pwd '\measurements\' 'measurements_round_3.mat']);
LED_round_3 = LED_round_3.measurements_out.LED;
LED_round_3.round(:,1) = 3;

LED = [LED_round_1; LED_round_3];

clear g; close all
g = gramm('x',LED.intensity,'color',LED.round);
g.stat_bin('geom','bar','dodge',0);
g.set_names('x','Intensity (µW/cm^2)','y','Count','color','Round')
g.set_text_options('font','arial','interpreter','tex');
g.draw()

%%
LED_uncalibrated = load([pwd '\measurements\' 'measurements_uncalibrated.mat']);
LED_uncalibrated = LED_uncalibrated.measurements_out.LED;
LED_uncalibrated.condition(:,1) = "Uncalibrated";

LED_calibrated = load([pwd '\measurements\' 'measurements_calibrated.mat']);
LED_calibrated = LED_calibrated.measurements_out.LED;
LED_calibrated.condition(:,1) = "Calibrated";

LED = [LED_uncalibrated; LED_calibrated];

clear g; close all
g = gramm('x',cellstr(LED.condition),'y',LED.intensity);
g.stat_boxplot();
g.set_names('x','','y','Intensity (µW/cm^2)','color','Round');
g.set_text_options('font','arial','interpreter','tex');
% g.axe_property('YLim',[0 200]);
g.draw();

p = vartestn(LED.intensity,LED.condition,'TestType','LeveneAbsolute');

%%
measurements = load([pwd '\measurements\' 'aaa.mat']);
measurements = measurements.measurements_out.measurements;
measurements.label = strcat("Well set ", num2str(measurements.well_set)," LED ", num2str(measurements.LED));

cmap = hsv(12)*0.95;
idx = randperm(12);
cmap = cmap(idx,:); cmap = repmat(cmap,96/12,1);

clear g; close all
g = gramm('x',measurements.sample,'y',measurements.intensity_raw*1E6,'row',cellstr(measurements.label));
g.stat_summary();
g.set_color_options('map',[90 90 90]/255);
g.set_line_options('base_size',1);
g.set_names('x','Time','y','Intensity (µW/cm^2)','color','','row','');
g.draw();

g.update('color',cellstr(measurements.well),'subset',~isnan(measurements.intensity))
g.geom_point();
g.set_color_options('map',cmap);
g.axe_property('YLim',[0 300]);
g.set_names('x','Time','y','Intensity (µW/cm^2)','color','','row','');
g.no_legend();
g.draw(); hold on

measurements2label = measurements(~isnan(measurements.intensity),:);
well_label_y = grpstats(measurements2label,{'well','label'},'max','DataVars',{'intensity'});
well_label_x = grpstats(measurements2label,{'well','label'},'mean','DataVars',{'sample'});
measurements2label = join(well_label_x,well_label_y);

g.update('x',measurements2label.mean_sample - 3,'y',measurements2label.max_intensity + 10,'row',cellstr(measurements2label.label),'label',measurements2label.well);
g.geom_label('FontSize',10);
g.set_color_options('map',[80 80 80]/255);
g.set_names('x','Time','y','Intensity (µW/cm^2)','color','','row','');
g.draw()