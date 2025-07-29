% Maximum Spherical Mean Value (mSMV)
%
% Samples and removes residual background field via the maximum value
% corollary of Green's theorem
%
% Inputs:
% RDF - Relative difference field (tissue or local field)
% Mask - Region of interest
% R2s - R2* map used for vessel mask
% voxel_size - Resolution used to calculate the minimum kernel radius
% radius - Prefilter radius
% maxk - Maximum number of residual background field removal iterations
% vessel_radius - Maximum vessel radius in R2* map
% prefilter - Prefilter flag, 0 if SMV filter previously used (i.e. VSHARP)
%
% Output: Filtered RDF
%
% Please cite:
% A. G. Roberts et al., "Maximum Spherical Mean Value (mSMV) 
% Filtering for Whole Brain Quantitative Susceptibility Mapping," 
% Magnetic Resonance in Medicine, 2024, DOI: 10.1002/mrm.29963

function [RDF] = msmv(RDF,Mask,R2s,voxel_size,radius,tmin,maxk,vessel_radius,B0_mag,prefilter)
    % Default to prefiltering with SMV
    if nargin <= 9 || isempty(prefilter)
        prefilter = 1;
    end
    % Default field strength
    if nargin <= 8 || isempty(B0_mag)
        B0_mag = 3;
    end
    % Default vessel size parameter
    if nargin <= 7 || isempty(vessel_radius)
        % Impose minimum vessel radius (Larson et. al)
        vessel_radius = max(15,8*max(voxel_size(:))); 
    end
    % Default iteration maximum
    if nargin <= 6 || isempty(maxk)
        maxk = 5;
    end
    % Default tmin
    if nargin <= 5 || isempty(tmin)
        tmin = 0.01;
    else
        disp('Using kernel limit parameter')
        tmin
    end
    % Default radius of 5 mm
    if nargin <= 4 || isempty(radius)
        radius = 5;
    end

    % Get matrix dimensions
    matrix_size = size(RDF);

    % Minimum radius
    r2 = min(voxel_size(:))/2+0.05;

    % Generate kernel
    SphereK = single(sphere_kernel(matrix_size,voxel_size,radius));

    % Partition mask
    Mne = SMV(Mask,SphereK) > 0.999;
    Me = Mask-Mne;

    % Perform initial SMV, then address incorrect values at edge
    if prefilter == 1
        RDF_s = Mask.*(RDF-SMV(RDF,SphereK));
    elseif prefilter == -1
        RDF_s = vSMV(RDF,Mask,voxel_size,radius);
    % Skip pre-filtering
    else 
        RDF_s = RDF;
        disp('Skipping initial SMV filtering')
    end
    RDF_s0 = RDF_s;
    
    % Check if minimum threshold should be scaled
    t = kernel_lim(RDF,voxel_size,matrix_size,Mask,B0_mag,tmin);

    % Create mask of known background field
    Mb = imbinarize(abs(Me.*RDF_s0),t);
    
    % Vessel mask
    Mask_ev = Mask-MaskErode(Mask,matrix_size,voxel_size,radius+1);
    Mv = imbinarize(fibermetric((Mask_ev.*R2s),[1:vessel_radius],'ObjectPolarity','bright'),0);
    Mb = Mb == 1 & Mv == 0;

    % Perform additional filtering on estimated background field
    k = 1;
    while sum(Mb(:))/sum(Mask(:)) > 1e-9%0.000001
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