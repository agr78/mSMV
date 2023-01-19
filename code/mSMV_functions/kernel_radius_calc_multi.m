% Compute the variable kernel size for each position relative to the center
% of mass of the ROI mask
%
% Alexandra G. Roberts
% MRI Lab
% Cornell University
% 12/07/2022


function Mask_Kr = kernel_radius_calc(Mask,Rmax)
    rp = regionprops(Mask);
    for k = 1:numel(rp)
        com = round(rp(k).Centroid);
        Mask_Dinit = zeros(size(Mask));
        Mask_Dinit(com(2),com(1),com(3)) = 1;
        Mask_D = Mask.*bwdist(Mask_Dinit);
        Mask_K = Mask.*(1./(bwdist(Mask_Dinit)));
        Mask_K(isinf(Mask_K)) = 1;
        Mask_Kr{:,:,:,k} = rescale(sqrt(Mask_K),0.5,10);
    end

    