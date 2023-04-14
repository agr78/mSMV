% QSM stats
%
% Helper function to compare shadow reduction methods and ground
% truth data
%
% Alexandra G. Roberts
% MRI Lab
% Cornell University
% 03/31/2022

function out_stats = QSM_ROI_stats(true_QSM,QSMs,Masks,roi_mask,matrix_size,voxel_size)
set(groot,'defaultFigureVisible','off')
warning('off','all')


    for j = 1:length(QSMs)
    [fitresr,gofr] = createFit(roi_mask(:).*true_QSM(:),roi_mask(:).*QSMs{j}(:)); 
    sloper{j} = fitresr.p1;
    gofsr{j} = gofr.rsquare;
    end
    disp('ROI fit: r and m')
    [sqrt(cell2mat(gofsr)')]
    [cell2mat(sloper)']
    
set(groot,'defaultFigureVisible','on')
warning('on','all')