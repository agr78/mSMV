function [RDF,mask_sharp]=VSHARP(iFreq, Mask, matrix_size, voxel_size, radiuss, threshold)

if (nargin<6)
    threshold=0.2;
end
if (nargin<5)
    radiuss=[5,4,3,2,1];
end

% Prepare kernels 
[Del_Sharp, dummy, DiffMask, Mask_Sharp] = prepare_VSHARP(radiuss, Mask, matrix_size, voxel_size);
RDF = 0;
for k = 1:size(DiffMask,4)
    RDF = RDF + DiffMask(:,:,:,k) .* real(ifftn(Del_Sharp(:,:,:,k) .* fftn(iFreq)));
end

% Inverse kernel
del_sharp = Del_Sharp(:,:,:,1);         % first kernel
mask_sharp = Mask_Sharp(:,:,:,end);     % largest mask
inv_sharp = zeros(size(del_sharp));
inv_sharp(abs(del_sharp) > threshold) = 1./del_sharp(abs(del_sharp)>threshold);
RDF = mask_sharp .* ifftn(Hann_window(inv_sharp .* fftn(RDF)));

end