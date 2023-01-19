% Residual background field fit (resfield_fit)
%
% Fits the local field edge after spherical mean value filtering
%
% Alexandra G. Roberts
% MRI Lab
% Cornell University
% 07/28/2022
function [f, RDF, RDF_SMV] = resfield_fit(RDF,Mask,N_std,voxel_size)
k = 0;
while k < 6
    % Specify parameters
    radius = 6;
    matrix_size = size(RDF);
    
    % Field uncertainty map
    tempn = single(N_std);
    
    % Generate noise-weighting
    m = ones(size(tempn));%dataterm_mask(1, tempn, Mask);
    
    % Scaling
    N = prod(matrix_size);
    
    % Create edge mask
    Mask_e = Mask-MaskErode(Mask,matrix_size,voxel_size,radius);
    
    % Create vein mask
    
    RDF_veins = abs(RDF-SMV(RDF,matrix_size,voxel_size,1));
    Mask_v = imbinarize(RDF_veins,std(RDF_veins(:))); 
        
    % Define Fourier transform functions with appropriate scaling and shifting
    k_center = @(x) fftshift(fftshift(fftshift(x,3),2),1);
    FT = @(x) (fftn(x));
    iFT = @(x) ifftn((x));
    
    % SMV kernel - sphere in image space, Bessel function in k-space
    %L = imresize3(FT(fspecial3('laplacian')),matrix_size);%,matrix_size,1);
    %L = fftshift(fspecial3('gaussian',matrix_size,radius));
    L = sphere_kernel(matrix_size,voxel_size,radius);
    
    % Apply SMV
    RDF_SMV = Mask.*(RDF-SMV(RDF,matrix_size,voxel_size,radius)); 
    % Positive definite system matrix A'A
    A = @(dK) conj(L).*FT(Mask_e.*m.*m.*Mask_e.*iFT(L.*dK)); 
    
    % Data term A'b
    b = conj(L).*fftn(Mask_e.*m.*m.*Mask_e.*RDF);
    
    % Fit residual background field (taking real part of Ks caused aliasing)
    Ks = cgsolve(A,b,1e-16,100,1);
    f = Mask_e.*iFT(L.*Ks);

    %RDF = RDF-((Mask_e == 1 & Mask_v == 0).*f);
    RDF = RDF_SMV-(Mask_e.*f);
    k = k+1;
end

RDF_out = RDF;


end