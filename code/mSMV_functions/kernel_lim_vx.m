% Kernel limit
%
% Approximates the limit of the maximum field value as the kernel radius
% approaches zero
%
% Alexandra G. Roberts
% MRI Lab
% Cornell University
% 11/09/2022

function t = kernel_lim(RDF,voxel_size,matrix_size,Mask)

kvox_min = 0.5;
kvox_max = 1/min(voxel_size);
Kmin = kvox_min.*min(voxel_size);
Kmax = kvox_max.*min(voxel_size);

K = linspace(Kmin,Kmax,500);
K = [0,K];

for k = 1:length(K)
    [RDF_u] = SMV(RDF,matrix_size,voxel_size,K(k));
    RDF_smv = Mask.*(RDF-SMV(RDF,matrix_size,voxel_size,K(k)));
    [maxval,idx] = max(abs(RDF_smv(:)));
    uvals(k) = RDF_u(idx);
    maxvals(k) = maxval;
end

t = min(maxvals(maxvals>10e-10))