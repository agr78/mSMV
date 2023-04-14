% Helper function to permute reconstructions into axial, coronal, and
% sagittal views.
%
% Alexandra G. Roberts
% MRI Lab
% Cornell University
% 04/02/2022

function make_figures(QSM,Mask,voxel_size,file_path,axn,corn,sagn,out_size,im_type)

    %cr = @(X)X(C:end-C,C:end-C,:);
    %cr = @(X)permute(cr(X.*Mask),[2 1 3 4]); 
    cr = @(X)((X.*Mask)); 
    ax_QSM = cr(QSM);
    ax_size = size(ax_QSM);

    sag_parg = [-3 1 2 4]; 
    idx = abs(sag_parg(1:2));
    sag_size = round(ax_size(idx).*voxel_size(idx)'/voxel_size(1));
    sag_QSM = imresize(fpermute(ax_QSM, sag_parg),sag_size);

    cor_parg = [-3 2 1 4]; 
    idx = abs(cor_parg(1:2));
    cor_size = round(ax_size(idx).*voxel_size(idx)'/voxel_size(1));
    cor_QSM = imresize(fpermute(ax_QSM, cor_parg),cor_size);
 
    psize = max([max(ax_size)]);
    pad = @(x)padarray(x,abs(floor(double(psize-[size(sag_QSM(:,:,109),1) size(sag_QSM(:,:,109),1)])./2)),0,'both');

    ax_QSM_slice = ax_QSM(:,:,axn);
    sag_QSM_slice = pad(sag_QSM(:,:,corn));
    c = (max(size(sag_QSM_slice))-max(size(ax_QSM_slice)))/2;
    sag_QSM_slice = imcrop(sag_QSM_slice, [c 0 psize psize]);
    cor_QSM_slice = pad(cor_QSM(:,:,sagn));
    s = (max(size(cor_QSM_slice))-max(size(ax_QSM_slice)))/2;
    cor_QSM_slice = imcrop(cor_QSM_slice, [s 0 psize psize]);
    
    win = 0.5;
    lev = 0; 
    tmp_ax = apply_wl(ax_QSM_slice, win, lev); 
    tmp_sag = apply_wl(sag_QSM_slice, win, lev); 
    tmp_cor = apply_wl(cor_QSM_slice, win, lev); 

    cd(file_path)
    imname_ax = lower(strcat(im_type,'_',num2str(axn),'_','ax','.tif'));
    imname_sag = lower(strcat(im_type,'_',num2str(corn),'_','cor','.tif'));
    imname_cor = lower(strcat(im_type,'_',num2str(sagn),'_','sag','.tif'));

    imwrite(imresize(uint8(255*(tmp_ax)),out_size), imname_ax);
    imwrite(imresize(uint8(255*(tmp_sag)),out_size), imname_sag);
    imwrite(imresize(uint8(255*(tmp_cor)),out_size), imname_cor);
end
