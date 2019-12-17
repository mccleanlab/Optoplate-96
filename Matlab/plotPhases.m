% here phasedata is for one LED (NOT ALL 96) 
function[] = plotPhases(phaseData) 
     [visY, visX] = getPhases(phaseData);
     plot(visX, visY)
     axis([-inf, inf, -max(visY)*0.1, max(visY)*1.1])
 end
 
 
function[plotterPointsY, plotterPointsX] = getPhases(phaseData)
    t = 0;
    plotterPointsY = 0;
    plotterPointsX = 0;
    for i = 1:length(phaseData.intensity)
        [tempY, tempX] = getPhase(phaseData.intensity(i), phaseData.offset(i), phaseData.tPulse(i), phaseData.tInterpulse(i), phaseData.periods(i), t);
        t = tempX(end);
        plotterPointsY = [plotterPointsY, tempY];
        plotterPointsX = [plotterPointsX, tempX];
    end
end
 
 function[plotterPointsY, plotterPointsX] = getPhase(intensity, offset, tPulse, tInterpulse, periods, t0)
    plotterPointsY = ones([1,4*periods+2]);
    plotterPointsX = ones([1,4*periods+2]);
    plotterPointsY(1) = 0;
    plotterPointsX(1) = t0;
    plotterPointsY(2) = 0;
    plotterPointsX(2) = t0 + offset;
    t = t0 + offset;
    for i = 1:periods
         [plotterPointsY((i-1)*4+3:i*4+2), plotterPointsX((i-1)*4+3:i*4+2)] = getplotterPoints(intensity, tPulse, tInterpulse, t);
         t = t + tPulse + tInterpulse;
    end
 end
 
 function[plotterPointsY, plotterPointsX] = getplotterPoints(intensity, tPulse, tInterpulse, t0)
    plotterPointsY(1) = intensity;
    plotterPointsX(1) = t0;
    plotterPointsY(2) = intensity;
    plotterPointsX(2) = t0 + tPulse;
    plotterPointsY(3) = 0;
    plotterPointsX(3) = t0 + tPulse;
    plotterPointsY(4) = 0;
    plotterPointsX(4) = t0 + tPulse + tInterpulse;
 end