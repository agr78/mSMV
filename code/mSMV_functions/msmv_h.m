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
    radius = 5;
    r2 = radius./10;
    SphereK = single(sphere_kernel(matrix_size,voxel_size,radius));

    % Partition mask
    M_ne = SMV(Mask,SphereK) > 0.999;
    M_e = Mask-M_ne;
    M_ev = Mask-MaskErode(Mask,matrix_size,voxel_size,radius+1);

    % Create vessel mask 
    if exist('R2s','var') == 1
        Mv = imbinarize(fibermetric((M_ev.*R2s),[1:5*max(voxel_size(:))],'ObjectPolarity','bright'),0);
    else
        Mv = zeros(size(Mb));
    end

    % Perform initial SMV, then address incorrect values at edge
    RDF_in = M_ne.*(RDF-SMV(RDF,SphereK));
    voxel_radii = Mask.*kernel_radius_calc_lin(Mask,radius);
    voxel_radii_d = Mask.*discretize(voxel_radii,1:1:max(voxel_radii(:))+1);
    voxel_radii_d(isnan(voxel_radii_d)) = 0;
    for j = 1:max(voxel_radii_d(:))
                 Ms = voxel_radii_d == j;
                 Ms = Ms == 1 & Mv == 0;
                 RDF_SMV{j} = SMV(Ms.*RDF,matrix_size,voxel_size,j);
    end
    RDF_s = Mask.*(RDF-M_ne.*SMV(sum(cat(4,RDF_SMV{:}),4),matrix_size,voxel_size,radius)-M_e.*SMV(sum(cat(4,RDF_SMV{:}),4),matrix_size,voxel_size,r2));
    RDF_s0 = RDF_s;

    % Calculate threshold using the maximum corollary and kernel limit
    t = kernel_lim(RDF,voxel_size,matrix_size,Mask);
    

    % Create mask of known background field
    Mb = imbinarize(abs(M_e.*RDF_s0),t);
    Mb = Mb == 1 & Mv == 0;

    % Perform additional filtering on estimated background field
    k = 1;
    maxk = 5;
    while sum(Mb(:))/sum(Mask(:)) > 0.000001 || sum(Mb(:))/sum(Mask(:)) == 0
        Mb = imbinarize(abs(M_e.*RDF_s),t) == 1;
        Mb = Mb == 1 & Mv == 0;
        RDF_s = Mask.*(RDF_s-SMV(Mb.*RDF_s,matrix_size,voxel_size,r2));
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