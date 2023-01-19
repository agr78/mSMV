% Scale regularization parameters
%
% Helper function to auto scale MEDI regularization parameters as in:
% Z. Liu, P. Spincemaille, Y. Yao, Y. Zhang, and Y. Wang, 
% "MEDI+0: Morphology enabled dipole inversion with 
% automatic uniform cerebrospinal fluid zero reference for 
% quantitative susceptibility mapping", 
% Magnetic Resonance in Medicine, vol. 79, no. 5, pp. 2795–2803, 2018.
%
% Alexandra G. Roberts
% MRI Lab
% Cornell University
% 12/12/2022

function [lambda1,lambda2] = scale_reg_params(def_lambda1,def_lambda2,CF,voxel_size,delta_TE)
CF0 = 127736342;
delta_TE0 = 0.004476000089198;
voxel_size0 = [0.625;0.625;2];

lambda1 = (def_lambda1*delta_TE0*CF0)/(delta_TE*CF);
lambda1 = (lambda1*sqrt(sum(voxel_size0.^2)))/sqrt(sum(voxel_size.^2)); 

lambda2 = (def_lambda2*(CF0*delta_TE0))/(delta_TE * CF);