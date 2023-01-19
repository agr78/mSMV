% Maximum Spherical Mean Value (mSMV)
%
% Samples and removes residual background field via the maximum value
% corollary of Green's theorem
%
% Alexandra G. Roberts
% MRI Lab
% Cornell University
% 03/31/2022

function msmv(in_file,out_file,r1,r2)
    % Set default vessel mask
    ves_mask = 1;
    maxk = 5;
    radius = r1;
    % Load local field
    load(in_file)
    
    % Generate kernel
    SphereK = single(sphere_kernel(matrix_size,voxel_size,radius));

    % Partition mask
    Mask_ne = SMV(Mask,SphereK) > 0.999;
    Mask_e = Mask-Mask_ne;

    % Find max, on edge via Green's theorem
    [maxval,idxmax] = max(abs(RDF(:)));
    [r,c,p] = ind2sub(size(RDF),idxmax);  
    if Mask_e(r,c,p)>0
        disp('Maximum principle verified')
    end

    % Perform initial SMV, then address incorrect values at edge
    RDF_s0 = Mask.*(RDF-SMV(RDF,SphereK));

    % Choose threshold
    t = abs(RDF(r,c,p)-RDF_s0(r,c,p));
    pe = prctile(abs(RDF(Mask_e>0)-RDF_s0(Mask_e>0)),90);
    t = min(pe,t/2);

    % Create mask of known background field
    Mask_bk = imbinarize(abs(Mask_e.*RDF_s0),t);
    
    if ves_mask == 1
        % Vessel filter
        N_stdm = N_std.*Mask;
        filt = RDF-SMV(RDF,matrix_size,voxel_size,1);
        Mask_ves = (N_stdm<2*std(N_stdm(Mask>0)) & N_stdm>std(N_stdm(Mask>0)))& filt>0;
        % Preserve the vessels that extend to the edge
        Mask_bk = Mask_bk == 1 & Mask_ves == 0;
        disp('Applying vessel mask')
    else
        Mask_ves = zeros(matrix_size);
    end
    if sum(Mask_ves(:)) > 0
       vm_max = prctile(RDF_s0(Mask_ves == 1 & Mask_e == 0),99.5);
       vm_min = prctile(RDF_s0(Mask_ves == 1 & Mask_e == 0),0.05);
       RDF_s0(RDF_s0 > vm_max & Mask_ves == 1) = vm_max;
       RDF_s0(RDF_s0 < vm_min & Mask_ves == 1) = vm_min;
    end
    RDF_s = RDF_s0-SMV(RDF_s0.*Mask_bk,matrix_size,voxel_size,r2);
    k = 0;

    %Perform additional filtering on estimated background field
    while sum(Mask_bk(:))/sum(Mask(:)) > 0.001
        Mask_bk = imbinarize(abs(Mask_e.*RDF_s),t) == 1 & Mask_ves == 0;
        RDF_s = Mask.*(RDF_s-SMV(Mask_bk.*RDF_s,matrix_size,voxel_size,r2));
        k = k+1;
        if k > maxk-1
            break
        end
    end
  
    % Prepare for reconstruction
    RDF = RDF_s;
    
save(out_file,'B0_dir','CF','delta_TE','iFreq', 'iFreq_raw', 'iMag',...
    'Mask', 'Mask_CSF', 'matrix_size', 'N_std', 'RDF', 'voxel_size');
end