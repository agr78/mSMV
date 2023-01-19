% Compute the variable kernel size for each position relative to the center
% of mass of the ROI mask
%
% Alexandra G. Roberts
% MRI Lab
% Cornell University
% 12/07/2022


function Mask_D = kernel_radius_calc(Mask)
    rp = regionprops(Mask);
    com = round(rp.Centroid);
    Mask_Dinit = zeros(size(Mask));
    Mask_Dinit(com(1),com(2),com(3)) = 1;
    Mask_D = bwdist(Mask_Dinit);
    Mask_K = Mask.*(1./(bwdist(Mask_Dinit)));
    Mask_K(isinf(Mask_K)) = 2;

    