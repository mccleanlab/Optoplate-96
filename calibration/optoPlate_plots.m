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

