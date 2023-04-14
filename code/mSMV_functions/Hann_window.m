% Hann Window
%   [win_im] = Hannwindow(im)
%   Outputs a symmetrically Hann windowed image
%   Addresses Gibbs ringing that occurs when cropping k-space
%   w[n] = 0.5(1-cos(2pi*n/(N-1)))
%  
% Alexandra G. Roberts
% MRI Lab
% Cornell University
% 12/13/2020

function [win_im] = Hannwindow(im)
    if numel(size(im)) == 2
            [NX NY] = size(im);
            X = 0:NX-1; Y = 0:NY-1; 
            [XG, YG] = ndgrid(X,Y);
            H = (0.5)^2.*(1-cos((2*pi.*XG)./(NX-1))).*(1-cos((2*pi.*YG)./(NY-1)));
            win_im = im.*H;
    end
    
    if numel(size(im)) == 3
            [NX NY NZ] = size(im);
            X = 0:NX-1; Y = 0:NY-1; Z = 0:NZ-1;
            [XG, YG, ZG] = ndgrid(X,Y,Z);
            H = (0.5)^3.*(1-cos((2*pi.*XG)./(NX-1))).*(1-cos((2*pi.*YG)./(NY-1))).*(1-cos((2*pi.*ZG)./(NZ-1)));
            win_im = ifftn(ifftshift(fftshift(fftn(im)).*H));   
    end
    
    if numel(size(im)) == 4
        win_im = im;
        for j = 1:size(im,4)
            [NX NY NZ] = size(im(:,:,:,j));
            X = 0:NX-1; Y = 0:NY-1; Z = 0:NZ-1;
            [XG, YG, ZG] = ndgrid(X,Y,Z);
            % Corrected 0.5 for each dimension
            H = (0.5).^3.*(1-cos((2*pi.*XG)./(NX-1))).*(1-cos((2*pi.*YG)./(NY-1))).*(1-cos((2*pi.*ZG)./(NZ-1)));
            win_im(:,:,:,j) = ifftn(ifftshift(fftshift(fftn(im(:,:,:,j))).*H));   
        end
    end
end