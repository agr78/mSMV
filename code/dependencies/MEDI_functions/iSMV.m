%Compute iSMV of iFreq
% matrix_size is the size of the 3D matrix
% voxel_size is the size of the voxel
% radius is the raidus of the solid sphere
% The radius must be greater than half of the largest dimension of the voxel

function [L,M] = iSMV(iFreq,Mask,matrix_size,voxel_size,radius)
tic
a = tdcsmv(matrix_size,voxel_size,radius);
F0 = iFreq; 
F1 = F0;
M = ifftn(fftn(Mask).*a)>.999;
BV = ((Mask-M).*iFreq);
d = 100;
iteration = 0;
while (d>=.001)
    F2 = ifftn(fftn(F1).*a).*M+BV;
    d = norm(F1(:)-F2(:))/norm(F1(:));
    iteration = iteration + 1;
    F1 = F2;
    %disp(num2str(d));
end
time = toc;
disp(['Elapsed Time = ' num2str(time) ]);
disp(['Iteration = ' num2str(iteration) ]);
L = (F0-F2).*M;
