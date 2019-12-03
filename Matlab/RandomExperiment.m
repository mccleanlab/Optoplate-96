led.intensity = 0;
led.duration = 0;
phaseData = repmat(led,1,96);
phases = 8;

for i = (1:96)
    phaseData(i).intensity = ones([phases, 1]) * 255;%randi([0, 255], [10,1]);
    phaseData(i).periods =  ones([phases, 1]) * 5; %randi([0, 255], [10, 1]);
    phaseData(i).offset = ones([phases, 1]); %randi([0, 255], [10, 1]);
    
    phaseData(i).tInterpulse = ones([phases, 1]) * 1; %randi([0, 255], [10, 1]);
    phaseData(i).tPulse = ones([phases, 1]) * 2; %randi([1, 3], [10,1]);
end

 save('phaseData.mat', 'phaseData');