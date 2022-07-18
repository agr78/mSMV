function cor_QSM = cor_view(QSM,Mask,voxel_size,crop)
  
  cr=@(X)X(10:end-10,10:end-10,:); 
  cr=@(X)permute(cr(X.*Mask),[2 1 3 4]);  % undoing the transpose in matlab
  ax_QSM=cr(QSM);
  ax_size=size(ax_QSM);

  cor_parg=[-3 1 2 4]; 
  idx=abs(cor_parg(1:2));
  cor_size=round(ax_size(idx).*voxel_size(idx)'/voxel_size(1));
  cor_QSM=imresize(fpermute(ax_QSM, cor_parg),cor_size);
  
end

