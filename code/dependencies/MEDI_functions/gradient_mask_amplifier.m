% Generate the gradient weighting in MEDI
%   w=gradient_mask(gradient_weighting_mode, iMag, Mask, grad, voxel_size, percentage)
% 
%   output
%   w - gradient weighting 
%
%   input
%   gradient_weighting_mode - 1, binary weighting; other, reserved for
%                             grayscale weighting
%   iMag - the anatomical image
%   Mask - a binary 3D matrix denoting the Region Of Interest
%   grad - function that takes gradient
%   voxel_size - the size of a voxel
%   percentage(optional) - percentage of voxels considered to be edges.
%
%   Created by Ildar Khalidov in 20010
%   Modified by Tian Liu and Shuai Wang on 2011.03.28 add voxel_size in grad
%   Modified by Tian Liu on 2011.03.31
%   Last modified by Tian Liu on 2013.07.24

function wG=gradient_mask_amplifier(gradient_weighting_mode, iMag, Mask, grad, voxel_size, percentage)

if nargin < 6
    percentage = 0.9;
end


field_noise_level = 0.01*max(iMag(:));
[xm,ym,zm] = size(iMag);
%sc = mean(reshape(iMag,[1 xm*ym*zm]));
sc = mean(iMag(Mask>0));
dgrad = max(reshape(iMag,[1 xm*ym*zm])-min(reshape(iMag,[1 xm*ym*zm])));
iMag_g = iMag;
kernel = zeros(3,3);
iMag_g = grad(iMag,voxel_size);
iMag_g0 = iMag_g;

% for k = 1:zm 
    for i = 3:xm-2
        for j = 3:ym-2
            %for k = 3:zm-2
            kernel = iMag(i-2:i+2,j-2:j+2,:);
            if kernel.*Mask(i-2:i+2,j-2:j+2,:) > 0
                if kernel > sc %If edge is strong
                    iMag_g(i,j,:,:) = iMag_g(i,j,:,:).*grad; %Amplify                   
                end
            end
        end
    end





wG = abs(iMag_g.*(Mask>0));        
%wG = abs(grad(iMag_g.*(Mask>0), voxel_size));
denominator = sum(Mask(:)==1);
numerator = sum(wG(:)>field_noise_level);
if  (numerator/denominator)>percentage
    while (numerator/denominator)>percentage
        field_noise_level = field_noise_level*1.05;
        numerator = sum(wG(:)>field_noise_level);
    end
else
    while (numerator/denominator)<percentage
        field_noise_level = field_noise_level*.95;
        numerator = sum(wG(:)>field_noise_level);
    end
end

wG = (wG<=field_noise_level);

