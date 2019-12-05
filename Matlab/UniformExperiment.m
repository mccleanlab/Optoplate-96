led.intensity = 0;
led.duration = 0;
phaseData = repmat(led,1,96);


for i = (1:96)
    phaseData(i).intensity = ones([10, 1])*10;
    phaseData(i).periods = ones([10, 1])*100;
    phaseData(i).offset = ones([10, 1])*5;
    
    phaseData(i).tInterpulse = ones([10, 1])*3;
    phaseData(i).tPulse = ones([10, 1])*1;
end

 save('phaseData.mat', 'phaseData');