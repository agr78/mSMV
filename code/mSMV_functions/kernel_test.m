function [K,maxvals,t] = kernel_test(RDF,voxel_size,matrix_size,Mask)

Kmin = min(voxel_size)./10;
Kmax = 1;

K = linspace(Kmin,Kmax,500);
K = [0,K];

for k = 1:length(K)
    RDF_smv = Mask.*(RDF-SMV(RDF,matrix_size,voxel_size,K(k)));
    [maxval] = max(abs(RDF_smv(:)));
    maxvals(k) = maxval;
end

t = min(maxvals(maxvals>10e-10))
figure; plot(K,maxvals(1:length(K)))