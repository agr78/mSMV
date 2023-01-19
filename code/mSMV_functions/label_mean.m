function [m1,m2] = label_mean(v1,v2,l,Mask,r)
Mask_SMV = MaskErode(Mask,matrix_size,voxel_size,r);
for j = 1:length(unique(l))-1
    if ~isempty(v1(l == j)) && ~isempty(v2(l == j)) 
        m1(j) = mean(v1(l == j));
        m2(j) = mean(v2(l == j));
    else
        disp(strcat('Label',{' '},string(j),{' '},'empty'))
    end

    if Mask(l==j) > Mask_SMV(l==j)
        disp('Lesion',{' '},string(j),{' '},'eroded!')
    end
end
