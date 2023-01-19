%% Prepare RDFs for healthy subjects
save_data = 1;
cd data/simulation
load('optimal_params.mat')
cd ..
cd 'healthy_subjects/control'
for j = 1:10
    if j < 10
        file_name = strcat('00',num2str(j),'_RDF_wcsf_R2S','.mat');
    else 
        file_name = strcat('0',num2str(j),'_RDF_wcsf_R2S','.mat');
    end     
    load(file_name)
    cd ..
    radius = 5;

    % Store variables that will be overwritten
    RDF_c = RDF;
    Mask_c = Mask;
    Mask_SMV = MaskErode(Mask,matrix_size,voxel_size,radius);


    % Preprocess local field with VSHARP with optimized parameters
    [RDF,Mask] = BKGRemovalVSHARP(RDF_c,Mask,matrix_size);
    Mask_VSHARP = Mask;
    vsharp_filename = strcat(file_name,'_vsharp.mat');
    save(strcat('vsharp\',vsharp_filename),'RDF','matrix_size','voxel_size','Mask','B0_dir','CF','delta_TE','iFreq','iFreq_raw','iMag','Mask_CSF','N_std')
   
    % Preprocess local field with mSMV
    msmv_filename = strcat('msmv/','RDF_',string(j),'_msmv_kl.mat');
    msmv(file_name,msmv_filename)



    %%

    % Preprocess local field with SMV
    Mask = Mask_SMV;
    RDF = Mask_SMV.*(RDF_c-SMV(RDF_c,matrix_size,voxel_size,radius));
    smv_filename = strcat(file_name,'_smv.mat');
    save(strcat('smv\',smv_filename),'RDF','matrix_size','voxel_size','Mask','B0_dir','CF','delta_TE','iFreq','iFreq_raw','iMag','Mask_CSF','N_std')
    
    % Reconstruct using MEDI-L1 with the appropriate dipole kernel for each
    % method
    reg_lam = 1000;
    reg_csf = 1000;
    Masks = {Mask_c Mask_SMV Mask_c Mask_c Mask_LBV Mask_VSHARP};
    QSM_VSHARP = MEDI_L1('filename',vsharp_filename,'lambda',reg_lam,'lambda_CSF',reg_csf,'dipole_filter',1);
    QSM_msmv =  MEDI_L1('filename',msmv_filename,'lambda',reg_lam,'lambda_CSF',reg_csf,'dipole_filter',1);
    QSM_smv =  MEDI_L1('filename',smv_filename,'lambda',reg_lam,'lambda_CSF',reg_csf,'dipole_filter',1);
    QSM_ctrl =  MEDI_L1('filename',file_name,'lambda',reg_lam,'lambda_CSF',reg_csf,'dipole_filter',0);
    QSMs = {QSM_ctrl QSM_smv QSM_msmv QSM_dmsmv QSM_LBV QSM_VSHARP};
    cd 'qsms'
    if save_data == 1
        save(strcat(file_name(1:end-4),'wstf_qsms_dmsmv.mat'),'QSMs','Masks','matrix_size','voxel_size')
    end
    
end

%%
peel = 5;
for j = 1:10
    if j < 10
        load(strcat('00',num2str(j),'_RDF_wcsf_R2Swstf_qsms_dmsmv'),'Masks','QSMs','voxel_size','matrix_size');
    else
        load(strcat('0',num2str(j),'_RDF_wcsf_R2Swstf_qsms_dmsmv'),'Masks','QSMs','voxel_size','matrix_size');
    end
    for k = 1:length(QSMs)
        QSMs_ax{k,j} = permute(QSMs{k},[2 1 3 4]);
        Masks_ax{k,j} = permute(Masks{k},[2 1 3 4]);
        QSMs_cor{k,j} = cor_view(QSMs_ax{k,j},Masks_ax{k,j},voxel_size);
        QSMs_sag{k,j}= sag_view(QSMs_ax{k,j},Masks_ax{k,j},voxel_size);
    end
end
cd ..
cd ..
cd ..
%%

names = {'control','smv','msmv','dmsmv','lbv','vsharp'};
hs = 9;
for k = 1:min(size(QSMs_ax))
    make_figures(QSMs_ax{k,hs},Masks_ax{k,hs},voxel_size,strcat('figures\healthy_subjects\tifs'),...
        28,213,222,[384 384],strcat(names{k},string(hs),'.png'),30)
    cd ..
    cd ..
    cd ..
end

%%
QSMs_arr = [];
k = 1;
ss_c = zeros(1,10);
ss_msmv = ss_c;
ss_lbv = ss_c;
ss_vsharp = ss_c;
figure;
while k < 11
    if k < 10
        file_name = strcat('00',num2str(k),'_RDF_wcsf_R2S','.mat');
        seg = load_untouch_nii(char(strcat('00',string(k),'_iMag_seg.nii')));
        load(strcat(file_name(1:end-4),'wstf_qsms_dmsmv.mat'),'Masks','QSMs','voxel_size','matrix_size');
    else
        file_name = strcat('0',num2str(k),'_RDF_wcsf_R2S','.mat');
        seg = load_untouch_nii(char(strcat('0',string(k),'_iMag_seg.nii')));
        load(strcat(file_name(1:end-4),'wstf_qsms_dmsmv.mat'),'Masks','QSMs','voxel_size','matrix_size');
    end
    seg = seg.img;
    gmm = seg == 1;
    wmm = seg == 2;
   
    % Use same mask for all brain volumes since it affects gray matter
    gmm_Mask = Masks{6}>0;
    ss_c(k) = var(Masks{6}(gmm_Mask).*QSMs{1}(gmm_Mask).*gmm(gmm_Mask))*1000;
    ss_smv(k) = var(Masks{6}(gmm_Mask).*QSMs{2}(gmm_Mask).*gmm(gmm_Mask))*1000;
    ss_msmv(k) = var(Masks{6}(gmm_Mask).*QSMs{3}(gmm_Mask).*gmm(gmm_Mask))*1000;
    ss_vsharp(k) = var(Masks{6}(gmm_Mask).*QSMs{6}(gmm_Mask).*gmm(gmm_Mask))*1000;   

    QSMs_arr = [QSMs_arr; QSMs];
    k = k+1;
end

    % Test significance with Bonferroni correction
    alpha = 0.00001;
    N = 6;
    alpha = alpha/6;
    [h,p] = ttest(ss_c,ss_msmv,"Alpha",alpha)
    [h,p] = ttest(ss_smv,ss_msmv,"Alpha",alpha)
    [h,p] = ttest(ss_lbv,ss_msmv,"Alpha",alpha)
    [h,p] = ttest(ss_vsharp,ss_msmv,"Alpha",alpha)

    
    method = categorical({'PDF','SMV','VSHARP','mSMV'});
    method = reordercats(categorical({'PDF','VSHARP','SMV','mSMV'}));

    boxplot([ss_c(:),ss_lbv(:),ss_vsharp(:),ss_smv(:),ss_msmv(:)],method,'grouporder',{'PDF','VSHARP','SMV','mSMV'})
    sigstar({[1,5]},[0.005],0)
    sigstar({[2,5]},[0.005],0)

    xlabel('Algorithm')
    ylabel('\sigma^2_{cortical gray matter}')
    title('Shadow reduction in healthy subjects')