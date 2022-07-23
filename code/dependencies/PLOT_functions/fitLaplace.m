function [m, b] = fitLaplace(x)
m = median(x);
b = mean(abs(x-m)); 
end