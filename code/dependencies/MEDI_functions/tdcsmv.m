% Generates a rendered solid spherical kernel for SMV
% matrix_size is the size of the 3D matrix
% voxel_size is the size of the voxel
% radius is the raidus of the spherical shell
% The radius must be greater than half of the largest dimension of the voxel

function a = tdcsmv(matrix_size, voxel_size, radius)

f = zeros(matrix_size);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (voxel_size(1)==voxel_size(3))
    w = 10;
else
    g = voxel_size(1);
    w = 1;
    while (int16(g*w)~=single(g*w))
        w = w+1;
    end
end
w = w*2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vs = voxel_size*w;
R = radius*w;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n = ceil(radius/voxel_size(1));
dx = vs(1);
dz = vs(3);
ps = 1;
d1 = .5*ps;
d2 = .5*ps;
[x y z] = meshgrid(-dx/2+d1:ps:dx/2-d2,-dx/2+d1:ps:dx/2-d2,-dz/2+d1:ps:dz/2-d2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
zmax = floor((radius+voxel_size(3)/2)/(voxel_size(3)));
for zof =-zmax:zmax
    for j = n-1:-1:-n+1
        for k = n-1:-1:-n+1
            sphere = ((x+dx*k).^2+(y+dx*j).^2+(z+dz*zof).^2)<=(R)^2;
            f(end/2+1+k,end/2+1+j,end/2+zof+1) = sum(sphere(:))/((w/ps)^3);
        end
    end
end
V = (4/3)*pi*(radius^3);
SMV = f/(sum(f(:)));
a = fftn(fftshift(SMV));
