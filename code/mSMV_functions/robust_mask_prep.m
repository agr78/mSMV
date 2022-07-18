for j = 1:10
    if j < 10
        load(strcat('00',string(j),'romeo_RDF.mat'))
    else
        load(strcat('0',string(j),'romeo_RDF.mat'))
    end
    cd rmasks
    Mask_r = percentile_mask(Mask,iMag);
    save(strcat('Mask_r_',string(j),'.mat'),'Mask_r')
    cd ..
%     cd nii
%     iMag_nii = make_nii(iMag,voxel_size);
%     save_nii(iMag_nii,strcat('mag_',string(j),'.nii'));
%     iFreq_nii = make_nii(iFreq_raw,voxel_size);
%     save_nii(iFreq_nii,strcat('phase_',string(j),'.nii'))
%     Mask_nii = make_nii(double(Mask),voxel_size);
%     save_nii(iFreq_nii,strcat('mask_',string(j),'.nii'))
%     cd ..
end
