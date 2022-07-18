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
    
    if exist('R2s','var') == 0
        disp('No R2s map, hemorrhage detection disabled.')
        R2s = zeros(size(RDF));
    end
    % Parameters
    nsamples = 20;
    rg_param = 0.25;

    % Generate kernels for edge and ~edge
    SphereK_ne = single(sphere_kernel(matrix_size, voxel_size,5));
    SphereK_e = single(sphere_kernel(matrix_size, voxel_size,1));
    
    % Partition mask
    Mask_ne = SMV(Mask,SphereK_ne) > 0.999;
    Mask_e = Mask-Mask_ne;
    R2s = Mask.*R2s;
    
    % Partition field
    RDF_ne = Mask_ne.*(RDF); 
    RDF_e = Mask_e.*(RDF); 

    % Find max, on edge via Green's theorem
    [maxval,idxmax] = max(RDF(:));
    [r,c,p] = ind2sub(size(RDF),idxmax);
    RDF_s0 = Mask.*(RDF-SMV(RDF,SphereK_ne));
    mode = 0;
    if Mask_e(r,c,p) == 0
        mode = 1;
    end
    if sum(R2s(:)) > 0 && mode == 0
        mode = 0;
        [maxvalk,idxmaxk] = maxk((RDF(:)),nsamples);
        [maxvalk2s1,idxmaxk2s1] = maxk(R2s(:),nsamples);
        [maxvalk2s2,idxmaxk2s2] = maxk(R2s(:),100*nsamples);
        [r,c,p] = ind2sub(size(RDF),idxmaxk(nsamples));
        hemo_check = 0;
        hemo_check_R2s = 0;
        for j = 1:nsamples
            [r,c,p] = ind2sub(size(RDF),idxmaxk(j));
            [r2s,c2s,p2s] = ind2sub(size(R2s),idxmaxk2s1(j));
            hemo_check = hemo_check+Mask_ne(r,c,p);
            hemo_check_R2s = hemo_check_R2s+Mask_ne(r2s,c2s,p2s);
        end
            if hemo_check_R2s > 0
                disp('Hemorrhage detected')
                mode = 1;
            end
            if hemo_check > 0
                disp('Internal hemorrhage detected')
                mode = 1;
            end
            %if hemo_check == 0
            % Add small amount of noise to avoid NaN
            maxvalk2s1 = maxvalk2s1+(1e-10)*randn(size(maxvalk2s1));
            maxvalk2s2 = maxvalk2s2+(1e-10)*randn(size(maxvalk2s2));
            % Check if sampling more maximum points increases the
            % variance (i.e., look for an edge hemorrahge on R2s);
            e_hemo_check = vartest2(maxvalk2s1,maxvalk2s2);
                if e_hemo_check == 1
                    disp('Edge hemorrhage detected')
                    mode = 1;
                end
            %end
    else
        mode = 0;
    end

    % Perform initial SMV, then address incorrect values at edge
    RDF_s0 = Mask.*(RDF-SMV(RDF,SphereK_ne));
    mu = mean(RDF_s0(:));
    % Region grow from max seed point, background field is connected component
    [P,J] = regionGrowing(abs(RDF_s0),[r c p],rg_param*max(RDF_s0(:)-min(RDF_s0(:))),10);

    % Fit normal distribution to known background field
    RDF_bk = RDF_s0.*J;
    f_bk = fitdist(RDF_bk(:),'normal');
    f_ne = fitdist(RDF_ne(:),'normal');
   
    % If needed, sample background to increase variance
    k = 1;
    J_bk = zeros(size(RDF));
    if mode == 0
        if f_bk.sigma < f_ne.sigma
            [maxvalk,idxmaxk] = maxk(RDF(:),100*nsamples);
            while f_bk.sigma < f_ne.sigma && k <= 100*nsamples
                [r,c,p] = ind2sub(size(RDF),idxmaxk(k));
                [P,J] = regionGrowing(abs(RDF_s0),[r c p],rg_param*max(RDF_s0(:)-min(RDF_s0(:))),10);
                J_bk = logical(J_bk+J);
                RDF_bk = RDF_s0.*J_bk;
            
                % Re-fit normal distribution to known background field
                f_bk = fitdist(RDF_bk(:),'normal');
                k = k+1;
                
                % Stop if iteration limit is reached
                if k == nsamples
                    f_bk.sigma == f_ne.sigma;
                end
            end
                Mask_bk = imbinarize(abs(RDF_s0.*Mask_e),mu+f_bk.sigma);      
                RDF_s = Mask.*(RDF_s0-Mask_bk.*RDF_s0);
                RDF = RDF_s;
         else
         % Create mask of known background field
         Mask_bk = imbinarize(abs(Mask_e.*RDF_s0),mu+f_bk.sigma);
         % Subtract background field and recombine.
         %RDF_s = Mask.*(RDF_s0-SMV(Mask_bk.*RDF_s0,SphereK_e));
         %RDF_s = Mask.*(RDF_s0-SMV(Mask_bk.*RDF_s0,1));
         RDF_s = Mask.*(RDF_s0-Mask_bk.*RDF_s0);
         RDF = RDF_s;
    end  
      

    % Hemorrhage mode
    else
        [maxval,idxmax] = max(Mask_ne(:).*RDF(:));
        [r,c,p] = ind2sub(size(RDF),idxmax);
        tic
        [P,J] = regionGrowing(abs(RDF_s0),[r c p],rg_param*max(RDF_s0(:)-min(RDF_s0(:))),10);
        toc
        J_bk = logical(J);
        sigma = max(f_bk.sigma,f_ne.sigma);
        Mask_bk = imbinarize((J_bk.*RDF_s0),mu+sigma);
        RDF_s = Mask.*(RDF_s0-SMV(Mask_bk.*RDF_s0,SphereK_ne));
        Mask_bke = imbinarize(abs((Mask_e).*RDF_s),mu+sigma);
        if e_hemo_check == 1
            RDF_s = Mask.*(RDF_s-SMV(Mask_bke.*RDF_s,SphereK_e));
        else
            RDF_s = Mask.*(RDF_s-Mask_bke.*RDF_s);
            %RDF_s-SMV(Mask_bke.*RDF_s0,1);
        end
        RDF = RDF_s;
    end
    if exist('Mask_CSF','var') == 0
        Mask_CSF = [];
    end
    
save(out_file,'B0_dir','CF','delta_TE','iFreq', 'iFreq_raw', 'iMag', 'Mask', 'Mask_CSF', 'matrix_size', 'N_std', 'RDF', 'voxel_size');
end