
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Histogram with a Laplace distribution fit       %
%              with MATLAB Implementation              %
%                                                      %
% Author: M.Sc. Eng. Hristo Zhivomirov        04/29/15 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function histfitgauss(x)
% function: histfitlaplace(x)
% x - data sequence (vector)
% distribution parameters estimation
mu = mean(x)                                               % find the distribution mean
sigma = std(x);                                             % find the distribution std
xprim = mu-linspace(-3*sigma, 3*sigma, 1000);             % xprim vector generation [-3*sigma+mu 3*sigma+mu]
fx = 1/(sqrt(2*pi)*sigma).*exp(-0.5.*((xprim-mu)./sigma).^2);   % calculate the Gaussian PDF
% normalize the pdf using the area of the histogram
bins = round(sqrt(length(x))/10);  % number of the histogram bins
n = length(x);                  % length of the data
r = max(x) - min(x);            % range of the data
binwidth = r/bins;              % width of each bin
area = n*binwidth;              % area of the histogram
fx = rescale(fx,0,0.5,'InputMin',0,'InputMax',max(fx(:)));                   % normalize the pdf
% plot the histogram
hHist = histogram(x, bins, 'EdgeColor', 'auto','Normalization','probability');
hold on
% plot the Laplace PDF 
plot(xprim, fx, '-r', 'LineWidth', 1.5)
% set the axes limits
dxl = mu - min(x);
dxr = max(x) - mu;
xlim([-1 1])
ylim([0 1.1*max(max(fx), max(get(hHist, 'Values')))])
title('Residual background field distribution Gaussian fit')
xlabel('\chi')
ylabel('\it P(\chi)')
end