function [RDF,SphereK] = vSMV(RDF,Mask,voxel_size,rmax)
    matrix_size = size(Mask);
    bg = zeros(matrix_size(1),matrix_size(2),matrix_size(3),rmax);
    bgs = zeros(matrix_size);
    shells = zeros(matrix_size);
    spheres = zeros(matrix_size);
    RDFs = zeros(matrix_size);
    for j = 1:rmax
        if j == 1
            rmax
            shells(:,:,:,j) = MaskErode(Mask,matrix_size,voxel_size,rmax-1);
            bg(:,:,:,j) = SMV(RDF,matrix_size,voxel_size,rmax);
            spheres(:,:,:,j) = single(sphere_kernel(matrix_size, voxel_size,rmax));
        else
              shells(:,:,:,j) = MaskErode(Mask,matrix_size,voxel_size,rmax-j+2)-MaskErode(Mask,matrix_size,voxel_size,rmax-j+1);
              spheres(:,:,:,j) = spheres(:,:,:,1)-single(sphere_kernel(matrix_size, voxel_size,rmax-j+1));
            end
            bg(:,:,:,j) = SMV(RDF,matrix_size,voxel_size,rmax-j+1);
            RDFs(:,:,:,j) = shells(:,:,:,j).*(RDF-bg(:,:,:,j));
    end
    RDF = sum(RDFs.*shells,4);