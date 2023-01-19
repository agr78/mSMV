% Residual background field fit (resfield_fit)
%
% Fits the local field edge after spherical mean value filtering
%
% Alexandra G. Roberts
% MRI Lab
% Cornell University
% 07/28/2022
function msmv(in_file,out_file)

% Load local field
load(in_file)

RDF_0 = RDF;
% Specify parameters
radius = 5;
matrix_size = size(RDF);
    
% Field uncertainty map
tempn = single(N_std);
    
% Generate noise-weighting
m = dataterm_mask(1, tempn, Mask);
    
% Scaling
N = prod(matrix_size);
      
% Create vein mask    
RDF_veins = abs(RDF-SMV(RDF,matrix_size,voxel_size,1));
Mask_v = imbinarize(RDF_veins,std(RDF_veins(:))); 
        
% Define Fourier transform functions with appropriate scaling and shifting
k_center = @(x) fftshift(fftshift(fftshift(x,3),2),1);
FT = @(x) (fftn(x));
iFT = @(x) ifftn((x));
    
% SMV kernel - sphere in image space, Bessel function in k-space
L = fftshift(fspecial3('gaussian',matrix_size,0.5.*radius));%FT(sphere_kernel(matrix_size,voxel_size,radius));

% Apply SMV
RDF_SMV = Mask.*(RDF-SMV(RDF,matrix_size,voxel_size,radius)); 
RDF_mSMV = RDF_SMV;

% Create edge mask
Mask_e = lapmask(RDF-RDF_SMV,Mask,voxel_size,radius);

% Preconditioner
Pv = 20;
P = single(Mask_e+(1-Mask_e)*Pv);

% Positive definite system matrix A'A
A = @(dK) conj(L).*FT(Mask_e.*m.*m.*Mask_e.*iFT(L.*dK)); 
    
% Data term A'b
b = conj(L).*FT(Mask_e.*m.*m.*Mask_e.*RDF_mSMV);
    
% Fit residual background field (taking real part of Ks caused aliasing)
Ks = cgsolve(A,b,1e-16,100,1);
f = m.*Mask_e.*real(iFT(L.*Ks));

    if exist('sim')
        RDF = RDF_mSMV-(Mask_e.*f);
    else
        RDF = RDF_mSMV-((Mask_e == 1 & Mask_v == 0).*f);
    end
    

RDF_mSMV = RDF;


save(out_file,'B0_dir','CF','delta_TE','iFreq', 'iFreq_raw', 'iMag',...
'Mask', 'Mask_CSF', 'matrix_size', 'N_std', 'RDF', 'voxel_size');
end