% Helper function to permute reconstructions into axial view.
%
% Alexandra G. Roberts
% MRI Lab
% Cornell University
% 04/02/2022


function ax_QSM = ax_view(QSM,Mask,voxel_size)
    cr = @(X)permute(X.*Mask,[2 1 3 4]);
    if length(size(QSM)) 
        ax_QSM = cr(QSM);
        ax_size = size(ax_QSM);
    else
        for j = 1:length(size(QSM,4))
            ax_QSM(:,:,:,j) = cr(QSM(:,:,:,j));
        end
end
