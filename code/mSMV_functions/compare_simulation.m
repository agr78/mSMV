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
RDF_t = load('data\simulation\RDF_sim_gt.mat').RDF;

% Use local field for fair comparison to mSMV
load('data\simulation\RDF_sim.mat')
RDF_c = RDF;
Mask_c = Mask;
% Set parameter range to encompass that used by Özbay et. al
delta = 0:0.01:0.25;

% Use a recommended radius of 5 mm (Li et. al) for distance-based erosion methods 
% SMV,SHARP,RESHARP,VSHARP 
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
alpha_SHARP = delta(idxmax_SHARP);
disp('Optimal alpha for RESHARP is')
delta(idxmax_RESHARP)
alpha_RESHARP = delta(idxmax_RESHARP);

% Optimize LBV peel (radius in voxels)
disp('Optimizing LBV')
cd data/simulation
for j = 1:5
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
[minval_LBV,idxmin_LBV] = min(cell2mat(mse_LBV));
disp('Optimal LBV peel is')
idxmin_LBV

peel = idxmin_LBV;

save('optimal_params','alpha_SHARP','alpha_RESHARP','peel')

cd ..
cd ..

% Process local fields
RDF_SHARP = Mask_SHARPs{idxmax_SHARP}.*RDF_SHARPs{idxmax_SHARP};
RDF_RESHARP = Mask_RESHARPs{idxmax_RESHARP}.*RDF_RESHARPs{idxmax_RESHARP};
[RDF_VSHARP,Mask_VSHARP] = BKGRemovalVSHARP(RDF_c,Mask_c,matrix_size);
[RDF_iSMV,Mask_iSMV] = iSMV(RDF_c,Mask_c,matrix_size,voxel_size,radius);
RDF_LBV = Mask_LBV{idxmin_LBV}.*RDF_LBVs{idxmin_LBV};

% Save local fields
RDF = RDF_SHARP;
Mask = Mask_SHARPs{idxmax_SHARP};
save ('data\simulation\RDF_sim_SHARP.mat','RDF','matrix_size','voxel_size','Mask','B0_dir','CF','delta_TE','iFreq','iFreq_raw','iMag','Mask_CSF','N_std')
RDF = RDF_RESHARP;
Mask = Mask_RESHARPs{idxmax_RESHARP};
save('data\simulation\RDF_sim_RESHARP.mat','RDF','matrix_size','voxel_size','Mask','B0_dir','CF','delta_TE','iFreq','iFreq_raw','iMag','Mask_CSF','N_std')
RDF = RDF_VSHARP.*Mask_VSHARP;
save ('data\simulation\RDF_sim_VSHARP.mat','RDF','matrix_size','voxel_size','Mask','B0_dir','CF','delta_TE','iFreq','iFreq_raw','iMag','Mask_CSF','N_std')
RDF = RDF_iSMV;
Mask = Mask_iSMV;
save ('data\simulation\RDF_sim_iSMV.mat','RDF','matrix_size','voxel_size','Mask','B0_dir','CF','delta_TE','iFreq','iFreq_raw','iMag','Mask_CSF','N_std')
RDF = RDF_LBV;
Mask = Mask_LBV{idxmin_LBV};
save('data\simulation\RDF_sim_LBV.mat','RDF','matrix_size','voxel_size','Mask','B0_dir','CF','delta_TE','iFreq','iFreq_raw','iMag','Mask_CSF','N_std')
Mask_Nstd = Mask-imbinarize(N_std.*Mask,prctile(N_std(:).*Mask(:),90)).*(Mask-MaskErode(Mask,matrix_size,voxel_size,radius));
RDF = RDF_c;
Mask = Mask_Nstd;
save('data\simulation\RDF_sim_nstd.mat','RDF','matrix_size','voxel_size','Mask','B0_dir','CF','delta_TE','iFreq','iFreq_raw','iMag','Mask_CSF','N_std')
msmv('data\simulation\RDF_sim.mat','data\simulation\RDF_sim_msmv.mat')

% QSM reconstruction
disp('Reconstructing QSM from local fields')
reg_lam = 100;
QSM_sim_SHARP = MEDI_L1_orig_dipole('filename','RDF_sim_SHARP.mat','lambda',reg_lam);
QSM_sim_RESHARP = MEDI_L1_orig_dipole('filename','RDF_sim_RESHARP.mat','lambda',reg_lam);
QSM_sim_VSHARP = MEDI_L1_filt_dipole('filename','RDF_sim_VSHARP.mat','lambda',reg_lam);
QSM_sim_iSMV = MEDI_L1_filt_dipole('filename','RDF_sim_iSMV.mat','lambda',reg_lam);
QSM_sim_LBV = MEDI_L1_orig_dipole('filename','RDF_sim_LBV.mat','lambda',reg_lam);
QSM_sim_msmv =  MEDI_L1_filt_dipole('filename','RDF_sim_msmv.mat','lambda',reg_lam);
QSM_sim_smv =  MEDI_L1('filename','RDF_sim.mat','lambda',reg_lam);
QSM_sim_nstd = MEDI_L1_filt_dipole('filename', 'RDF_sim_nstd.mat','lambda',reg_lam);
QSM_ctrl =  MEDI_L1_orig_dipole('filename','RDF_sim.mat','lambda',reg_lam);
QSM_mPDF = MEDI_L1_orig_dipole('filename','RDF_sim_mPDF.mat','lambda',reg_lam);
%% Compare reconstructions
true_QSM = load('data\simulation\RDF_sim_gt.mat').true_QSM;
gray_mask = load('data\simulation\RDF_sim_gt.mat').gray_mask;
roi_mask = load('sim_roi_mask.mat').roi_mask;
QSMs = {Mask_c.*QSM_ctrl 
        Mask_c.*QSM_mPDF
        Mask_SMV.*QSM_sim_smv 
        Mask_c.*QSM_sim_nstd;
        Mask_SHARPs{idxmax_SHARP}.*QSM_sim_SHARP 
        Mask_RESHARPs{idxmax_RESHARP}.*QSM_sim_RESHARP 
        Mask_VSHARP.*QSM_sim_VSHARP 
        Mask_LBV{idxmin_LBV}.*QSM_sim_LBV 
        Mask_iSMV.*QSM_sim_iSMV 
        Mask_c.*QSM_sim_msmv};
Masks = {Mask_c Mask_c Mask_SMV Mask_c Mask_SHARPs{idxmax_SHARP} Mask_RESHARPs{idxmax_RESHARP} Mask_VSHARP Mask_LBV{idxmin_LBV} Mask_iSMV Mask_c};
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
Masks = {Mask_c Mask_c Mask_c Mask_SMV Mask_c Mask_SHARPs{idxmax_SHARP} Mask_RESHARPs{idxmax_RESHARP} Mask_VSHARP Mask_LBV{idxmin_LBV} Mask_iSMV Mask_c};
for j = 1:length(QSM_figs)
    ax1 = 33;
    ax2 = 49;
    cor = 94;
    sag = 138;
    names = {'gt','ctrl','mpdf','smv','nstd','sharp','resharp','vsharp','lbv','ismv','msmv'};
    make_figures(QSM_figs{j},Masks{j},voxel_size','figures\simulation',ax1,sag,cor,[matrix_size(1) matrix_size(2)],names{j})
    cd ..
    cd ..
end



