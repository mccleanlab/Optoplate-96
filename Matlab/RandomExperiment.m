led.intensity = 0;
led.duration = 0;
phaseData = repmat(led,1,96);


for i = (1:96)
    phaseData(i).intensity = randi([0, 255], [1, 10]);
    phaseData(i).periods = randi([0, 255], [1, 10]);
    phaseData(i).offset = randi([0, 255], [1, 10]);
    
    phaseData(i).tInterpulse = randi([0, 255], [1, 10]);
    phaseData(i).tPulse = randi([1, 3], [1, 10]);
end

 save('phaseData.mat', 'phaseData');