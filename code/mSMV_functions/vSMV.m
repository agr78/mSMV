function RDF = vSMV(RDF,Mask,voxel_size,rmax)
    matrix_size = size(Mask);
    bg = zeros(matrix_size(1),matrix_size(2),matrix_size(3),rmax);
    bgs = zeros(matrix_size);
    shells = zeros(matrix_size);
    for j = 1:rmax
        j
        if j == 1
            rmax
            shells(:,:,:,j) = MaskErode(Mask,matrix_size,voxel_size,rmax-1);
            bg(:,:,:,j) = SMV(RDF,matrix_size,voxel_size,rmax);
        else
            disp('For radius')
            rmax-j+1
            disp('Compute shell between')
            rmax-j+1
            rmax-j
            if rmax-j == 0
               shells(:,:,:,j) = Mask-MaskErode(Mask,matrix_size,voxel_size,rmax-j+1);
            else
               shells(:,:,:,j) = MaskErode(Mask,matrix_size,voxel_size,rmax-j)-MaskErode(Mask,matrix_size,voxel_size,rmax-j+1);
            end
            bg(:,:,:,j) = SMV(RDF,matrix_size,voxel_size,rmax-j+1);
        end
    end
    RDF = Mask.*(RDF-SMV(sum(shells.*bg,4),matrix_size,voxel_size,1));
