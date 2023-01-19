% Residual background field fit (resfield_fit)
%
% Fits the local field edge after spherical mean value filtering
%
% Alexandra G. Roberts
% MRI Lab
% Cornell University
% 07/28/2022
function [f, RDF, RDF_SMV] = msmv(in_file,out_file)
    
    % Load local field
    load(in_file)

    % Specify parameters
    radius = 5;
    matrix_size = size(RDF);
    
    % Field uncertainty map
    tempn = single(N_std);
    
    % Generate noise-weighting
    m = dataterm_mask(1, tempn, Mask);
    
    % Scaling
    N = prod(matrix_size);
    
        
    % SMV kernel - sphere in image space, Bessel function in k-space
    L = sphere_kernel(matrix_size,voxel_size,radius);
    
    % Apply SMV
    RDF_SMV = Mask.*(RDF-SMV(RDF,matrix_size,voxel_size,radius)); 

    % Create edge mask
    Mask_e = lapmask(RDF-RDF_SMV,Mask,voxel_size);
    
    % Create vein mask
    if ~contains(in_file,'sim')
        RDF_veins = abs(RDF-SMV(RDF,matrix_size,voxel_size,1));
        Mask_v = imbinarize(RDF_veins,std(RDF_veins(:))); 
        Mask_e = (Mask_e == 1 & Mask_v == 0);
    end
    % Define Fourier transform functions with appropriate scaling and shifting
    k_center = @(x) fftshift(fftshift(fftshift(x,3),2),1);
    FT = @(x) (fftn(x));
    iFT = @(x) ifftn((x));
    
    % Positive definite system matrix A'A
    A = @(dK) conj(L).*FT(Mask_e.*m.*m.*Mask_e.*iFT(L.*dK)); 
    
    % Data term A'b
    b = conj(L).*fftn(Mask_e.*m.*m.*Mask_e.*RDF);
    
    % Fit residual background field (taking real part of Ks caused aliasing)
    Ks = cgsolve(A,b,1e-16,500,1);
    f = Mask_e.*iFT(L.*Ks);

    %RDF = RDF-(.*f);
    RDF = RDF_SMV-(Mask_e.*f);

    save(out_file,'B0_dir','CF','delta_TE','iFreq', 'iFreq_raw', 'iMag',...
    'Mask', 'Mask_CSF', 'matrix_size', 'N_std', 'RDF', 'voxel_size');
end