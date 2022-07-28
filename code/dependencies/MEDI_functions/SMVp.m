% Spherical Mean Value operator
%   y=SMV(iFreq,matrix_size,voxel_size,radius)
%   
%   output
%   y - resultant image after SMV
% 
%   input
%   iFreq - input image
%   matrix_size - dimension of the field of view
%   voxel_size - the size of the voxel
%   radius - radius of the sphere in mm
%
%   Created by Tian Liu in 2010
%   Last modified by Tian Liu on 2013.07.24

function [y, v] = SMVp(iFreq,Mask,matrix_size,voxel_size,radius) 
    K = sphere_kernel(matrix_size,voxel_size,radius);
    v = real(ifftn(fftn(Mask).*K));
     f = (1./v);
     f(isinf(f)) = 0;
%     f = SMV(f,K);
    Mask_SMV = ifftn(fftn(Mask).*K) > 0.999;
    y = f.*ifftn(fftn(iFreq).*K);
end