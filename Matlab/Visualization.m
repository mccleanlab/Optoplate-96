
[file, path] = uigetfile('.mat','Select LED pattern data');
phaseData = load([path file]);
phaseData = phaseData.phaseData;

plotLeds(phaseData)


function plotLED(LEDindex, name, phaseData)
    plotPhases(phaseData(LEDindex))
    title(['LED ', name, ' pattern'])
end

function plotLeds(phaseData)


letters = 'ABCDEFGH';

width = 30;
height = 25
padding = 5;


totWidth = (width+padding)*12;
totHeight = (height+padding)*8;
fig = uifigure('Name', 'Select LED', 'Position',[10 50 totWidth+20 totHeight+20]);
figure()

plotLED(1, 'A1', phaseData)

for x = 1:12
   for y = 1:8
    uibutton(fig,'push',...
               'Text', [letters(y), num2str(x)],...
               'Position',[10+(x-1)*(width+padding), totHeight+10 - y*(height+padding), width, height],...
               'ButtonPushedFcn', @(btn,event) plotLED((y-1)*12+x, [letters(y), num2str(x)], phaseData));
   end
end

end

