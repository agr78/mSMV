% Kernel limit
%
% Approximates the limit of the maximum field value as the kernel radius
% approaches zero
%
% Inputs:
% RDF - Relative difference field (tissue or local field)
% voxel_size - Resolution used to calculate the minimum kernel radius
% matrix_size - Image dimensions
% Mask - Region of interest
% B0_mag - Field strength
%
% Output: Filtered RDF
%
% Please cite:
% A. G. Roberts et al., "Maximum Spherical Mean Value (mSMV) 
% Filtering for Whole Brain Quantitative Susceptibility Mapping," 
% Magnetic Resonance in Medicine, 2024, DOI: 10.1002/mrm.29963

function t = kernel_lim(RDF,voxel_size,matrix_size,Mask,B0_mag)
% Default field strength of 3T
if nargin < 5
    B0_mag = 3;
end
% Kernel limit parameters
kvox_min = 0.5;
K = kvox_min.*min(voxel_size);
eta = 1e-3;
t = 0.001;
% Approach from 0 (for speed)
while t < (0.01*B0_mag/3)
    [RDF_u] = SMV(RDF,matrix_size,voxel_size,K);
    RDF_smv = Mask.*(RDF-SMV(RDF,matrix_size,voxel_size,K));
    [maxval,idx] = max(abs(RDF_smv(:)));
    t = maxval;
    K = K+eta;
end
end
