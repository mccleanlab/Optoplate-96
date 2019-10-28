led.intensity = 0;
led.duration = 0;
phaseData = repmat(led,1,96);
for i = (1:96)
    phaseData(i).intensity = randi([0, 255], [59,1]);
    phaseData(i).duration = randi([0, 2^16-1], [59,1]);
    
end
 save('phaseData.mat', 'phaseData');