function [ts,R] = detect_grad_polarity(iField,matrix_size,voxel_size,N)

iMag = squeeze(sqrt(sum(abs(iField).^2,4)));
Mask = BET(iMag,matrix_size,voxel_size);
c = round(matrix_size(3)/2);
Mask2d = Mask(:,:,c);
for j = 1:size(iField,4)
    iField_echo = angle(iField(:,:,c,j));
    iField_nz(:,j) = angle(iField_echo(Mask2d>0));
end

% Consider only positions in brain mask
sample_pool = find(sum(iField_nz,2));

% Generate uniform distribution of indices
k = 1;
figure;
while k < N+1
    U = randi([1,size(iField_nz,1)])
    if sum(iField_nz(U,:),2) > 0
        ts{k} = iField_nz(U,:);
        plot(ts{k}); hold on
        [c,r] = fit([1:size(iField,4)]',squeeze(ts{k})','sin2');
        R{k} = r.rsquare;
        k = k+1;
        disp('Nonzero time evolution found')

    else
    end
end


