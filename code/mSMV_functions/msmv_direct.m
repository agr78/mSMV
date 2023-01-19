% Direct maximum Spherical Mean Value (dmSMV)
%
% Samples and removes residual background field via the maximum value
% corollary of Green's theorem
%
% Alexandra G. Roberts
% MRI Lab
% Cornell University
% 12/08/2022

function dmsmv(in_file,out_file)

    % Load local field
    load(in_file)
    
    % Generate kernel
    radius = 5;
    r2 = radius./10;
    SphereK = single(sphere_kernel(matrix_size,voxel_size,radius));

    % Partition mask
    Mask_vec = Mask(:);
    Mask_ne = SMV(Mask,SphereK) > 0.999;
    Mask_e = Mask-Mask_ne;

    % Perform initial SMV, then address incorrect values at edge
   
    RDF_s = RDF;
    RDF_s0 = RDF_s;

    % Calculate threshold using the maximum corollary and kernel limit
    t = kernel_lim(RDF,voxel_size,matrix_size,Mask);
    Mask_ev = Mask-MaskErode(Mask,matrix_size,voxel_size,radius+1);
    
    % Create mask of known background field
    Mb = imbinarize(abs(Mask_e.*RDF_s0),t);
    if exist('R2s','var') == 1
        Mv = imbinarize(fibermetric((R2s),[1:5*max(voxel_size(:))],'ObjectPolarity','bright'),0);
        Mb = Mb == 1 & Mv == 0;
    else
        Mv = zeros(size(Mb));
    end

    % Perform additional filtering on estimated background field
    k = 1;
    maxk = 5;
    voxel_radii = Mask.*kernel_radius_calc_lin(Mask,radius);
    voxel_radii_d = Mask.*discretize(voxel_radii,1:1:max(voxel_radii(:))+1);
    voxel_radii_d(isnan(voxel_radii_d)) = 0;
    % Discretization
    voxel_radii_d = discretize(voxel_radii,5);
    
    while sum(Mb(:))/sum(Mask(:)) > 0.000001 || sum(Mb(:))/sum(Mask(:)) == 0
            for j = flip(2:length(unique(voxel_radii_d)))
                     Mb = Mask_e.*imbinarize(abs(RDF_s),t) == 1;
                     Mbs{j} = Mb == 1 & Mv == 0;
                     Mss{j} = voxel_radii_d == j;
                     RDF_SMVs{j} = SMV(Mss{j}.*Mbs{j}.*RDF_s,matrix_size,voxel_size,j);
                     RDF_s = Mask.*(RDF_s-RDF_SMVs{j});
                     k = k+1;
            end
            k = k+1;
        if k > maxk-1
            break
        end
    end

    RDF = RDF_s;
    
save(out_file,'B0_dir','CF','delta_TE','iFreq', 'iFreq_raw', 'iMag',...
    'Mask', 'Mask_CSF', 'matrix_size', 'N_std', 'RDF', 'voxel_size');
end