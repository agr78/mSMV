function make_sup_figures(Mask,N_std,Mask_bk)
    matrix_size = size(Mask);
    z = zeros(max(matrix_size),max(matrix_size));
    N_std = N_std.*Mask;
    [r,c,p] = size(Mask);
    m = 10-mod(p,10);
    for j = 1:m
        Mask(:,:,p+j) = z;
        N_std(:,:,p+j) = z;
        Mask_bk(:,:,p+j) = z;
    end
    figure;
    montage(Mask.*N_std,'DisplayRange',[]);
    title('Field estimation error map')
    figure;
    montage(Mask_bk,'DisplayRange',[]);
    title('Residual background field mask')
end