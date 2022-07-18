function [L, invL, DiffMask, Mask_out] = prepare_VSHARP(radius, Mask, matrix_size, voxel_size)

    % variable SMV
    stol = .2;                  % truncation threshold
    % Kernel_Sizes = (2*radius+1):-2:3;
    % Kernel_Sizes = 3;           % Changed from Bilgic's script due to small matrix size
    Kernel_Sizes = 2*radius;
    
    Mask0 = Mask;
    DiffMask = zeros([matrix_size, length(Kernel_Sizes)]);
    Mask_Sharp = zeros([matrix_size, length(Kernel_Sizes)]);
    L = zeros([matrix_size, length(Kernel_Sizes)]);
    invL = zeros([matrix_size, length(Kernel_Sizes)]);

%     for k = 1:length(Kernel_Sizes)
% 
%         Kernel_Size = Kernel_Sizes(k);
% 
%         ksize = [Kernel_Size, Kernel_Size, Kernel_Size];                % Sharp kernel size
%         khsize = (ksize-1)/2;
% %         erode_size = ksize + 1;
%         erode_size = ksize;
% 
%         msk_sharp0 = circshift(Mask0, [1,1,1]);
%         msk_sharp1 = imerode(msk_sharp0, strel('line', erode_size(1), 0));
%         msk_sharp2 = imerode(msk_sharp0, strel('line', erode_size(2), 90));
%         msk_sharp0 = permute(msk_sharp0, [1,3,2]);
%         msk_sharp3 = imerode(msk_sharp0, strel('line', erode_size(3), 0));
%         msk_sharp3 = permute(msk_sharp3, [1,3,2]);
%         msk_sharp = circshift(msk_sharp1 & msk_sharp2 & msk_sharp3, [-1,-1,-1]);
% 
%         Mask_Sharp(:,:,:,k) = msk_sharp; 
%         L(:,:,:,k) = SMV_kernel(matrix_size, [1,1,1], khsize(1));
% 
%         if k == 1
%             DiffMask(:,:,:,1) = Mask_Sharp(:,:,:,1);
%         else
%             DiffMask(:,:,:,k) = Mask_Sharp(:,:,:,k) - Mask_Sharp(:,:,:,k-1);
%         end
% 
%     end

    for k = 1:length(Kernel_Sizes)

        Kernel_Size = Kernel_Sizes(k);

        ksize = [Kernel_Size];                % Sharp kernel size
        khsize = (ksize)/2;
%         erode_size = ksize + 1;
        erode_size = khsize;

        %msk_sharp = SMV(Mask0, matrix_size, voxel_size, erode_size)>0.999;   % erode the boundary by erode_size mm
        msk_sharp = Mask; % AR 04/09/2022

        Mask_Sharp(:,:,:,k) = msk_sharp; 
        L(:,:,:,k) = SMV_kernel(matrix_size, voxel_size, erode_size);

        if k == 1
            DiffMask(:,:,:,1) = Mask_Sharp(:,:,:,1);
        else
            DiffMask(:,:,:,k) = Mask_Sharp(:,:,:,k) - Mask_Sharp(:,:,:,k-1);
        end

    end
    
    Mask_out = Mask_Sharp(:,:,:,end);
    
    

end