clearvars; clc; close all
%%
LED_round_1 = load([pwd '\measurements\OptoPlate2\' 'measurements_round_1.mat']);
LED_round_1 = LED_round_1.measurements_out.LED;
LED_round_1.round(:,1) = 1;

LED_round_2 = load([pwd '\measurements\OptoPlate2\' 'measurements_round_2.mat']);
LED_round_2 = LED_round_2.measurements_out.LED;
LED_round_2.round(:,1) = 2;

LED = [LED_round_1; LED_round_2];

clear g; close all
g = gramm('x',LED.intensity,'color',LED.round);
g.stat_bin('geom','bar','dodge',0);
g.set_names('x','Intensity (µW/cm^2)','y','Count','color','Round')
g.set_text_options('font','arial','interpreter','tex');
g.draw()

%%
LED_uncalibrated = load([pwd '\measurements\OptoPlate2\' 'measurements_uncalibrated.mat']);
LED_uncalibrated = LED_uncalibrated.measurements_out.LED;
LED_uncalibrated.condition(:,1) = "Uncalibrated";

LED_calibrated = load([pwd '\measurements\OptoPlate2\' 'measurements_calibrated.mat']);
LED_calibrated = LED_calibrated.measurements_out.LED;
LED_calibrated.condition(:,1) = "Calibrated";

LED = [LED_uncalibrated; LED_calibrated];

clear g; close all
g = gramm('x',cellstr(LED.condition),'y',LED.intensity,'color',cellstr(LED.condition));
g.set_order_options('x',0,'color',0);
g.stat_boxplot();
g.set_names('x','','y','Intensity (µW/cm^2)','color','Round');
g.set_text_options('font','arial','interpreter','tex');
% g.axe_property('YLim',[0 200]);
g.draw();

g.update('color',(LED.LED));
g.stat_summary('type','std','geom','point');
g.set_color_options('map',[50 50 50]/255);
g.draw()
p = vartestn(LED.intensity,LED.condition,'TestType','LeveneAbsolute')

%%