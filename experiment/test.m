createExperiment(randi([0, 255], 8, 12), randi([1, 10], 8, 12),randi([0, 255], 8, 12),randi([20, 1000], 8, 12),randi([20, 1000], 8, 12),randi([1, 40], 8, 12),randi([1, 50], 8, 12))
figure();
plotLedPattern(20, 2, 10, 200, 300, 10, 20)
plotLedGui(experiment)