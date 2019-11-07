led.intensity = 0;
led.duration = 0;
phaseData = repmat(led,1,96);


for i = (1:96)
    phaseData(i).intensity = randi([0, 255], [10,1]);
    phaseData(i).intensity(end) = 0;
    phaseData(i).duration = randi([1, 3], [10,1]);
    phaseData(i).duration(end) = 0;
end

max = 50;
for i = (1:96)
    x = mod(i, 12);
    y = floor(i/12);
    phaseData(i).intensity = zeros(max,1);
    for j = (1:max)
        phaseData(i).intensity(j) = round(sin(x/6*pi + y/6*pi +j*5/max*pi)*127+128);
    end
    phaseData(i).duration = ones(max, 1);
end
 save('phaseData.mat', 'phaseData');