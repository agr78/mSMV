% Compute the variable kernel size for each position relative to the center
% of mass of the ROI mask
%
% Alexandra G. Roberts
% MRI Lab
% Cornell University
% 12/07/2022


function Mask_Kr = kernel_radius_calc(Mask,Rmax)
    rp = regionprops(Mask);
    com = round(rp.Centroid);
    Mask_Dinit = zeros(size(Mask));
    Mask_Dinit(com(1),com(2),com(3)) = 1;
    Mask_D = Mask.*bwdist(Mask_Dinit);
    Mask_K = Mask.*rescale(Mask_D,0,Rmax-1);
    Mask_Kr = Rmax-Mask_K;


    