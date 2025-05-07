clear all;clc;close all;

%%%%% Import data %%%%%
load('RDF_total.mat','iField','voxel_size','matrix_size','CF','delta_TE','TE','B0_dir','iMag','Mask_CSF')

%%%%% Get uneroded mask from original RDF %%%%%
load('RDF_total.mat', 'RDF')
Mask = abs(RDF~=0);

%%%%% Provide a noise_level here if possible %%%%%%
if (~exist('noise_level','var'))
    noise_level = calfieldnoise(iField, Mask);
end

%%%%% Normalize signal intensity by noise to get SNR %%%
iField = iField/noise_level;

%%%%% Estimate the frequency offset in each of the voxel using a 
%%%%% complex fitting %%%%
[iFreq_raw N_std] = Fit_ppm_complex(iField);

%%% Spatial phase unwrapping %%%%
iFreq = unwrapPhase(iMag, iFreq_raw, matrix_size);

%%%% Background field removal %%%%
[RDF shim] = PDF(iFreq,N_std,Mask,matrix_size,voxel_size,B0_dir,0,100);

%%%% CSF Mask for zero referencing %%%%
%%%% R2s from corrected magnitude %%%%
iMagtc = niftiread('mag_t_bc.nii.gz');
R2s = arlo(TE,iMagtc);

%%%% Adjusted mSMV parameters %%%%
maxk = 1;
vessel_radius = 1.5;
tmin = 0.1;
B0_mag = 7;

%%%% Dipole inversion %%%%%
save RDF.mat RDF iFreq iFreq_raw iMag N_std Mask matrix_size...
     voxel_size delta_TE CF B0_dir Mask_CSF R2s vessel_radius maxk tmin B0_mag;
%QSM_msmv_10000_new = MEDI_L1r('filename', 'RDF.mat', 'lambda', 10000, 'merit', 'msmv',1);
QSM_msmv_10000 = MEDI_L1('filename', 'RDF.mat', 'lambda', 10000, 'merit', 'msmv',1);
