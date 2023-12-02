cases = dir();
for i = 1:numel(cases)
    if ~contains(cases(i).name,'.') && ~contains(cases(i).name,'..')
        cd(cases(i).name)
        acq = dir();
        cd(acq(3).name)
        contrasts = dir();
        for i = 1:numel(contrasts)
            if contains(contrasts(i).name,'AXL_GRE') 
                [iField,voxel_size,matrix_size,CF,delta_TE,TE,B0_dir,B0_mag,files] = Read_DICOM(contrasts(i).name);
                iMag = squeeze(sqrt(sum(abs(iField).^2,4)));
                Mask = BET(iMag,matrix_size,voxel_size);
                [iFreq_raw,N_std] = Fit_ppm_complex(iField);
                iFreq = romeo(iFreq_raw, iMag, Mask);
                [RDF,shim] = PDF(iFreq,N_std,Mask,matrix_size,voxel_size,B0_dir,0,100);
                iField_c = BGCor(iField, iFreq-(Mask.*(RDF-SMV(RDF,matrix_size,voxel_size,5))), TE); 
                R2s = arlo(TE,abs(iField_c));
                Mask_CSF = extract_whole_CSF(R2s,Mask,voxel_size,0,5);
            end
            if contains(contrasts(i).name,'nii') 
                cd(contrasts(i).name)
                niis = dir();
                for kk = 1:numel(niis)
                    if contains(niis(kk).name,'T1FS_gm_mask_to_MAG')
                        gray_matter_mask = niftiread(niis(kk).name);
                        cd ..
                    end

                    if contains(niis(kk).name,'T1FS_brain_label_to_MAG')
                        rois = niftiread(niis(kk).name);
                        save rois rois
                        cd ..
                    end
                end
            end
   
        end
        % save RDF -v7.3
        cd ../..
    end
end

            
%%

for i = 1:11
    file_name = strcat('RDF',string(i),'.mat');
    load(file_name)
    radius = 5;
    disp(strcat('Processing ',{' '},file_name))
    % Store variables that will be overwritten
    RDF_c = RDF;
    Mask_c = Mask;
    Mask_SMV = MaskErode(Mask,matrix_size,voxel_size,radius);

    % Preprocess local field with VSHARP with optimized parameters
    [RDF,Mask_VSHARP] = V_SHARP(iFreq,Mask,'voxelsize',voxel_size(:)','smvsize',5);
    Mask = Mask_VSHARP;
    vsharp_filename = strcat('RDF',string(i),'_vsharp.mat');
    save(vsharp_filename,'RDF','matrix_size','voxel_size','Mask','B0_dir','CF','delta_TE','iFreq','iFreq_raw','iMag','Mask_CSF','N_std')
   
    % Preprocess local field with mSMV
    msmv_filename = strcat('RDF_',string(i),'_msmv_mk.mat');
    msmv(file_name,msmv_filename)

    % Preprocess local field with SMV
    Mask = Mask_SMV;
    RDF = Mask_SMV.*(RDF_c-SMV(RDF_c,matrix_size,voxel_size,radius));
    smv_filename = strcat('RDF',string(i),'_smv.mat');
    save(strcat(smv_filename),'RDF','matrix_size','voxel_size','Mask','B0_dir','CF','delta_TE','iFreq','iFreq_raw','iMag','Mask_CSF','N_std')
    
    % Reconstruct using MEDI-L1 with the appropriate dipole kernel for each
    % method
    reg_lam = 1000;
    reg_csf = 100;
    Masks = {Mask_c Mask_SMV Mask_c Mask_VSHARP};
    QSM_VSHARP = MEDI_L1('filename',vsharp_filename,'lambda',reg_lam,'lambda_CSF',reg_csf,'dipole_filter',1,'smv',radius);
    QSM_msmv =  MEDI_L1('filename',msmv_filename,'lambda',reg_lam,'lambda_CSF',reg_csf,'dipole_filter',1,'smv',radius);
    QSM_smv =  MEDI_L1('filename',smv_filename,'lambda',reg_lam,'lambda_CSF',reg_csf,'dipole_filter',1,'smv',radius);
    QSM_ctrl =  MEDI_L1('filename',file_name,'lambda',reg_lam,'lambda_CSF',reg_csf,'dipole_filter',0);
    QSMs = {QSM_ctrl QSM_smv QSM_msmv QSM_VSHARP};

    save(strcat('RDF',string(i),'_qsms_msmv_mk.mat'),'QSMs','Masks','matrix_size','voxel_size')
    
end

%%
