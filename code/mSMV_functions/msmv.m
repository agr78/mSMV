% Maximum Spherical Mean Value (mSMV)
%
% Samples and removes residual background field via the maximum value
% corollary of Green's theorem
%
% Alexandra G. Roberts
% MRI Lab
% Cornell University
% 03/31/2022

function RDF = msmv(RDF,Mask,R2s,voxel_size,radius,maxk,vr,pf)
   
    % Get matrix dimensions
    matrix_size = size(RDF);
    
    % Generate kernel with default radius of 5 mm
    if nargin <= 4
        radius = 5;
    end
    r2 = min(voxel_size(:))/2+0.05;

    % Default iteration maximum
    if nargin <= 5
        maxk = 5;
    end

    % Default vessel size parameter
    if nargin <= 6
        vr = 5*max(voxel_size(:));
    end
  
    SphereK = single(sphere_kernel(matrix_size,voxel_size,radius));

    % Partition mask
    Mne = SMV(Mask,SphereK) > 0.999;
    Me = Mask-Mne;

    % Perform initial SMV, then address incorrect values at edge
    if nargin <= 7
        RDF_s = Mask.*(RDF-SMV(RDF,SphereK));
    % Skip pre-filtering
    else 
        RDF_s = RDF;
        disp('Skipping initial SMV filtering')

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

    % Impose minimum vessel radius (Larson et. al)
    vr = max(15,vr); 
    Mv = imbinarize(fibermetric((Mask_ev.*R2s),[1:vr],'ObjectPolarity','bright'),0);
    Mb = Mb == 1 & Mv == 0;


    % Perform additional filtering on estimated background field
    k = 1;
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

end