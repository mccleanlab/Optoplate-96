led.intensity = 0;
led.periods = 0;
led.offset = 0;
led.tInterpulse = 0;
led.tPulse = 0;
phaseData = repmat(led,1,96);

phases = 25;

for i = (1:96)
    phaseData(i).intensity = ones([phases, 1])*1;
    phaseData(i).periods = ones([phases, 1])*100;
    phaseData(i).offset = ones([phases, 1])*2;
    
    phaseData(i).tInterpulse = ones([phases, 1])*3;
    phaseData(i).tPulse = ones([phases, 1])*1000;
end

 save('phaseData.mat', 'phaseData');