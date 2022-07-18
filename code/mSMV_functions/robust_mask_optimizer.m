clc
clear
load RDF_sim.mat
% Load true RDF for parameter optimization
RDF_t = load('data\simulation\RDF_sim_gt.mat').RDF;
k = 1;
P = 50:1:80;
for p = 50:1:80
    Mask_r{k} = percentile_mask(Mask,iMag,p);
    RDF = Mask_r{k}.*RDF;
    mse_xTpp(k) = mse(RDF_t(:),RDF(:));
    k = k+1;
end

[minval_xTpp,idxmin_xTpp] = min(mse_xTpp);
disp('Optimal xTpp percentile is')
P(idxmin_xTpp)

%%
load('RDF_sim.mat')
RDF = percentile_mask(Mask,iMag,P(idxmin_xTpp)).*(RDF-SMV(RDF,matrix_size,voxel_size,5));
save('RDF_sim_xTpp.mat')