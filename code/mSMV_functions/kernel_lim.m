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
K = kvox_min.*min(voxel_size);
eta = 1e-3;
t = 0.001;
k = 1;
while t < 0.01
    [RDF_u] = SMV(RDF,matrix_size,voxel_size,K);
    RDF_smv = Mask.*(RDF-SMV(RDF,matrix_size,voxel_size,K));
    [maxval,idx] = max(abs(RDF_smv(:)));
    uvals(k) = RDF_u(idx);
    maxvals(k) = maxval;
    t = maxvals(k);
    K = K+eta;
    radii(k) = K;
    k = k+1;
end

t