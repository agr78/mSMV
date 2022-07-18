%% Prepare RDFs for healthy subjects
save_data = 1;
cd data/simulation
load('optimal_params.mat')
cd ..
cd 'healthy_subjects/control'
for j = 1:10
    file_name = strcat('romeo_RDF_anon_',num2str(j));
    load(file_name)
    cd ..
    radius = 5;
    % Store variables that will be overwritten
    RDF_c = RDF;
    Mask_c = Mask;
    Mask_SMV = MaskErode(Mask,matrix_size,voxel_size,radius);
    % Preprocess local field with LBV with optimized parameters
    tol = 0.01; 
    depth = -1; 
    N1 = 30; 
    N2 = 100; 
    N3 = 100; 
    peel = 5;
    RDF = LBV(RDF_c,Mask,matrix_size,voxel_size,tol,depth,peel,N1,N2,N3);
    fid = fopen('mask_p5.bin','r');
    Mask_LBV = reshape(fread(fid,matrix_size(1)*matrix_size(2)*matrix_size(3),'int'),matrix_size);
    Mask = Mask_LBV;
    RDF = RDF.*Mask_LBV;
    
    lbv_filename = strcat(file_name,'_lbv.mat');
    save(strcat('lbv\',lbv_filename),'RDF','matrix_size','voxel_size','Mask','B0_dir','CF','delta_TE','iFreq','iFreq_raw','iMag','Mask_CSF','N_std')
    

    % Preprocess local field with VSHARP with optimized parameters
    [RDF,Mask] = BKGRemovalVSHARP(RDF_c,Mask,matrix_size);
    Mask_VSHARP = Mask;
    vsharp_filename = strcat(file_name,'_vsharp.mat');
    save(strcat('vsharp\',vsharp_filename),'RDF','matrix_size','voxel_size','Mask','B0_dir','CF','delta_TE','iFreq','iFreq_raw','iMag','Mask_CSF','N_std')
   
    % Preprocess local field with mSMV
    msmv_filename = strcat('msmv/',file_name,'_msmv.mat');
    msmv(file_name,msmv_filename)

    % Preprocess local field with mSMV
    mpdf_filename = strcat('mpdf/',file_name,'_mpdf.mat');
    mpdf(file_name,mpdf_filename)
    
    % Reconstruct using MEDI-L1 with the appropriate dipole kernel for each
    % method
    reg_lam = 1000;
    Masks = {Mask_c Mask_c Mask_SMV Mask_c Mask_LBV Mask_VSHARP};
    QSM_VSHARP = MEDI_L1_filt_dipole('filename',vsharp_filename,'lambda',reg_lam);
    QSM_LBV = MEDI_L1_orig_dipole('filename',lbv_filename,'lambda',reg_lam);
    QSM_msmv =  MEDI_L1_filt_dipole('filename',msmv_filename,'lambda',reg_lam);
    QSM_smv =  MEDI_L1('filename',file_name,'lambda',reg_lam);
    QSM_ctrl =  MEDI_L1_orig_dipole('filename',file_name,'lambda',reg_lam);
    QSM_mpdf =  MEDI_L1_orig_dipole('filename',mpdf_filename,'lambda',reg_lam);
    QSMs = {QSM_ctrl QSM_mpdf QSM_smv QSM_msmv QSM_LBV QSM_VSHARP};
    cd 'qsms'
    if save_data == 1
        save(strcat(file_name,'QSMs'),'QSMs','Masks','matrix_size','voxel_size')
    end
    
end

%%
peel = 5;
for j = 1:10

    if j < 10
        load(strcat('00',num2str(j),'romeo_RDFQSMs_anon.mat'),'QSMs','Masks','voxel_size','matrix_size');
        for k = 1:length(QSMs)
             QSMs_ax{k,j} = permute(QSMs{k},[2 1 3 4]);
             Masks_ax{k,j} = permute(Masks{k},[2 1 3 4]);
             QSMs_cor{k,j} = cor_view(QSMs_ax{k,j},Masks_ax{k,j},voxel_size);
             QSMs_sag{k,j}= sag_view(QSMs_ax{k,j},Masks_ax{k,j},voxel_size);
        end
    else
        load(strcat('0',num2str(j),'romeo_RDFQSMs_anon.mat'),'QSMs','Masks','voxel_size','matrix_size');
        for k = 1:length(QSMs)
            QSMs_ax{k,j} = permute(QSMs{k},[2 1 3 4]);
            Masks_ax{k,j} = permute(Masks{k},[2 1 3 4]);
            QSMs_cor{k,j} = cor_view(QSMs_ax{k,j},Masks_ax{k,j},voxel_size);
            QSMs_sag{k,j}= sag_view(QSMs_ax{k,j},Masks_ax{k,j},voxel_size);
        end
    end
end
ax = 35;
cor = 190;
sag = 215;
ax_fig = cell2mat(QSMs_ax);
cor_fig = cell2mat(QSMs_cor);
sag_fig = cell2mat(QSMs_sag);
imwrite(uint8(255*apply_wl(ax_fig(:,:,ax),0.5,0)),strcat('figures\healthy_subjects\hs_ax',string(ax),'.png'))
imwrite(uint8(255*apply_wl(cor_fig(:,:,cor),0.5,0)),strcat('figures\healthy_subjects\hs_cor',string(cor),'.png'))
imwrite(uint8(255*apply_wl(sag_fig(:,:,sag),0.5,0)),strcat('figures\healthy_subjects\hs_sag',string(sag),'.png'))
%%
names = {'control','mpdf','smv','msmv','lbv','vsharp'};
hs = 10;
for k = 1:min(size(QSMs_ax))
    make_figures(QSMs_ax{k,hs},Masks_ax{k,hs},voxel_size,strcat('figures\healthy_subjects\'),23,215,210,[384 384],strcat(names{k},string(hs),'.png'))
    cd ..
    cd ..
end

%%
QSMs_arr = [];
k = 0;
ss_c = zeros(1,10);
ss_msmv = ss_c;
ss_lbv = ss_c;
ss_vsharp = ss_c;
figure;
while k < 10
    k = k+1;
    if k < 10
        seg = load_untouch_nii(char(strcat('00',string(k),'_iMag_seg.nii')));
        load(strcat('romeo_RDF_anon_',string(k),'QSMs'),'Masks','QSMs','voxel_size','matrix_size');
    else
        seg = load_untouch_nii(char(strcat('0',string(k),'_iMag_seg.nii')));
        load(strcat('romeo_RDF_anon_',string(k),'QSMs'),'Masks','QSMs','voxel_size','matrix_size');
    end
    seg = seg.img;
    gmm = seg == 1;
    wmm = seg == 2;
   
    % Use same mask for all brain volumes since it affects gray matter
    % variance
    ss_c(k) = var(Masks{2}(:).*QSMs{1}(:).*gmm(:))*1000;
    ss_mpdf(k) = var(Masks{2}(:).*QSMs{2}(:).*gmm(:))*1000;
    ss_smv(k) = var(Masks{2}(:).*QSMs{3}(:).*gmm(:))*1000;
    ss_msmv(k) = var(Masks{2}(:).*QSMs{4}(:).*gmm(:))*1000;
    ss_lbv(k) = var(Masks{2}(:).*QSMs{5}(:).*gmm(:))*1000;
    ss_vsharp(k) = var(Masks{2}(:).*QSMs{6}(:).*gmm(:))*1000;   

    QSMs_arr = [QSMs_arr; QSMs];
end
vis([imrotate(cell2mat(QSMs_arr),-90)],'WindowLevel',[0.5 0])
    % Test significance with Bonferroni correction
    alpha = 0.005/4; 
    [h,p] = ttest(ss_c,ss_msmv,"Alpha",alpha)
    [h,p] = ttest(ss_mpdf,ss_msmv,"Alpha",alpha)
    [h,p] = ttest(ss_smv,ss_msmv,"Alpha",alpha)
    [h,p] = ttest(ss_lbv,ss_msmv,"Alpha",alpha)
    [h,p] = ttest(ss_vsharp,ss_msmv,"Alpha",alpha)

    
    method = categorical({'PDF','mPDF','SMV','LBV','VSHARP','mSMV'});
    method = reordercats(categorical({'PDF','mPDF','VSHARP','LBV','SMV','mSMV'}));

    boxplot([ss_c(:),ss_mpdf(:),ss_vsharp(:),ss_lbv(:),ss_smv(:),ss_msmv(:)],method,'grouporder',{'PDF','mPDF','VSHARP','LBV','SMV','mSMV'})
    sigstar({[1,6]},[0.005],0)
    sigstar({[2,6]},[0.005],0)
    sigstar({[3,6]},[0.005],0)
    sigstar({[4,6]},[0.005],0)

    xlabel('Algorithm')
    ylabel('\sigma^2_{gray matter}')
    title('Shadow reduction via gray matter variance')