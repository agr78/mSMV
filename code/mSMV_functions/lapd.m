function lapd(RDF,Mask,voxel_size)
    matrix_size = size(RDF);
    RDF_s0 = Mask.*(RDF-SMV(RDF,matrix_size,voxel_size,5));
    db = (RDF-RDF_s0);
    H = fspecial3('laplacian');
    Ldb = imfilter(db,H);
    Mask_b0 = (Mask-MaskErode(Mask,matrix_size,voxel_size,5)).*abs(Ldb) > mean(abs(Ldb(:)));
    
    % Problems at the edge
        % Max is there = background field
        % SMV kernel doesn't correctly calculate background field there
        % PDF doesn't correctly calculate background field there
        % db = |bL-(bL-S{bL})| = |S{bL}|
        % L{db} should be 0 everywhere if it is background field
        % If L{db} is not zero, more "local field" needs to be subtracted
        % Background field ~ Laplacian not equal to 0

   [x1,x2,x3] = ndgrid((-1/2)*matrix_size(1):voxel_size(1):(1/2)*matrix_size(1),(-1/2)*matrix_size(2):voxel_size(2):(1/2)*matrix_size(2),(-1/2)*matrix_size(3):voxel_size(3):(1/2)*matrix_size(3));

end