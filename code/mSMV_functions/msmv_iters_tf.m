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
    r1 = 5; r2 = 0.5;
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
    [maxval,idxmax] = max(abs(RDF(:)));
    [r,c,p] = ind2sub(size(RDF),idxmax);  
    if Mask_e(r,c,p)>0
        disp('Maximum principle verified')
    end

    % Perform initial SMV, then address incorrect values at edge
    RDF_s0 = Mask.*(RDF-SMV(RDF,SphereK));
    RDF_s0k = RDF_s0;

    % Choose threshold
    pe = prctile(abs(RDF(Mask_e>0)-RDF_s0(Mask_e>0)),90);
    pne = prctile(abs(RDF_s0(Mask_ne>0)),90)

    t = abs(RDF(r,c,p)-RDF_s0(r,c,p));
    pe = prctile(abs(RDF(Mask_e>0)-RDF_s0(Mask_e>0)),90);
    t = min(pe,t/2);

    % Create mask of known background field
    Mask_bk = imbinarize(abs(Mask_e.*RDF_s0),t);
    Mask_ves = zeros(size(Mask_bk));
    if ~contains(in_file,'sim')
        % Vessel filter
        filt = abs(RDF-SMV(RDF,matrix_size,voxel_size,1));
        Mask_ves = imfill(imbinarize(filt,(1/4)*std(filt(:))),8,'holes'); 

        %Mask_ves = Mask_ves_edges+(Mask.*(N_std.*Mask > 0.0025) & Mask.*(N_std.*Mask < 0.01)) > 0;
        % Preserve the vessels that extend to the edge
        Mask_bk = Mask_bk == 1 & Mask_ves == 0;
        disp('Applying vessel mask')
    end

    % Establish threshold
    disp('Residual background field threshold in radians is:')
    disp(t)

    if sum(Mask_ves(:)) > 0
       vm_max = prctile(RDF_s0(Mask_ves == 1 & Mask_e == 0),97);
       vm_min = prctile(RDF_s0(Mask_ves == 1 & Mask_e == 0),3);
       RDF_s0(RDF_s0 > vm_max & Mask_ves == 1 & Mask_e == 1) = vm_max;
       RDF_s0(RDF_s0 < vm_min & Mask_ves == 1 & Mask_e == 1) = vm_min;
    end
    RDF_s = RDF_s0-SMV(RDF_s0.*Mask_bk,matrix_size,voxel_size,r2);
    maxk = 5;
    k = 0;

     %Perform additional filtering on estimated background field
    while sum(Mask_bk(:))/sum(Mask(:)) > 0.000001 || sum(Mask_bk(:))/sum(Mask(:)) == 0
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