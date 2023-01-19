% Small kernel radius simulation
clear R
clear rstar_err
clear whole_brain_err
% Define the smallest radius according to voxel size
epsilon = 0.1;
rmin = sqrt(sum((0.5*voxel_size).^2)); 
r0 = (1/(2+epsilon)).*rmin; 
N = 5;
rho = rmin-((1/(2+epsilon)).*rmin/N);
R = r0:rho:N*rmin;
R = R(1:end-1);
%linspace(r0,(lR-(1/(2+epsilon))*rmin)-r0,lR);
Mask_e = Mask-MaskErode(Mask,matrix_size,voxel_size,5);
figure;

for r = 1:length(R)
    % Initial SMV filtering
    [RDF_u] = SMV(RDF,matrix_size,voxel_size,R(r));
    RDF_smv{r} = Mask_e.*(RDF-SMV(RDF,matrix_size,voxel_size,R(r)));
    b_smv{r} = Mask_e.*(b_local-SMV(b_local,matrix_size,voxel_size,R(r)));
    b_smv_s = b_smv{r};
    RDF_smv_s = RDF_smv{r};
    % Find extremum
    [maxval,idx] = max(abs(RDF_smv_s(:)));
    % Record index
    idxr(r) = idx;
    bstar(r) = abs(RDF_smv_s(idx));
    bstar_0(r) = abs(b_smv_s(idx));
    rstar_err(r) = abs(RDF_smv_s(idx)-b_smv_s(idx)); %mse(abs(RDF_smv_s(idx)),abs(b_smv_s(idx)));
    edge_brain_err(r) = mean(abs(RDF_smv_s(Mask_e>0)-b_smv_s(Mask_e>0)));%mse(abs(RDF_smv_s(Mask_e>0)),abs(b_smv_s(Mask_e>0)));

    % Plot the kernel in image space
    K(:,:,:,r) = sphere_kernel_is(matrix_size,voxel_size,R(r));
    subplot(1,length(R),r)
    isosurface(K(:,:,:,r)); 
    xlim([(1/2)*matrix_size(1)-2*ceil(max(R)) (1/2)*matrix_size(1)+2*ceil(max(R))]); 
    ylim([(1/2)*matrix_size(2)-2*ceil(max(R)) (1/2)*matrix_size(2)+2*ceil(max(R))]); 
    zlim([(1/2)*matrix_size(3)-2*ceil(max(R)) (1/2)*matrix_size(3)+2*ceil(max(R))]); 
    axis square
    %     view(3)
    %     camlight;
    title(strcat(string(r),{' '},'voxels'))
    %plot_dm_wrapper
    sgtitle('Image space kernel by radius','Color','black','Interpreter','LaTeX','FontSize',24)
    
end


figure; 
subplot(1,2,1)
plot(R,edge_brain_err);
title('5mm edge brain error','Interpreter','LaTeX','FontSize',24)
xlabel('Kernel radius','Interpreter','LaTeX','FontSize',18)
ylabel('Mean-absolute error $\frac{1}{N} \Sigma|\hat{b}^0_L(\vec{r}) - b_L(\vec{r})|$','Interpreter','LaTeX','FontSize',18)
%plot_dm_wrapper
subplot(1,2,2)
plot(R,rstar_err)
xlabel('Kernel radius','Interpreter','LaTeX','FontSize',18)
ylabel('Absolute error $|\hat{b}^0_L(r^*) - b_L(r^*)|$','Interpreter','LaTeX','FontSize',18)
title('Maximum point $r^*$ error','Interpreter','LaTeX','FontSize',24)
%plot_dm_wrapper