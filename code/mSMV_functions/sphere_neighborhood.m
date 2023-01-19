function Mask_s = sphere_neighborhood(matrix_size,voxel_size,radius,px,py,pz)

[Y,X,Z]=meshgrid(1:matrix_size(2),...
                 1:matrix_size(1),...
                 1:matrix_size(3));

X = X*voxel_size(1);
Y = Y*voxel_size(2);
Z = Z*voxel_size(3);

px = px*voxel_size(1);
py = py*voxel_size(2);
pz = pz*voxel_size(3);

Mask_s = ((X-px).^2 ... 
                +(Y-py).^2 ...
                +(Z-pz).^2)<=radius^2; 