%% Prepare RDFs for healthy subjects
save_data = 1;
cd data/simulation
load('optimal_params.mat')
cd ..
cd 'healthy_subjects/control'
for j = 1:10
    if j < 10
        file_name = strcat('00',num2str(j),'input_RDF','.mat');
    else 
        file_name = strcat('0',num2str(j),'input_RDF','.mat');
    end     
    load(file_name)
    cd ..
    radius = 5;

    % Store variables that will be overwritten
    RDF_c = RDF;
    Mask_c = Mask;
    Mask_SMV = MaskErode(Mask,matrix_size,voxel_size,radius);


    % Preprocess local field with VSHARP with optimized parameters
    [RDF,Mask_VSHARP] = V_SHARP(iFreq,Mask,'voxelsize',voxel_size(:)','smvsize',5);
    Mask = Mask_VSHARP;
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
    Masks = {Mask_c Mask_SMV Mask_c Mask_VSHARP};
    QSM_VSHARP = MEDI_L1('filename',vsharp_filename,'lambda',reg_lam,'lambda_CSF',reg_csf,'dipole_filter',1,'smv',radius);
    QSM_msmv =  MEDI_L1('filename',msmv_filename,'lambda',reg_lam,'lambda_CSF',reg_csf,'dipole_filter',1,'smv',radius);
    QSM_smv =  MEDI_L1('filename',smv_filename,'lambda',reg_lam,'lambda_CSF',reg_csf,'dipole_filter',1,'smv',radius);
    QSM_ctrl =  MEDI_L1('filename',file_name,'lambda',reg_lam,'lambda_CSF',reg_csf,'dipole_filter',0);
    QSMs = {QSM_ctrl QSM_smv QSM_msmv QSM_VSHARP};
    cd 'qsms'
    if save_data == 1
        save(strcat(file_name(1:end-4),'qsms_msmv_cor_r2s.mat'),'QSMs','Masks','matrix_size','voxel_size')
    end
    
end

%%
peel = 5;
for j = 1:10
    if j < 10
        load(strcat('00',num2str(j),'input_RDFqsms_msmv_cor_r2s.mat'),'Masks','QSMs','voxel_size','matrix_size');
    else
        load(strcat('0',num2str(j),'input_RDFqsms_msmv_cor_r2s.mat'),'Masks','QSMs','voxel_size','matrix_size');
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

names = {'control','smv','msmv','vsharp'};
hs = 8;
for k = 1:min(size(QSMs_ax))
    make_figures(QSMs_ax{k,hs},Masks_ax{k,hs},voxel_size,strcat('figures\healthy_subjects\tifs'),...
        24,208,165,[384 384],strcat(names{k},string(hs)),30)
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
        file_name = strcat('00',num2str(k),'input_RDF','.mat');
        seg = load_untouch_nii(char(strcat('00',string(k),'_iMag_seg.nii')));
        load(strcat(file_name(1:end-4),'qsms_msmv_cor_r2s.mat'),'Masks','QSMs','voxel_size','matrix_size');
    else
        file_name = strcat('0',num2str(k),'input_RDF','.mat');
        seg = load_untouch_nii(char(strcat('0',string(k),'_iMag_seg.nii')));
        load(strcat(file_name(1:end-4),'qsms_msmv_cor_r2s.mat'),'Masks','QSMs','voxel_size','matrix_size');
    end
    seg = seg.img;
    gmm = seg == 1;
    wmm = seg == 2;
   
    % Use same mask for all brain volumes since it affects gray matter
    gmm_Mask = Masks{4}>0;
    ss_c(k) = var(Masks{4}(gmm_Mask).*QSMs{1}(gmm_Mask).*gmm(gmm_Mask))*1000;
    ss_msmv(k) = var(Masks{4}(gmm_Mask).*QSMs{3}(gmm_Mask).*gmm(gmm_Mask))*1000;
    ss_vsharp(k) = var(Masks{4}(gmm_Mask).*QSMs{4}(gmm_Mask).*gmm(gmm_Mask))*1000;   

    QSMs_arr = [QSMs_arr; QSMs];
    k = k+1;
end

    % Test significance with Bonferroni correction
    alpha = 0.001;
    N = 3;
    alpha = alpha/N;
    [h,p] = ttest(ss_c,ss_msmv,"Alpha",alpha)
    [h,p] = ttest(ss_vsharp,ss_msmv,"Alpha",alpha)

    
    method = categorical({'PDF','VSHARP','mSMV'});
    method = reordercats(categorical({'PDF','VSHARP','mSMV'}));

    boxplot([ss_c(:),ss_vsharp(:),ss_msmv(:)],method,'grouporder',{'PDF','VSHARP','mSMV'})
    sigstar({[1,3]},[0.001],0)
    sigstar({[1,2]},[0.001],0)

    xlabel('Algorithm','FontSize',14,'Interpreter','latex')
    ylabel('$\sigma^2_{\mathrm{cortical \ gray \ matter}}$','FontSize',20,'Interpreter','latex')
    title('Shadow reduction in healthy subjects','Interpreter','latex','FontSize',20)