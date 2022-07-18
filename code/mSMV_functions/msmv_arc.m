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
    

    % Parameters
    nsamples = round(min(voxel_size(:)).*min(matrix_size(:)));
    rg_param = 0.1;

    % Generate kernels for edge and ~edge
    SphereK_e = single(sphere_kernel(matrix_size, voxel_size,1));
    SphereK_ne = single(sphere_kernel(matrix_size, voxel_size,5));
    % Partition mask
    Mask_ne = SMV(Mask,SphereK_ne) > 0.999;
    Mask_e = Mask-Mask_ne;
    
    % Partition field
    RDF_ne = Mask_ne.*(RDF); 
    RDF_e = Mask_e.*(RDF); 

    % Find max, on edge via Green's theorem
    [maxval,idxmax] = max(RDF(:));
    [r,c,p] = ind2sub(size(RDF),idxmax);
    RDF_s0 = Mask.*(RDF-SMV(RDF,SphereK_ne));
       

    % Perform initial SMV, then address incorrect values at edge
    RDF_s0 = Mask.*(RDF-SMV(RDF,SphereK_ne));
    mu = mean(RDF_s0(:));
    % Region grow from max seed point, background field is connected component
    %[P,J] = regionGrowing(abs(RDF_s0),[r c p],rg_param*max(RDF_s0(:)-min(RDF_s0(:))));
    [P,J] = regionGrowing(abs(RDF_s0),[r c p],rg_param*max(RDF_s0(:)),min(matrix_size(:)).*min(voxel_size(:)));
    while sum(J(:)) == 0
        rg_param = 1.1*rg_param;
        [P,J] = regionGrowing(abs(RDF_s0),[r c p],rg_param*max(RDF_s0(:)),min(matrix_size(:)).*min(voxel_size(:)));
    end
    % Fit normal distribution to known background field
%     RDF_bk = abs(RDF_s0).*J;
%     RDF_bk = abs(RDF_bk(abs(RDF_bk(:))>0)); 
    RDF_bk = abs(RDF-RDF_s0).*J;
    RDF_bk = abs(RDF_bk(abs(J(:))>0));
    %RDF_bk = RDF_bk(Mask>0);
    f_bk = fitdist(RDF_bk(:)-mean(RDF_bk(:)),'normal');
    f_ne = fitdist(RDF_ne(:)-mean(RDF_ne(:)),'normal');
%    
%     % If needed, sample background to increase variance
%     k = 1;
%     J_bk = zeros(size(RDF));
%     if f_bk.sigma < f_ne.sigma
%             [maxvalk,idxmaxk] = maxk(RDF(:),nsamples);
%             while f_bk.sigma < f_ne.sigma && k <= nsamples
%                 [r,c,p] = ind2sub(size(RDF),idxmaxk(k));
%                 k
%                 [P,J] = regionGrowing(abs(RDF_s0),[r c p],rg_param*max(RDF_s0(:)),max(voxel_size(:)));
%                 J_bk = logical(J_bk+J);
%                 RDF_bk = abs(RDF_s0).*J_bk;
%                 %RDF_bk = RDF_bk(J_bk > 0);
%             
%                 % Re-fit normal distribution to known background field
%                 f_bk = fitdist(RDF_bk(:),'normal');
%                 k = k+1;
%                 
%                 % Stop if iteration limit is reached
%                 if k == nsamples
%                     f_bk.sigma == f_ne.sigma;
%                 end
%             end
%             Mask_bk = imbinarize(abs(RDF_s0.*Mask_e),mu+f_bk.sigma);      
%             RDF_s = Mask.*(RDF_s0-Mask_bk.*RDF_s0);
%             RDF = RDF_s;
%     else
         % Create mask of known background field
         Mask_bk = imbinarize(abs(Mask_e.*RDF_s0),f_bk.mu/mink(matrix_size)+f_bk.sigma/min(matrix_size));
         disp((f_bk.mu+f_bk.sigma))
         disp(f_ne)
         RDF_s = Mask.*(RDF_s0-Mask_bk.*RDF_s0);
         RDF = RDF_s;
%    end  
      


    
save(out_file,'B0_dir','CF','delta_TE','iFreq', 'iFreq_raw', 'iMag', 'Mask', 'Mask_CSF', 'matrix_size', 'N_std', 'RDF', 'voxel_size');
end