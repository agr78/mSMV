% Maximum Spherical Mean Value (mSMV)
%
% Samples and removes residual background field via the maximum value
% corollary of Green's theorem
%
% Alexandra G. Roberts
% MRI Lab
% Cornell University
% 03/31/2022

function msmv(in_file,out_file,pf)
   
    % Load local field
    load(in_file)
    
    % Generate kernel
    radius = 5;
    r2 = radius./10;
    % Make sure all datasets use minimum radius kernel.
    if min(voxel_size(:))>=1
        r2 = min(voxel_size(:))/2+0.05;
        r2
    end
    SphereK = single(sphere_kernel(matrix_size,voxel_size,radius));

    % Partition mask
    Mne = SMV(Mask,SphereK) > 0.999;
    Me = Mask-Mne;

    % Perform initial SMV, then address incorrect values at edge
    if nargin == 2
        RDF_s = Mask.*(RDF-SMV(RDF,SphereK));

    else 
        RDF_s = RDF;

    end
    RDF_s0 = RDF_s;

    % Check if minimum threshold should be scaled
    if exist('B0_mag','var') == 1
        t = kernel_lim(RDF,voxel_size,matrix_size,Mask,B0_mag);
    else
        % Calculate threshold using the maximum corollary and kernel limit
        t = kernel_lim(RDF,voxel_size,matrix_size,Mask);
    end
    Mask_ev = Mask-MaskErode(Mask,matrix_size,voxel_size,radius+1);

    % Create mask of known background field
    Mb = imbinarize(abs(Me.*RDF_s0),t);
    if exist('R2s','var') == 1
        vr = 5*max(voxel_size(:));
        % Impose minimum vessel radius (Larson et. al)
        vr = max(15,vr); 
        Mv = imbinarize(fibermetric((Mask_ev.*R2s),[1:vr],'ObjectPolarity','bright'),0);
        Mb = Mb == 1 & Mv == 0;
    else
        Mv = zeros(size(Mb));
    end

    % Perform additional filtering on estimated background field
    k = 1;
    maxk = 5;
    while sum(Mb(:))/sum(Mask(:)) > 0.000001 || sum(Mb(:))/sum(Mask(:)) == 0
        Mb = imbinarize(abs(Me.*RDF_s),t) == 1;
        Mb = Mb == 1 & Mv == 0;
        RDF_s = Mask.*(RDF_s-SMV(Mb.*RDF_s,matrix_size,voxel_size,r2));
        k = k+1;
        if k > maxk-1
            break
        end
    end
    % Prepare for reconstruction
    RDF = RDF_s;
    if exist('Mask_CSF','var')
    save(out_file,'B0_dir','CF','delta_TE','iFreq', 'iFreq_raw', 'iMag',...
        'Mask', 'Mask_CSF', 'matrix_size', 'N_std', 'RDF', 'voxel_size');
    else
        save(out_file,'B0_dir','CF','delta_TE','iFreq', 'iFreq_raw', 'iMag',...
        'Mask', 'matrix_size', 'N_std', 'RDF', 'voxel_size');

end