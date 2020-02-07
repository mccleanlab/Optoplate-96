function[] = plotLedSelector(experimnet_data)

    letters = 'ABCDEFGH';
    
    %Dimensions of buttons
    width = 30;
    height = 25;
    padding = 5;
    
    %Dimensions of navigation window
    totWidth = (width+padding)*12;
    totHeight = (height+padding)*8;
    fig = uifigure('Name', 'Select LED', 'Position',[10 50 totWidth+20 totHeight+20]);
    figure()

    plotLedData('A1', experimnet_data(1, 1))

    for x = 1:12
       for y = 1:8
        uibutton(fig,'push',...
                   'Text', [letters(y), num2str(x)],...
                   'Position',[10+(x-1)*(width+padding), totHeight+10 - y*(height+padding), width, height],...
                   'ButtonPushedFcn', @(btn,event) plotLedData([letters(y), num2str(x)], experimnet_data(y, x)));
       end
    end

end



