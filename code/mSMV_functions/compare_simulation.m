% Compare simulation
%
% Compares mSMV to other shadow reduction methods. Optimizes methods with
% tunable parameters (SHARP,RESHARP,LBV).                   
%
% Alexandra G. Roberts
% MRI Lab
% Cornell University
% 03/31/2022

clear
clc

save_opt = 1;

% Load true RDF for parameter optimization
set(groot,'defaultFigureVisible','off')
RDF_t = load('data\simulation\RDF_sim_gt.mat').RDF;
load('data\simulation\RDF_sim_50.mat')
RDF_c = RDF;
Mask_c = Mask;
numecho = 11;
TE = [1:numecho]*delta_TE;


% Use a recommended radius of 5 mm (Li et. al) for SMV
radius = 5; 
Mask_SMV = MaskErode(Mask,matrix_size,voxel_size,radius);


%%
% Optimize VSHARP
for j = 1:12    
    if j > radius-1
        [RDF_VSHARP_opt,Mask_opt] = V_SHARP(iFreq,Mask,'voxelsize',voxel_size(:)','smvsize',j);
        RDF_VSHARPs{j} = RDF_VSHARP_opt.*Mask_opt;
        Mask_VSHARP{j} = Mask_opt;
        mse_VSHARP{j} = mse(RDF_t(:),Mask_VSHARP{j}(:).*RDF_VSHARPs{j}(:));
    else
        mse_VSHARP{j} = Inf;
    end
end


[minval_VSHARP,idxmin_VSHARP] = min(cell2mat(mse_VSHARP));
disp('Optimal VSHARP kernel is')
idxmin_VSHARP
VSHARP_radius = idxmin_VSHARP;

save('data\simulation\optimal_params','VSHARP_radius')
set(groot,'defaultFigureVisible','on')

% Process and save local fields
[RDF_VSHARP,Mask_VSHARP] = V_SHARP(iFreq,Mask,'voxelsize',voxel_size(:)','smvsize',VSHARP_radius);
RDF = RDF_VSHARP.*Mask_VSHARP;
Mask = Mask_VSHARP;
save ('data\simulation\RDF_sim_VSHARP_50.mat','RDF','matrix_size','voxel_size','Mask','B0_dir','CF','delta_TE','iFreq','iFreq_raw','iMag','Mask_CSF','N_std')
msmv('data\simulation\RDF_sim_50.mat','data\simulation\RDF_sim_msmv_50.mat')
msmv('data\simulation\RDF_sim_VSHARP_50.mat','data\simulation\RDF_sim_VSHARP_msmv_50.mat','no_prefilter')
Mask = Mask_SMV;
RDF = Mask_SMV.*(RDF_c-SMV(RDF_c,matrix_size,voxel_size,radius));
save('data\simulation\RDF_sim_smv_50.mat','RDF','matrix_size','voxel_size','Mask','B0_dir','CF','delta_TE','iFreq','iFreq_raw','iMag','Mask_CSF','N_std')

% QSM reconstruction
disp('Reconstructing QSM from local fields')
reg_lam = 100;
QSM_sim_VSHARP = MEDI_L1('filename','RDF_sim_VSHARP_50.mat','lambda',reg_lam,'dipole_filter',1);
QSM_sim_VSHARP_msmv =  MEDI_L1('filename','RDF_sim_VSHARP_msmv_50.mat','lambda',reg_lam,'dipole_filter',1);
QSM_sim_msmv =  MEDI_L1('filename','RDF_sim_msmv_50.mat','lambda',reg_lam,'dipole_filter',1);
QSM_sim_smv =  MEDI_L1('filename','RDF_sim_smv_50.mat','lambda',reg_lam,'dipole_filter',1);
QSM_ctrl =  MEDI_L1('filename','RDF_sim_50.mat','lambda',reg_lam,'dipole_filter',0);

%% Compare reconstructions
true_QSM = load('data\simulation\RDF_sim_gt.mat').true_QSM;
roi_mask = load('sim_roi_mask.mat').roi_mask;
QSMs = {Mask_c.*QSM_ctrl 
        Mask_SMV.*QSM_sim_smv 
        Mask_VSHARP.*QSM_sim_VSHARP 
        Mask_VSHARP.*QSM_sim_VSHARP_msmv 
        Mask_c.*QSM_sim_msmv};
Masks = {Mask_c Mask_c Mask_SMV Mask_VSHARP Mask_VSHARP Mask_c};
QSM_ROI_stats(true_QSM,QSMs,roi_mask,matrix_size,voxel_size)

% Save
if save_opt == 1;
    cd data/simulation/
    save recon_comp_ws_all_50 QSMs true_QSM Masks
end
cd ..
cd ..
%%
QSM_figs = {true_QSM QSMs{:}};
Masks = {Mask_c Mask_c Mask_SMV Mask_VSHARP Mask_VSHARP Mask_c};
for j = 1:length(QSM_figs)
    ax2 = 34;
    cor = 128;
    sag = 100;
    names = {'gt','ctrl','smv','vsharp','vsharp_msmv','msmv'};
    auto_crop_figures(QSM_figs{j},Masks{j},voxel_size','figures\simulation\tifs',ax2,sag,cor,[matrix_size(1) matrix_size(2)],names{j})
    cd ..
    cd ..
    cd ..
end

%% Shadow score
load('recon_comp_ws_all_50.mat')
QSM_msmv = QSMs{5};
QSM_vsharp_msmv = QSMs{4};
QSM_vsharp = QSMs{3};
QSM_smv = QSMs{2};
QSM_pdf = QSMs{1};

gray_mask = Mask_SMV.*load('data\simulation\RDF_sim_gt.mat').gray_mask;
var(QSM_msmv(gray_mask(:)>0))
var(QSM_vsharp(gray_mask(:)>0))
var(QSM_vsharp_msmv(gray_mask(:)>0))
var(QSM_pdf(gray_mask(:)>0))

