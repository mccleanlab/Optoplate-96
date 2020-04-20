function[] = plotLedGui(experimnet_data)

    letters = 'ABCDEFGH';
    
    %Dimensions of buttons
    width = 30;
    height = 25;
    padding = 5;
    
    %Dimensions of navigation window
    totWidth = (width+padding)*12;
    totHeight = (height+padding)*8;
    fig = uifigure('Name', 'Select LED', 'Position',[10 50 totWidth+20 totHeight+20]);
    f_plot = figure();

    btn_event(f_plot, experimnet_data, 1, 1)
    for x = 1:12
       for y = 1:8
        uibutton(fig,'push',...
                   'Text', [letters(y), num2str(x)],...
                   'Position',[10+(x-1)*(width+padding), totHeight+10 - y*(height+padding), width, height],...
                   'ButtonPushedFcn', @(btn,event)  btn_event(f_plot, experimnet_data, x,y) );
       end
    end
end

function btn_event(f_plot, experimnet_data, x, y)
    letters = 'ABCDEFGH';
    figure(f_plot);
    plotLedPattern(experimnet_data.amplitude(y, x), experimnet_data.pulse_numb(y, x), experimnet_data.pusle_start_time(y, x), experimnet_data.pulse_high_time(y, x), experimnet_data.pulse_low_time(y, x), experimnet_data.subpulse_high_time(y, x), experimnet_data.subpulse_low_time(y, x));
    title([letters(y), num2str(x)]);
end


