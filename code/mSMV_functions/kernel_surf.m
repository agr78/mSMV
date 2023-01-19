R = linspace(1*min(voxel_size),10*min(voxel_size),10);
figure;
for r = 1:length(R)
    K(:,:,:,r) = sphere_kernel_is(matrix_size,voxel_size,R(r)/2);
    subplot(2,5,r)
    isosurface(K(:,:,:,r)); xlim([0 matrix_size(1)]); ylim([0 matrix_size(2)]); zlim([0 matrix_size(3)])
    view(3)
    camlight;
    title(strcat('Kernel of radius',{' '},string(r),{' '},'voxels'))
end
