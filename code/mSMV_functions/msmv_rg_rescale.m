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
    sim = 0;
    load(in_file)
    
    % Initial region-growing parameter
    rg_param = 0.1;

    % Generate kernel
    SphereK = single(sphere_kernel(matrix_size, voxel_size,5));

    % Partition mask
    Mask_ne = SMV(Mask,SphereK) > 0.999;
    Mask_e = Mask-Mask_ne;
    
    % Partition field
    RDF_ne = Mask_ne.*(RDF); 
    RDF_e = Mask_e.*(RDF); 

    % Find max, on edge via Green's theorem
    [maxval,idxmax] = max(RDF(:));
    [r,c,p] = ind2sub(size(RDF),idxmax);  

    % Perform initial SMV, then address incorrect values at edge
    RDF_s0 = Mask.*(RDF-SMV(RDF,SphereK));

    % Region grow from max seed point, background field is connected component
    [P,J] = regionGrowing(abs(RDF_s0),[r c p],rg_param*max(RDF_s0(:)),min(matrix_size(:)).*min(voxel_size(:)));
    while sum(J(:)) < max(matrix_size)
        rg_param = 1.1*rg_param;
        [P,J] = regionGrowing(abs(Mask_e.*RDF_s0),[r c p],rg_param*max(abs(RDF_s0(:))),min(matrix_size(:)).*min(voxel_size(:)));
    end

    % Fit normal distribution to difference in filtered and unfiltered known background field
    RDF_bk = abs(RDF_s0).*J;
    RDF_bk = abs(RDF_bk(abs(J(:))>0));
    f_bk = fitdist(RDF_bk(:)-mean(RDF_bk(:)),'normal');

    % Create mask of known background field
    t = f_bk.sigma;
    Mask_bk = imbinarize(abs(Mask_e.*RDF_s0),t);
    disp('Residual background field threshold in radians is:')
    disp(string(t))

    if sim == 0
      % Vessel filter
      filt = abs(RDF-SMV(RDF,matrix_size,voxel_size,1));
      Mv = imbinarize(filt,std(filt(:)))-imbinarize(filt,3*std(filt(:)));
        
      % Preserve the vessels that extend to the edge
      Mask_bk = Mask_bk == 1 & Mv == 0;
      disp('Applying vessel mask')
    end

    % Rescale all points in background field mask to +/- cutoff t
    RDF_s = RDF_s0;
    RDF_s(Mask_bk == 1) = rescale(RDF_s0(Mask_bk == 1),-t,t);
    RDF = RDF_s;
    
save(out_file,'B0_dir','CF','delta_TE','iFreq', 'iFreq_raw', 'iMag', 'Mask', 'Mask_CSF', 'matrix_size', 'N_std', 'RDF', 'voxel_size');
end

