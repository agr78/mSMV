function sag_QSM = sag_view(QSM,Mask,voxel_size,crop)
    
    cr=@(X)X(10:end-10,10:end-10,:); 
    cr=@(X)permute(cr(X.*Mask),[2 1 3 4]);  % undoing the transpose in matlab
    ax_QSM=cr(QSM);
    ax_size=size(ax_QSM);
    sag_parg=[-3 2 1 4]; 
    idx=abs(sag_parg(1:2));
    sag_size=round(ax_size(idx).*voxel_size(idx)'/voxel_size(1));

    % original
    sag_QSM=imresize(fpermute(ax_QSM, sag_parg),sag_size);
    %sag_QSM = imresize3(fpermute(ax_QSM,sag_parg),[sag_size(2,2) sag_size(1,2) sag_size(2,1)]);

end