function ax_QSM = ax_view(QSM,Mask,voxel_size)
    cr=@(X)X(10:end-10,10:end-10,:); 
    cr=@(X)permute(cr(X.*Mask),[2 1 3 4]);  % undoing the transpose in matlab
    ax_QSM=cr(QSM);
    ax_size=size(ax_QSM);
end
