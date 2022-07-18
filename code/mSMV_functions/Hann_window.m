% Hann Window
%   [win_im] = Hannwindow(im)
%   Outputs a symmetrically Hann windowed image
%   Addresses Gibbs ringing that occurs when cropping k-space
%   w[n] = 0.5(1-cos(2pi*n/(N-1)))
%   For a 2D input:
%       0.5(1-cos(2pi*nx/(Nx-1))0.5(1-cos(2pi*ny/(Ny-1))
%   For a 3D input:
%       0.5(1-cos(2pi*nx/(Nx-1))0.5(1-cos(2pi*ny/(Ny-1))0.5(1-cos(2pi*nz/(Nz-1))
%  
% Alexandra G. Roberts
% MRI Lab
% Cornell University
% 12/13/2020

function [win_im] = Hannwindow(im)
if numel(size(im)) == 2
        [NX NY] = size(im);
        X = 0:NX-1; Y = 0:NY-1; 
        [XG, YG] = meshgrid(X, Y);
        F = 0.5.*(1-cos((2*pi.*XG)./(NX-1))).*0.5.*(1-cos((2*pi.*YG)./(NY-1)));
        win_im = im.*F;
end

if numel(size(im)) == 3
        [NX NY NZ] = size(im);
        X = 0:NX-1; Y = 0:NY-1; Z = 0:NZ-1;
        [XG, YG, ZG] = meshgrid(X, Y, Z);
        F = 0.5.*(1-cos((2*pi.*XG)./(NX-1))).*0.5.*(1-cos((2*pi.*YG)./(NY-1))).*0.5.*(1-cos((2*pi.*ZG)./(NZ-1)));
        win_im = im.*F;      
end

end