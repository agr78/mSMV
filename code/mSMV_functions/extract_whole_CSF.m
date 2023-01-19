% Whole brain CSF mask
% Implementation of the global CSF mask based on extract_CSF():
% Z. Liu, P. Spincemaille, Y. Yao, Y. Zhang, and Y. Wang, 
% "MEDI+0: Morphology enabled dipole inversion with 
% automatic uniform cerebrospinal fluid zero reference for 
% quantitative susceptibility mapping", 
% Magnetic Resonance in Medicine, vol. 79, no. 5, pp. 2795–2803, 2018.
%
% Obtains a global CSF mask according to:
% A. V. Dimov, T. D. Nguyen, P. Spincemaille, E. M. Sweeney, N. Zinger, 
% I. Kovanlikaya, B. H. Kopell, S. A. Gauthier, and Y. Wang, 
% “Global cerebrospinal fluid as a zero‐reference regularization for 
% brain quantitative susceptibility mapping”, 
% Journal of Neuroimaging, vol. 32, no. 1, pp. 141–147, 2022.
%
% Mean threshold of 5.25 Hz from: 
% X. He and D. A. Yablonskiy, 
% “Quantitative BOLD: 
% Mapping of human cerebral deoxygenated blood volume and 
% oxygen extraction fraction: Default state”, 
% Magnetic Resonance in Medicine, vol. 57, no. 1, pp. 115–126, 2007
%
%
% Alexandra G. Roberts
% MRI Lab
% Cornell University
% 09/25/2022

function Mask_CSF = extract_whole_CSF(R2s, Mask, voxel_size, flag_erode, thresh_R2s, fs)

if isempty(R2s)
    Mask_ROI_CSF=[];
    return
end

if nargin < 6
    fs = 3;
end
if nargin < 5
    thresh_R2s = 5;
end
if nargin < 4
    flag_erode = 1;
end

n_region_cen = 3;
matrix_size = size(Mask);

if flag_erode
    Mask = SMV(Mask, matrix_size, voxel_size, 10)>0.999;
end

Mask_CSF = (R2s < thresh_R2s).*Mask;

if fs == 3
    Z = 5.25;
else
    Z = 5.25.*(fs/3);
end 

while mean(R2s(Mask_CSF>0)) < Z 
    thresh_R2s = thresh_R2s*1.1;
    Mask_CSF = (R2s < thresh_R2s).*Mask;
    if thresh_R2s > 12
        break
    end
end

thresh_R2s

end