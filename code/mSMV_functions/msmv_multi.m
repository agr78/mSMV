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
    nsamples = 75;
    rg_param = 0.5;

    % Generate kernels for edge and ~edge
    SphereK = single(sphere_kernel(matrix_size, voxel_size,5));

    % Partition mask
    Mask_ne = SMV(Mask,SphereK) > 0.999;
    Mask_e = Mask-Mask_ne;
    
    % Partition field
    RDF_ne = Mask_ne.*(RDF); 

    % Find max, on edge via Green's theorem
    [maxval,idxmax] = max(RDF(:));
    [r,c,p] = ind2sub(size(RDF),idxmax)       

    % Perform initial SMV, then address incorrect values at edge
    RDF_s0 = Mask.*(RDF-SMV(RDF,SphereK));
    mu = mean(RDF_s0(:));

    % Region grow from max seed point, background field is connected component
    % If region grow fails, adjust threshold until background mask is
    % nonzero
    [P,J] = regionGrowing(abs(RDF_s0),[r c p],rg_param*max(RDF_s0(:)),5*max(voxel_size));
    while sum(J(:)) == 0
        rg_param = 1.1*rg_param;
        [P,J] = regionGrowing(abs(RDF_s0),[r c p],rg_param*max(RDF_s0(:)),5*max(voxel_size));
    end 

    % Fit normal distribution to known background field
    RDF_bk = RDF_s0.*J;
    RDF_bk = RDF_bk(abs(RDF_bk(:))>0); 
    RDF_bk = (RDF_bk./(max(RDF_bk(:))+abs(min(RDF_bk(:)))));
    f_bk = fitdist(RDF_bk(:),'normal');
    f_ne = fitdist(RDF_ne(:),'normal');
   
    % If needed, sample background to increase variance
    k = 1;
    J_bk = zeros(size(RDF));
    f_bko = zeros(1,nsamples);
    if f_bk.sigma < f_ne.sigma || length(RDF_bk) < max(matrix_size(:))
            [maxvalk,idxmaxk] = maxk(RDF(:),nsamples);
            while k <= nsamples
                f_bko(k) = f_bk.sigma;
                f_bku = f_bk.mu;
                [r,c,p] = ind2sub(size(RDF),idxmaxk(k));
                [P,J] = regionGrowing(abs(RDF_s0),[r c p],rg_param*max(RDF_s0(:)),5*max(voxel_size));
                J_bk = logical(J_bk+J);
                RDF_bk = RDF_s0.*J_bk;
                RDF_bk = RDF_bk(abs(RDF_bk(:))>0); 
                RDF_bk = (RDF_bk./(max(RDF_bk(:))+abs(min(RDF_bk(:)))));
                RDF_bk_dist{k} = RDF_bk;

                % Re-fit normal distribution to known background field
                f_bk = fitdist(RDF_bk(:),'normal');
                k = k+1;

            end
            % Use tightest distribution
            f_bk.sigma = min(f_bko);
            Mask_bk = imbinarize(abs(RDF_s0.*Mask_e),mu+f_bk.sigma);
            disp('Threshold:'); mu+f_bk.sigma
            disp('Mean:'); mu
            disp('Standard deviation:'); f_bk.sigma
            RDF_s = Mask.*(RDF_s0-Mask_bk.*RDF_s0);
            RDF = RDF_s;
    else
         % Create mask of known background field
         disp('Single sample')
         Mask_bk = imbinarize(abs(Mask_e.*RDF_s0),mu+f_bk.sigma);
         RDF_s = Mask.*(RDF_s0-Mask_bk.*RDF_s0);
         RDF = RDF_s;
    end  
      


    
save(out_file,'B0_dir','CF','delta_TE','iFreq', 'iMag', 'Mask', 'Mask_CSF', 'matrix_size', 'N_std', 'RDF', 'voxel_size');
end