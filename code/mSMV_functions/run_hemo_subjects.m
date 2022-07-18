for j = 1:5
    filename = strcat('hemo_',string(j),'_romeo.mat');
    msmv_filename = strcat('RDF_hemo_',string(j),'_romeo_msmv.mat');
    msmv(filename,msmv_filename)
    QSM_msmv =  MEDI_L1_filt_dipole('filename',msmv_filename,'lambda',1000);
    QSM_smv =  MEDI_L1('filename',filename,'lambda',1000);
    QSM_ctrl =  MEDI_L1_orig_dipole('filename',filename,'lambda',1000);
    vis([QSM_ctrl QSM_smv QSM_msmv],'WindowLevel',[0.5 0])
    QSMs = {QSM_ctrl, QSM_smv, QSM_msmv};
    recon_name = strcat('hemo_',string(j),'_romeo_recons.mat');
    save(recon_name,'QSMs'); 
end

%%
make_figures(QSM_ctrl,Mask,voxel_size','figures\hemo',33,1,1,[256 256],'hemo_ctrl')
cd ..
cd ..
make_figures(QSM_smv,MaskErode(Mask,matrix_size,voxel_size,5),voxel_size','figures\hemo',33,1,1,[256 256],'hemo_smv')
cd ..
cd ..
make_figures(QSM_msmv,Mask,voxel_size','figures\hemo',33,1,1,[256 256],'hemo_msmv')