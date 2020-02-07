%Plot the the LED intensity of one well over one experiment
function[] = plotLedData(name, led_data)
     [visY, visX] = getExtendedLedData(led_data);
     plot(visX, visY)
     axis([-inf, inf, -max(visY)*0.1, (1+max(visY))*1.1])
     title(['LED ', name, ' pattern'])
end
 
 %Transforms the parameters of the experiment of one LED to two vectors,
 %plotter_points_y represents the intenisiy at time plotter_points_x
function[plotter_points_y, plotter_points_x] = getExtendedLedData(led_data)
    t = 0;
    plotter_points_y = 0;
    plotter_points_x = 0;
    for i = 1:length(led_data.intensity)
        [tempY, tempX] = getExtendedLedDataPhase(led_data.intensity(i), led_data.offset(i), led_data.t_pulse(i), led_data.t_interpulse(i), led_data.periods(i), t);
        t = tempX(end);
        plotter_points_y = [plotter_points_y, tempY];
        plotter_points_x = [plotter_points_x, tempX];
    end
end

 %Transforms the parameters of one phase of one LED to two vectors,
 %plotter_points_y represents the intenisiy at time plotter_points_x
 function[plotter_points_y, plotter_points_x] = getExtendedLedDataPhase(intensity, offset, t_pulse, t_interpulse, periods, t0)
    plotter_points_y = ones([1,4*periods+2]);
    plotter_points_x = ones([1,4*periods+2]);
    plotter_points_y(1) = 0;
    plotter_points_x(1) = t0;
    plotter_points_y(2) = 0;
    plotter_points_x(2) = t0 + offset;
    t = t0 + offset;
    for i = 1:periods
         [plotter_points_y((i-1)*4+3:i*4+2), plotter_points_x((i-1)*4+3:i*4+2)] = getExtendedLedDataPeriod(intensity, t_pulse, t_interpulse, t);
         t = t + t_pulse + t_interpulse;
    end
 end
 
 %Transforms the parameters of one pahse of one LED to two vectors,
 %plotter_points_y represents the intenisiy at time plotter_points_x
 function[plotter_points_y, plotter_points_x] = getExtendedLedDataPeriod(intensity, t_pulse, t_interpulse, t0)
    plotter_points_y(1) = intensity;
    plotter_points_x(1) = t0;
    plotter_points_y(2) = intensity;
    plotter_points_x(2) = t0 + t_pulse;
    plotter_points_y(3) = 0;
    plotter_points_x(3) = t0 + t_pulse;
    plotter_points_y(4) = 0;
    plotter_points_x(4) = t0 + t_pulse + t_interpulse;
 end