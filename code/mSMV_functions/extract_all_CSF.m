function Mask_CSF = extract_all_CSF(R2s, Mask, voxel_size, flag_erode, thresh_R2s)

if isempty(R2s)
    Mask_ROI_CSF=[];
    return
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
    Mask = SMV(Mask, matrix_size, voxel_size, 5)>0.999;
end


Mask_CSF = (R2s < thresh_R2s).*Mask;

end