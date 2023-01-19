% QSM stats
%
% Helper function to compare shadow reduction methods and ground
% truth data
%
% Alexandra G. Roberts
% MRI Lab
% Cornell University
% 03/31/2022

function out_stats = QSM_stats(true_QSM,QSMs,Masks,gray_mask,roi_mask,matrix_size,voxel_size)
set(groot,'defaultFigureVisible','off')
warning('off','all')
    Mask = Masks{1};
    Mask_SMV = MaskErode(Mask,matrix_size,voxel_size,5);
    % Calculate fits and slopes
    for j = 1:length(QSMs)
    [fitres,gof] = createFit(true_QSM(:),Mask(:).*QSMs{j}(:)); slope{j} = fitres.p1; gofs{j} = gof.rsquare;
    end
    disp('Whole brain fit: r and m')
     [sqrt(cell2mat(gofs))']
     [cell2mat(slope)']


    for j = 1:length(QSMs)
    [fitres,gof] = createFit(Mask_SMV(:).*true_QSM(:),Mask_SMV(:).*QSMs{j}(:)); slopes{j} = fitres.p1; gofss{j} = gof.rsquare;
    end
    disp('~Edge brain fit: r and m')
     [sqrt(cell2mat(gofss))']
     [cell2mat(slopes)']

    Mask_e = Mask-MaskErode(Mask,matrix_size,voxel_size,6);
    for j = 1:length(QSMs)
    [fitres,gof] = createFit((Mask(:)-Mask_e(:)).*true_QSM(:),(Mask(:)-Mask_e(:)).*QSMs{j}(:)); slopese{j} = fitres.p1; gofsse{j} = gof.rsquare;
    end
    disp('Edge brain fit: r and m')
     [sqrt(cell2mat(gofsse))']
     [cell2mat(slopese)']
   

    for j = 1:length(QSMs)
    [fitresr,gofr] = createFit(roi_mask(:).*true_QSM(:),roi_mask(:).*QSMs{j}(:)); 
    sloper{j} = fitresr.p1;
    gofsr{j} = gofr.rsquare;
    end
    disp('ROI fit: r and m')
    [sqrt(cell2mat(gofsr)')]
    [cell2mat(sloper)']
    

    for j = 1:length(QSMs)
    [fitresg,gofg] = createFit(Masks{j}(:).*gray_mask(:).*true_QSM(:),Masks{j}(:).*gray_mask(:).*QSMs{j}(:)); 
    slopeg{j} = fitresg.p1;
    gofsg{j} = gofg.rsquare;
    end
    disp('Gray matter fit: r and m')
     [sqrt(cell2mat(gofsg)')]
     [cell2mat(slopeg)']
   
    
set(groot,'defaultFigureVisible','on')
warning('on','all')