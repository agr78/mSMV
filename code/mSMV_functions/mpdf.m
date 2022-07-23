% Maximum Spherical Mean Value (mSMV)
%
% Samples and removes residual background field via the maximum value
% corollary of Green's theorem
%
% Alexandra G. Roberts
% MRI Lab
% Cornell University
% 03/31/2022

function msmv(in_file,out_file)
    % Load local field
    load(in_file)
    
    % Generate kernel
    SphereK = single(sphere_kernel(matrix_size,voxel_size,5));

    % Partition mask
    Mask_ne = SMV(Mask,SphereK) > 0.999;
    Mask_e = Mask-Mask_ne;
    
    % Partition field
    RDF_ne = Mask_ne.*(RDF); 
    RDF_e = Mask_e.*(RDF); 

    % Find max, on edge via Green's theorem
    [maxval,idxmax] = max(RDF(:));
    [r,c,p] = ind2sub(size(RDF),idxmax);  

    % Skip initial SMV, then address incorrect values at edge
    RDF_s0 = Mask.*(RDF);

    % Fit distribution
    f_e = fitdist(abs(RDF(Mask_e>0)-RDF_s0(Mask_e>0)),'normal');
    f_ne = fitdist(abs(RDF(Mask_ne>0)-RDF_s0(Mask_ne>0)),'normal');

    % Create mask of known background field
    Mask_bk = imbinarize(abs(Mask_e.*RDF_s0),f_e.sigma);
    disp('Residual background field threshold in radians is:')
    disp(f_e.sigma)
    RDF_s = Mask.*(RDF_s0-Mask_bk.*RDF_s0);
    RDF = RDF_s;
    
save(out_file,'B0_dir','CF','delta_TE','iFreq', 'iFreq_raw', 'iMag', 'Mask', 'Mask_CSF', 'matrix_size', 'N_std', 'RDF', 'voxel_size');
end