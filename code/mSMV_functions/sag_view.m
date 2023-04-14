% Helper function to permute reconstructions into sagittal view.
%
% Alexandra G. Roberts
% MRI Lab
% Cornell University
% 04/02/2022

function sag_QSM = sag_view(QSM,Mask,voxel_size)
    
    %cr = @(X)X(10:end-10,10:end-10,:); 
    cr = @(X)permute((X.*Mask),[2 1 3 4]); 
    ax_QSM = cr(QSM);
    ax_size = size(ax_QSM);
    sag_parg = [-3 2 1 4]; 
    idx = abs(sag_parg(1:2));
    sag_size = round(ax_size(idx).*voxel_size(idx)'/voxel_size(1));
    sag_QSM = imresize(fpermute(ax_QSM, sag_parg),sag_size);
   

end