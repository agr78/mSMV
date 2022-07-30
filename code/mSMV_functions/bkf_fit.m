% Residual background field fit (resfield_fit)
%
% Samples and removes residual background field via the maximum value
% corollary of Green's theorem
%
% Alexandra G. Roberts
% MRI Lab
% Cornell University
% 03/31/2022

function Ks = resfield_fit(RDF,Mask,N_std,voxel_size)
radius = 5;
matrix_size = size(RDF);
normh = @(dK) norm(dK(:));
Mask_e = Mask-MaskErode(Mask,matrix_size,voxel_size,radius);
K = zeros(size(RDF));
dK = K;
tempn = single(N_std);
m = dataterm_mask(1, tempn, Mask);
L = sphere_kernel(matrix_size,voxel_size,radius);
RDF = RDF-SMV(RDF,matrix_size,voxel_size,radius);
A = @(dK) m.*Mask_e.*real(sphere_kernel(matrix_size, voxel_size,radius)).*conj(m.*Mask_e.*real(sphere_kernel(matrix_size, voxel_size,radius))).*(dK)+normh(dK);
b = normh(dK)+conj(m.*Mask_e.*real(sphere_kernel(matrix_size, voxel_size,radius))).*RDF;
Ks = real(cgsolve(A, -b, 0.001, 100, 'verbose'));
