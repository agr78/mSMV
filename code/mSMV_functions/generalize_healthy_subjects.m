cd 'healthy_subjects/control'
for j = 1:10
    if j < 10
        file_name = strcat('00',num2str(j),'_RDF_wcsf_R2S','.mat');
    else 
        file_name = strcat('0',num2str(j),'_RDF_wcsf_R2S','.mat');
    end     
    load(file_name)
    clear RDF
    cd ..
    radius = 1;
    Mask_c = Mask;
    % PDF background field removal
    [RDF_PDF,shim] = PDF(iFreq,N_std,Mask_c,matrix_size,voxel_size,B0_dir,0,100);

    % VSHARP background field removal
    [RDF_VSHARP,Mask_VS] = BKGRemovalVSHARP(iFreq,Mask_c,matrix_size);

    % LBV background field removal
    [RDF_LBV] = LBV(iFreq,Mask_c,matrix_size,voxel_size,0.01,-1,1,30,100,100);
    fid = fopen(strcat('mask_p1.bin'),'r');
    Mask_LBV = reshape(fread(fid,matrix_size(1)*matrix_size(2)*matrix_size(3),'int'),matrix_size);
    
    % Create files for dipole inversion and reconstruct
    RDFs = {'RDF_LBV' 'RDF_PDF' 'RDF_VSHARP' };
    for k = 1:length(RDFs)
        RDF = eval(RDFs{k});
        filename = RDFs{k};
        
        % Save the correct mask for each local field
        if contains(filename,'VSHARP') == 1
            Mask = Mask_VS;
        elseif contains(filename,'LBV') == 1
            Mask = Mask_LBV;
        else
            Mask = Mask_c;
        end
        
        cd gen
        save(strcat(file_name(1:3),'_',filename),'RDF','iFreq','iFreq_raw','iMag','N_std','Mask',...
            'matrix_size','voxel_size', 'delta_TE', 'CF','B0_dir','Mask_CSF','R2s');
        msmv(strcat(file_name(1:3),'_',filename),strcat('msmv_gen',strcat(file_name(1:3),'_',filename)))
        msmv_direct(strcat(file_name(1:3),'_',filename),strcat('msmd_gen',strcat(file_name(1:3),'_',filename)))
        % Select the correct dipole for each local field
        if contains(filename,'VSHARP') == 1
            QSMs_ctrl{k} =  MEDI_L1('filename',strcat(file_name(1:3),'_',filename),'lambda',1000,'lambda_CSF',1000,'dipole_filter',1);
            QSMs_dmsmv{k} =  MEDI_L1('filename',strcat('msmd_gen',strcat(file_name(1:3),'_',filename)),'lambda',1000,'lambda_CSF',1000,'dipole_filter',1);
        else
            QSMs_ctrl{k} =  MEDI_L1('filename',strcat(file_name(1:3),'_',filename),'lambda',1000,'lambda_CSF',1000,'dipole_filter',0);
            QSMs_dmsmv{k} =  MEDI_L1('filename',strcat('msmd_gen',strcat(file_name(1:3),'_',filename)),'lambda',1000,'lambda_CSF',1000,'dipole_filter',0);
        end
        QSMs_msmv{k} =  MEDI_L1('filename',strcat('msmv_gen',strcat(file_name(1:3),'_',filename)),'lambda',1000,'lambda_CSF',1000,'dipole_filter',1);
        save(strcat('QSM_gen_',strcat(file_name(1:3))),'QSMs_ctrl','QSMs_dmsmv','QSMs_msmv')
        cd ..
    end
    cd control
end


