% Helper function to permute reconstructions into axial view.
%
% Alexandra G. Roberts
% MRI Lab
% Cornell University
% 04/02/2022


function ax_QSM = ax_view(QSM,Mask,voxel_size,c)
    if c == 0
        cr = @(X)X(1:end,1:end,:); 
    else
        cr = @(X)X(c:end-c,c:end-c,:); 
    end
    cr = @(X)permute(cr(X.*Mask),[2 1 3 4]);
    ax_QSM = cr(QSM);
    ax_size = size(ax_QSM);
end
