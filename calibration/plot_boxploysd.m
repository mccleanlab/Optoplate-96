clc; clearvars; close all

LED_uncalibrated = load('LED_uncalibrated.mat');
LED_uncalibrated = LED_uncalibrated.LED;
LED_uncalibrated.state(:,1) = "uncalibrated";

LED_calibrated = load('LED_calibrated.mat');
LED_calibrated = LED_calibrated.LED;
LED_calibrated.state(:,1) = "calibrated";

LED = [LED_uncalibrated; LED_calibrated];

g = gramm('x',cellstr(LED.state),'y',LED.intensity)
g.box_plot()
g.draw
