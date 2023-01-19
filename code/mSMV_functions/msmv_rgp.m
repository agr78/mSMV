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
    
    % Initial region-growing parameter
    rg_param = 0.1;

    % Generate kernel
    SphereK = single(sphere_kernel(matrix_size, voxel_size,5));

    % Partition mask
    Mask_ne = SMV(Mask,SphereK) > 0.999;
    Mask_e = Mask-Mask_ne;
    Mask_nep = Mask-MaskErode(Mask,matrix_size,voxel_size,7);
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
    while sum(J(:)) < (1/2)*max(matrix_size)
        rg_param = 1.1*rg_param;
        [P,J] = regionGrowing(Mask_e.*abs(RDF_s0),[r c p],rg_param*max(abs(RDF_s0(:))),min(matrix_size(:)).*min(voxel_size(:)));
    end

    
    % Create mask of known background field
    prctile(abs(RDF_s0(J>0)),1)
    Mask_bk = imbinarize(abs(Mask_e.*RDF_s0),min(f_bk.sigma.*rg_param,(f_bk.sigma.*(1-rg_param))));
    disp('Residual background field threshold in radians is:')
    disp(string(min(f_bk.sigma.*rg_param,(f_bk.sigma.*(1-rg_param)))))
    RDF_s = Mask.*(RDF_s0-Mask_bk.*RDF_s0);
    RDF = RDF_s;
    
save(out_file,'B0_dir','CF','delta_TE','iFreq', 'iFreq_raw', 'iMag', 'Mask', 'Mask_CSF', 'matrix_size', 'N_std', 'RDF', 'voxel_size');
end