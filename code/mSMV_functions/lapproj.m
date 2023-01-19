% Residual background field fit (resfield_fit)
%
% Fits the local field edge after spherical mean value filtering
%
% Alexandra G. Roberts
% MRI Lab
% Cornell University
% 07/28/2022
function [b_mSMV,b_SMV] = lapproj(RDF,Mask,voxel_size,N_std)

% Specify parameters
radius = 5;
matrix_size = size(RDF);

% Use field notation
b = RDF;

% Apply SMV
b_SMV = Mask.*(b-SMV(b,matrix_size,voxel_size,radius)); 

% Generate Laplacian mask
db0 = (b-b_SMV);
H = fspecial3('laplacian');
Ldb0 = imfilter(db0,H);
Mask_b0 = (Mask-MaskErode(Mask,matrix_size,voxel_size,5)).*abs(Ldb0) > mean(abs(Ldb0(:))+std(abs(Ldb0(:))));
  
% Positive definite system matrix A'A
% Want to find scaling b_SMV closest SMV
A = @(dR) (conj(b_SMV).*Mask.*Mask.*b_SMV).*(dR);
    
% Data term A'b
b = conj(b_SMV).*Mask.*2.*Mask_b0.*b_SMV;
    
% Fit residual background field (taking real part of Ks caused aliasing)
r = real(cgsolve(A,b,1e-16,100,1));
b_mSMV = (Mask-Mask_b0).*b_SMV+(Mask_b0.*bs_SMV);

end