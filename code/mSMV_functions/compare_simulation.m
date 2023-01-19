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
load('data\simulation\RDF_sim.mat');
load('data\simulation\RDF_sim_field.mat','iField')
RDF_c = RDF;
Mask_c = Mask;
numecho = 11;
TE = [1:numecho]*delta_TE;
% Set parameter range to encompass that used by Özbay et. al
delta = 0:0.01:0.25;

% Use a recommended radius of 5 mm (Li et. al) for SMV
radius = 5; 
Mask_SMV = MaskErode(Mask,matrix_size,voxel_size,radius);

% Optimize iRSHARP
params.sizeVol = matrix_size;
params.voxSize = voxel_size;

delta = 0.05:0.05:0.25;
C = 0.25:0.5:10;
iRparams.rMIN = 1;
for i = 1:length(C)
    for j = 1:2*radius
        for k = 1:length(delta)
            if j > 1
                disp(strcat('Optimizing iRSHARP with constant', {' '}, string(C(i)),{' '},'radius',{' '}, string(j), {' '}, 'and threshold', {' '}, string(delta(k))))
                iRparams.C = C(i);
                iRparams.rMAX = j;
                iRparams.TSVD = delta(k);
                [RDF_iRSHARP_opt, bg] = iRSHARP(iFreq_raw,iFreq,Mask,params,iRparams);
                mse_iRSHARP(i,j,k) = mse(RDF_t(:),RDF_iRSHARP_opt(:));
            else
                mse_iRSHARP(i,j,k) = single(Inf);
            end
        end
    end
end
[minval_iRSHARP,idxmin_iRSHARP] = min(min(min((mse_iRSHARP))))
[i_opt,j_opt,k_opt] = ind2sub(size(mse_iRSHARP),idx(1));
disp('Optimal iRSHARP kernel is')
C(i_opt)
radius(j_opt)
delta(k_opt)

iRparams_opt.rMIN = iRparams.rMIN;
iRparams_opt.C = C(i_opt);
iRparams_opt.rMAX = radius(j_opt);
iRparams_opt.TSVD = delta(k_opt);
[RDF_iRSHARP, bg] = iRSHARP(iFreq_raw,iFreq,Mask,params,iRparams_opt);
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
save ('data\simulation\RDF_sim_VSHARP.mat','RDF','matrix_size','voxel_size','Mask','B0_dir','CF','delta_TE','iFreq','iFreq_raw','iMag','Mask_CSF','N_std')
msmv('data\simulation\RDF_sim.mat','data\simulation\RDF_sim_msmv.mat')
Mask = Mask_SMV;
RDF = Mask_SMV.*(RDF_c-SMV(RDF_c,matrix_size,voxel_size,radius));
save('data\simulation\RDF_sim_smv.mat','RDF','matrix_size','voxel_size','Mask','B0_dir','CF','delta_TE','iFreq','iFreq_raw','iMag','Mask_CSF','N_std')


% QSM reconstruction
disp('Reconstructing QSM from local fields')
reg_lam = 100;
QSM_sim_VSHARP = MEDI_L1('filename','RDF_sim_VSHARP.mat','lambda',reg_lam,'dipole_filter',1);
QSM_sim_msmv =  MEDI_L1('filename','RDF_sim_msmv.mat','lambda',reg_lam,'dipole_filter',1);
QSM_sim_smv =  MEDI_L1('filename','RDF_sim_smv.mat','lambda',reg_lam,'dipole_filter',1);
QSM_ctrl =  MEDI_L1('filename','RDF_sim.mat','lambda',reg_lam,'dipole_filter',0);

%% Compare reconstructions
true_QSM = load('data\simulation\RDF_sim_gt.mat').true_QSM;
gray_mask = Mask_SMV.*load('data\simulation\RDF_sim_gt.mat').gray_mask;
roi_mask = load('sim_roi_mask.mat').roi_mask;
QSMs = {Mask_c.*QSM_ctrl 
        Mask_SMV.*QSM_sim_smv 
        Mask_VSHARP.*QSM_sim_VSHARP 
        Mask_c.*QSM_sim_msmv};
Masks = {Mask_c Mask_SMV Mask_VSHARP Mask_c};
QSM_stats(true_QSM,QSMs,Masks,gray_mask,roi_mask,matrix_size,voxel_size)

% Save
if save_opt == 1;
    cd data/simulation/
    save recon_comp_ws QSMs true_QSM
end
cd ..
cd ..
%%
QSM_figs = {true_QSM QSMs{:}};
Masks = {Mask_c Mask_c Mask_SMV Mask_VSHARP Mask_c};
for j = 1:length(QSM_figs)
    ax1 = 33;
    ax2 = 49;
    cor = 94;
    sag = 138;
    names = {'gt','ctrl','smv','vsharp','msmv'};
    make_figures(QSM_figs{j},Masks{j},voxel_size','figures\simulation\tifs',ax1,sag,cor,[matrix_size(1) matrix_size(2)],names{j},30)
    cd ..
    cd ..
    cd ..
end



