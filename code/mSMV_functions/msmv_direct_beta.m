% Maximum Spherical Mean Value (mSMV)
%
% Samples and removes residual background field via the maximum value
% corollary of Green's theorem
%
% Alexandra G. Roberts
% MRI Lab
% Cornell University
% 03/31/2022

function [RDF_msmvd,Mvd] = msmv_direct(RDF,Mask,radius,voxel_size,R2s)

    % Compute matrix size
    matrix_size = size(Mask);
    
    % Generate kernel
    r2 = radius./10;
    SphereK = single(sphere_kernel(matrix_size,voxel_size,radius));

    % Partition mask
    Mask_ne = SMV(Mask,SphereK) > 0.999;
    Mask_e = Mask-Mask_ne;

    % Perform initial SMV, then address incorrect values at edge
    %RDF_s = Mask.*(RDF-SMV(RDF,SphereK));
    RDF_s = RDF;
    RDF_s0 = RDF_s;

    % Calculate threshold using the maximum corollary and kernel limit
    t = kernel_lim(RDF,voxel_size,matrix_size,Mask);
    
    Mask_ev = Mask-MaskErode(Mask,matrix_size,voxel_size,radius+1);
    

    % Create mask of known background field
    Mb = imbinarize(abs(RDF_s0),t);
    if exist('R2s','var') == 1
        Mv = imbinarize(fibermetric(R2s,[1:5*max(voxel_size(:))],'ObjectPolarity','bright'),0);
        Mb = Mb == 1 & Mv == 0;
    else
        Mv = zeros(size(Mb));
    end

    % Perform additional filtering on estimated background field
    k = 1;
    maxk = 5;
    while sum(Mb(:))/sum(Mask(:)) > 0.000001 || sum(Mb(:))/sum(Mask(:)) == 0
        Mb = imbinarize(abs(RDF_s),t) == 1;
        Mb = Mb == 1 & Mv == 0;
        RDF_s = Mask.*(RDF_s-SMV(Mb.*RDF_s,matrix_size,voxel_size,r2));
        k = k+1;
        if k > maxk-1
            break
        end
    end
    % Prepare for reconstruction
    RDF_msmvd = RDF_s;
    Mvd = Mv;
end