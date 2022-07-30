% Residual background field fit (resfield_fit)
%
% Fits the local field edge after spherical mean value filtering
%
% Alexandra G. Roberts
% MRI Lab
% Cornell University
% 07/28/2022
function [f, RDF] = resfield_fit(RDF,Mask,N_std,voxel_size)

% Specify parameters
radius = 5;
matrix_size = size(RDF);

% Pad to avoid wrap-around artifact
RDF = padarray(RDF,[matrix_size(1)/2,matrix_size(2)/2 matrix_size(3)/2],'both');
Mask = padarray(Mask,[matrix_size(1)/2,matrix_size(2)/2 matrix_size(3)/2],'both');
N_std = padarray(N_std,[matrix_size(1)/2,matrix_size(2)/2 matrix_size(3)/2],'both');
matrix_size = 2.*matrix_size;
N = prod(matrix_size);

% Create edge mask
Mask_e = Mask-MaskErode(Mask,matrix_size,voxel_size,radius);

% Field uncertainty map
tempn = single(N_std);

% Generate noise-weighting
m = dataterm_mask(1, tempn, Mask);

% Define Fourier transform functions with appropriate scaling and shifting
k_center = @(x) fftshift(fftshift(fftshift(x,3),2),1);
FT = @(x) (1/sqrt(N))*(fftn(x));
iFT = @(x) sqrt(N)*ifftn((x));

% SMV kernel - sphere in image space, Bessel function in k-space
%L = imresize3(FT(fspecial3('laplacian')),matrix_size);%,matrix_size,1);
L = fftshift(fspecial3('gaussian',matrix_size,radius));
%L = sphere_kernel(matrix_size,voxel_size,radius);

% Apply SMV
RDF = Mask.*(RDF-SMV(RDF,matrix_size,voxel_size,radius));

% Positive definite system matrix A'A
A = @(dK) conj(L).*FT(Mask_e.*m.*m.*Mask_e.*iFT(L.*dK));

% Data term A'b
b = conj(L).*FT(Mask_e.*m.*m.*Mask_e.*RDF);

% Fit residual background field
Ks = real(cgsolve(A, b, 1e-16, 100, 1));

% Remove padding
matrix_size = (1/2)*matrix_size;
f = Mask_e.*iFT(L.*Ks);
f = f((1/2)*matrix_size(1):matrix_size(1)+(1/2)*matrix_size(1),(1/2)*matrix_size(2):matrix_size(2)+(1/2)*matrix_size(2),(1/2)*matrix_size(3):matrix_size(3)+(1/2)*matrix_size(3));
RDF = RDF((1/2)*matrix_size(1):matrix_size(1)+(1/2)*matrix_size(1),(1/2)*matrix_size(2):matrix_size(2)+(1/2)*matrix_size(2),(1/2)*matrix_size(3):matrix_size(3)+(1/2)*matrix_size(3));