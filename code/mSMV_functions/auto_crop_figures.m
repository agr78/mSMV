% Helper function to permute reconstructions into axial, coronal, and
% sagittal views and automatically crop output image.
%
% Alexandra G. Roberts
% MRI Lab
% Cornell University
% 03/30/2023

function auto_crop_figures(QSM,Mask,voxel_size,file_path,axn,corn,sagn,out_size,im_type)

    cr = @(X)((X.*Mask)); 
    ax_QSM = cr(QSM);
    ax_Mask = cr(Mask);
    ax_size = size(ax_QSM);

    sag_parg = [-3 1 2 4]; 
    idx = abs(sag_parg(1:2));
    sag_size = round(ax_size(idx).*voxel_size(idx)'/voxel_size(1));
    sag_QSM = imresize(fpermute(ax_QSM, sag_parg),sag_size);
    sag_Mask = imresize(fpermute(ax_Mask, sag_parg),sag_size);

    cor_parg = [-3 2 1 4]; 
    idx = abs(cor_parg(1:2));
    cor_size = round(ax_size(idx).*voxel_size(idx)'/voxel_size(1));
    cor_QSM = imresize(fpermute(ax_QSM, cor_parg),cor_size);
    cor_Mask = imresize(fpermute(ax_Mask, cor_parg),cor_size);
 
    psize = max([max(ax_size)]);
    pad = @(x)padarray(x,abs(floor(double(psize-[size(sag_QSM(:,:,109),1) size(sag_QSM(:,:,109),1)])./2)),0,'both');

    ax_QSM_slice = ax_QSM(:,:,axn);
    ax_Mask_slice = ax_Mask(:,:,axn);
    sag_QSM_slice = pad(sag_QSM(:,:,corn));
    sag_Mask_slice = pad(sag_Mask(:,:,corn));
    c = (max(size(sag_QSM_slice))-max(size(ax_QSM_slice)))/2;
    sag_QSM_slice = imcrop(sag_QSM_slice, [c 0 psize psize]);
    sag_Mask_slice = imcrop(sag_Mask_slice, [c 0 psize psize]);
    cor_QSM_slice = pad(cor_QSM(:,:,sagn));
    cor_Mask_slice = pad(cor_Mask(:,:,sagn));
    s = (max(size(cor_QSM_slice))-max(size(ax_QSM_slice)))/2;
    cor_QSM_slice = imcrop(cor_QSM_slice, [s 0 psize psize]);
    
    win = 0.5;
    lev = 0; 
    im_ax = apply_wl(ax_QSM_slice, win, lev); 
    im_sag = apply_wl(sag_QSM_slice, win, lev); 
    im_cor = apply_wl(cor_QSM_slice, win, lev); 

    cd(file_path)
    imname_ax = lower(strcat(im_type,'_',num2str(axn),'_','ax','.tif'));
    imname_sag = lower(strcat(im_type,'_',num2str(corn),'_','cor','.tif'));
    imname_cor = lower(strcat(im_type,'_',num2str(sagn),'_','sag','.tif'));

    [I,J] = find(ax_Mask_slice,1,'first')
    imwrite((uint8(255*(im_ax(round(J/4):end-round(J/4),round(J/4):end-round(J/4))))), imname_ax);
    [I,J] = find(sag_Mask_slice,1,'first')
    imwrite((uint8(255*(im_sag(round(J/4):end-round(J/4),round(J/4):end-round(J/4))))), imname_sag);
    [I,J] = find(cor_Mask_slice,1,'first')
    imwrite((uint8(255*(im_cor(round(J/4):end-round(J/4),round(J/4):end-round(J/4))))), imname_cor);
end
