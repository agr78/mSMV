clear
hs_path = 'C:\Users\agr78\MEDI_toolbox\MEDI_data\MEDI_data\05_HealthySubject';
hs_dir = dir(hs_path);
cd(hs_path)
for j = 1:10
    if j < 10
        fn = strcat('00',num2str(j),'romeo_RDF','.mat')
        load(fn,'-mat')
    else
        fn = strcat('0',num2str(j),'romeo_RDF','.mat')
        load(fn,'-mat')
    end
    iMag_N = make_nii(Mask.*iMag,voxel_size)
    save_nii(iMag_N,strcat(fn(1:3),'_iMag.nii'))
end