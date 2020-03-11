%% Specify used input_values in order listed in table LED (if applicable)
input_values = [];
input_values = 10:10:240;
input_values = reshape(input_values',12,2)';
input_values =  repmat(input_values,4,1);
input_values = reshape(input_values',96,1);
output_intensity = 186.89; % Calculate input value needed to attain this output intensity

%% Plot and fit output intensity vs input values (if applicable)
clear g; close all; figure('Position',[100 100 1200 800])
LED.input_values = input_values;
g = gramm('x',LED.input_values,'y',LED.intensity,'subset',~isnan(LED.intensity));
g.stat_summary('type','std','geom',{'point','black_errorbar'});
g.set_title('Intensity vs input value');
g.set_names('x','Input value','y', ['Output intensity (' units ')'  newline 'mean ± std']);
g.set_text_options('font','arial','interpreter','tex')
g.stat_fit('fun',@(m,x)m*x,'StartPoint',1)
g.draw(); clc
savefig(gcf,[path 'output_intensity_vs_input_value']);

model = g.results.stat_fit.model;
m = g.results.stat_fit.model.m;

% Calculate input value needed to attain target output intensity
syms y(x)
y(x) = m*x;
input = round(double(solve(y==output_intensity, x)));

disp(model)

if input<0 || input>255
    disp(['input_value = ' num2str(input) ' (out of bounds)'])
else
    disp(['For output_intensity = ' num2str(output_intensity) ', input_value = ' num2str(input)])
end
