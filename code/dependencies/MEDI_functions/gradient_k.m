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

function [wG,iMag_ds]=gradient_k(gradient_weighting_mode, iMag, Mask, grad, voxel_size, matrix_size, percentage)

if nargin < 6
    percentage = 0.9;
end
[x,y,z] = size(iMag);

iMagk = fftshift(fft2(iMag.*Mask));
iMagk_ds_mag = zeros(size(iMagk)./2);
iMagk_ds_phase = iMagk_ds_mag;
iMagk_ds = iMagk_ds_phase;
[xm,ym,zm] = size(iMagk_ds);
win = centerCropWindow2d(size(iMagk),size(iMagk)./2);
w = hann(128);
for j = 1:zm
       iMagk_ds_mag(:,:,j) = imcrop(abs(iMagk(:,:,2*j)),win);
       iMagk_ds_phase(:,:,j) = imcrop(angle(iMagk(:,:,2*j)),win);
       iMagk_ds = w.*iMagk_ds_mag.*exp(1*i.*iMagk_ds_phase);
       %disp(j)
end
%vis(iMagk)
iMag_ds = fftshift(ifft2(iMagk_ds),3);
%vis(iMag_ds)
iMagk_g = grad_kernel(matrix_size,voxel_size).*iMagk;

field_noise_level = 0.01*max(iMagk_ds(:));
[x,y,z] = size(iMagk_ds);  
wG = abs(iMagk_ds);
denominator = sum(Mask(:)==1);
numerator = sum(wG(:)>field_noise_level);
%if  (numerator/denominator)>percentage
%    while (numerator/denominator)>percentage
%        field_noise_level = field_noise_level*1.05;
%        numerator = sum(wG(:)>field_noise_level);
%    end
%else
%    while (numerator/denominator)<percentage
%        field_noise_level = field_noise_level*.95;
%        numerator = sum(wG(:)>field_noise_level);
%        disp(field_noise_level)
%    end
%end

wG = (wG<=field_noise_level);
function E = grad_kernel(matrix_size,voxel_size)
[k{1}, k{2}, k{3}] = ndgrid(0:matrix_size(1)-1,...
                            0:matrix_size(2)-1,...
                            0:matrix_size(3)-1);
E = zeros([matrix_size 3]);
    for j=1:3
        E(:,:,:,j) = (1-exp(2i.*pi.*k{j}/matrix_size(j)))/voxel_size(j);
    end
end
end

