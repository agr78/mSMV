% Create fit
%
% Helper function adapted from MATLAB curve fitting toolbox
%
% Alexandra G. Roberts
% MRI Lab
% Cornell University
% 03/31/2022

function [fitresult, gof] = createFit(x,y,dm)

% figure;
% Reshape input data to columns and match data types
[xData, yData] = prepareCurveData(x,y);

% Use linear polynomial curve fit
ft = fittype('poly1');

% Fit model to data
[fitresult, gof] = fit(xData,yData,ft);

% Plot
h = plot(fitresult,xData,yData);

grid on

if exist('dm','var') == 1
    if dm == 1
        plot_dm_wrapper
    end
end




