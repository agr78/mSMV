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

% Use local field for fair comparison to mSMV
load('data\simulation\RDF_sim.mat')
RDF_c = RDF;
Mask_c = Mask;
% Set parameter range to encompass that used by Özbay et. al
delta = 0:0.01:0.25;

% Use a recommended radius of 5 mm (Li et. al) for SMV
radius = 5; 
Mask_SMV = MaskErode(Mask,matrix_size,voxel_size,radius);

% Parameter optimization for SHARP and RESHARP
for j = 1:length(delta)
    [RDF_SHARPs{j},Mask_SHARPs{j}] = SHARP(RDF_c,Mask, matrix_size,voxel_size,radius,delta(j)); 
    [RDF_RESHARPs{j},Mask_RESHARPs{j}] = RESHARP(RDF_c,Mask, matrix_size,voxel_size,radius,delta(j));
    [fitres_SHARP{j},gof_SHARP{j}] = createFit(RDF_t(:),Mask_SHARPs{j}(:).*RDF_SHARPs{j}(:)); gof_SHARP{j} = gof_SHARP{j}.rsquare;
    [fitres_RESHARP{j},gof_RESHARP{j}]  = createFit(RDF_t(:),Mask_RESHARPs{j}(:).*RDF_RESHARPs{j}(:)); gof_RESHARP{j} = gof_RESHARP{j}.rsquare;
end

% Output optimal parameters
[maxval_SHARP,idxmax_SHARP] = max(cell2mat(gof_SHARP));
[maxval_RESHARP,idxmax_RESHARP] = max(cell2mat(gof_RESHARP));
disp('Optimal alpha for SHARP is')
delta(idxmax_SHARP)
alpha_SHARP = delta(idxmax_SHARP);
disp('Optimal alpha for RESHARP is')
delta(idxmax_RESHARP)
alpha_RESHARP = delta(idxmax_RESHARP);

% Optimize LBV peel (radius in voxels)
disp('Optimizing LBV and VSHARP')
cd data/simulation
for j = 1:12
    if j < 5
        tol = 0.01; 
        depth = -1; 
        N1 = 30; 
        N2 = 100; 
        N3 = 100; 
        peel = j;
        RDF_LBVs{j} = LBV(RDF_c,Mask,matrix_size,voxel_size,tol,depth,peel,N1,N2,N3);
        fid = fopen(strcat('mask_p',string(j),'.bin'),'r');
        Mask_LBV{j} = reshape(fread(fid,matrix_size(1)*matrix_size(2)*matrix_size(3),'int'),matrix_size);
        mse_LBV{j} = mse(RDF_t(:),Mask_LBV{j}(:).*RDF_LBVs{j}(:));
    end
    
    if j > 1
        [RDF_VSHARP_opt,Mask_opt] = V_SHARP(iFreq,Mask,'voxelsize',voxel_size(:)','smvsize',j);
        RDF_VSHARPs{j} = RDF_VSHARP_opt;
        Mask_VSHARP{j} = Mask_opt;
        mse_VSHARP{j} = mse(RDF_t(:),Mask_VSHARP{j}(:).*RDF_VSHARPs{j}(:));
    else
        mse_VSHARP{j} = Inf;
    end
end

[minval_LBV,idxmin_LBV] = min(cell2mat(mse_LBV));
disp('Optimal LBV peel is')
idxmin_LBV
peel = idxmin_LBV;

[minval_VSHARP,idxmin_VSHARP] = min(cell2mat(mse_VSHARP));
disp('Optimal VSHARP kernel is')
idxmin_VSHARP
VSHARP_radius = idxmin_VSHARP;

save('optimal_params','alpha_SHARP','alpha_RESHARP','peel','VSHARP_radius')

cd ..
cd ..

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
Masks = {Mask_c Mask_c Mask_c Mask_SMV Mask_SHARPs{idxmax_SHARP} Mask_RESHARPs{idxmax_RESHARP} Mask_VSHARP Mask_LBV{idxmin_LBV} Mask_iSMV Mask_c};
for j = 1:length(QSM_figs)
    ax1 = 33;
    ax2 = 49;
    cor = 94;
    sag = 138;
    names = {'gt','ctrl','dmsmv','smv','sharp','resharp','vsharp','lbv','ismv','msmv'};
    make_figures(QSM_figs{j},Masks{j},voxel_size','figures\simulation\tifs',ax1,sag,cor,[matrix_size(1) matrix_size(2)],names{j},30)
    cd ..
    cd ..
    cd ..
end



