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
    [maxval,idxmax] = max(abs(RDF(:)));
    [r,c,p] = ind2sub(size(RDF),idxmax);  
    if Mask_e(r,c,p)>0
        disp('Maximum principle verified')
    end

    % Perform initial SMV, then address incorrect values at edge
    RDF_s0 = Mask.*(RDF-SMV(RDF,SphereK));
    RDF_s0k = RDF_s0;

    % Choose threshold
    t = abs(RDF(r,c,p)-RDF_s0(r,c,p));
    pe = prctile(abs(RDF(Mask_e>0)-RDF_s0(Mask_e>0)),90);
    t = min(pe,t/2);
    pne = prctile(abs(RDF_s0(Mask_ne>0)),98);

    % Create mask of known background field
    Mask_bk = imbinarize(abs(Mask_e.*RDF_s0),t);
    
    if ~contains(in_file,'sim')
        % Vessel filter
        filt = abs(RDF-SMV(RDF,matrix_size,voxel_size,1));
        Mask_ves = imbinarize(filt,std(filt(:))); 
        
        % Preserve the vessels that extend to the edge
        Mask_bk = Mask_bk == 1 & Mask_ves == 0;
        disp('Applying vessel mask')
    end

    % Establish threshold
    disp('Residual background field threshold in radians is:')
    disp(pe)

    % Rescale background field values to known local field values
    RDF_s0(Mask_bk == 1) = rescale(RDF_s0(Mask_bk == 1),...
    -pne,pne,...
    "InputMax",max(RDF_s0(Mask_bk == 1)),"InputMin",...
    min(RDF_s0(Mask_bk == 1)));
    disp('Rescaling residual background field to:') 
    disp('+/-'); disp(pne)
    RDF_s = RDF_s0;

    % Prepare for reconstruction
    RDF = RDF_s;
    
save(out_file,'B0_dir','CF','delta_TE','iFreq', 'iFreq_raw', 'iMag',...
    'Mask', 'Mask_CSF', 'matrix_size', 'N_std', 'RDF', 'voxel_size');
end