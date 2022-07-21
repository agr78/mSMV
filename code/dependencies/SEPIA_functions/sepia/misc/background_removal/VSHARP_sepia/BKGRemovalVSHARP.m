%% function [RDF,mask]=BKGRemovalVSHARP(totalField,mask,matrixSize,varargin)
%
% Input
% _____
%   totalField      : total field
%   mask            : ROI mask
%   matrixSize      : image matrix size
%   varargin        : flags with
%       'radius'    -   vector of radii being used
% 
% Ouput
% _____
%   RDF             : local field
%
% Description: compute QSM based on iterative LSQR
%
% Kwok-shing Chan @ DCCN
% k.chan@donders.ru.nl
% Date created: 19 July 2017
% Date modified: 1 April 2019
% Date modified: 12 April 2019
%
function [RDF,mask]=BKGRemovalVSHARP(totalField,mask,matrixSize,varargin)
% parse argument input
[radius] = parse_varargin_VSHARP(varargin);

% zero padding
totalField  = padarray(totalField,[1 1 1],'both');
mask        = padarray(mask,[1 1 1],'both');
matrixSize  = size(totalField);

% total field in k-space
kTotalField = fftn(totalField);

DiffMask = zeros([matrixSize, length(radius)], 'like', totalField);
Mask_Sharp = zeros([matrixSize, length(radius)], 'like', totalField);
Del_Sharp = zeros([matrixSize, length(radius)], 'like', totalField);
RDF = 0;
% variable kernel size
for k = 1:length(radius)
    % get radius
    radiusCurrent = radius(k);
    
    % Sphere kernel in k-space
    sphereKernel = SphereKernel(matrixSize,radiusCurrent);
    
    % erode mask to remove convolution artifacts
    erode_size = radiusCurrent*2 + 1;
    msk_sharp = imerode(mask, strel('line', erode_size, 0));
    msk_sharp = imerode(msk_sharp, strel('line', erode_size, 90));
    msk_sharp = permute(msk_sharp, [1,3,2]);
    msk_sharp = imerode(msk_sharp, strel('line', erode_size, 0));
    msk_sharp = permute(msk_sharp, [1,3,2]);

    Mask_Sharp(:,:,:,k) = msk_sharp; 
    Del_Sharp(:,:,:,k) = sphereKernel; 
    
    if k == 1
        DiffMask(:,:,:,1) = Mask_Sharp(:,:,:,1);
    else
        % boundary voxels between two spheres
        DiffMask(:,:,:,k) = Mask_Sharp(:,:,:,k) - Mask_Sharp(:,:,:,k-1);
    end
    % if k~=1, put back the phase in the boundary between current kernel
    % and previous kernel
    RDF = RDF + DiffMask(:,:,:,k) .* ifftn(Del_Sharp(:,:,:,k) .* kTotalField);
end
%  largest mask
mask = Mask_Sharp(:,:,:,end);     

RDF = RDF .* mask ;

RDF = RDF(2:end-1,2:end-1,2:end-1);
mask = mask(2:end-1,2:end-1,2:end-1);

end

%% parser
function [radius] = parse_varargin_VSHARP(arg)
radius = 5:-1:1;
if ~isempty(arg)
    for kvar = 1:length(arg)
        if strcmpi(arg{kvar},'radius')
            tmp = arg{kvar+1};
            radius = sort(tmp,'descend');
        end
    end
end
end