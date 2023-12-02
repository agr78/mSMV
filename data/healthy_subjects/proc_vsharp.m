
for j = 1:numel(cases)-2
    file_name = strcat('RDF',string(j),'_vsharp.mat')
    load(file_name)
    load(strcat('RDF',string(j),'.mat'),'R2s').R2s;
    save(strcat('vm',file_name),'RDF','matrix_size','voxel_size','Mask','B0_dir','CF','delta_TE','iFreq','iFreq_raw','iMag','Mask_CSF','N_std','R2s')
    radius = 5;
    disp(strcat('Processing ',{' '},file_name))
    % Store variables that will be overwritten
    RDF_c = RDF;
    Mask_c = Mask;
 
    % Preprocess local field with mSMV
    msmv_filename = strcat('vmRDF_mk',string(j),'_vsharp_msmv_kl.mat');
    msmv(strcat('vm',file_name),msmv_filename,'no_prefilter')
 
    % Reconstruct using MEDI-L1 with the appropriate dipole kernel for each method
    reg_lam = 1000;
    reg_csf = 100;
    Masks = {Mask_c Mask_c Mask_c};
    
    QSM_msmv =  MEDI_L1('filename',msmv_filename,'lambda',reg_lam,'lambda_CSF',reg_csf,'dipole_filter',1,'smv',radius);
    QSM_ctrl = MEDI_L1('filename',file_name,'lambda',reg_lam,'lambda_CSF',reg_csf,'dipole_filter',1,'smv',radius);
    QSMs = {QSM_ctrl QSM_msmv};
 
    save(strcat('qsms',string(j),'_msmv_vsharp.mat'),'QSMs','Masks','matrix_size','voxel_size')
end

%%
%%
for i = 1:11

    filename = strcat('RDF',string(i),'.mat');
    load(filename,'gray_matter_mask');
    load(strcat('rois',string(i),'.mat'))
    R = fliplr(rois);
    load(strcat('qsms',string(i),'_msmv_vsharp.mat'),'QSMs','Masks');
    gmm = Masks{1}.*fliplr(gray_matter_mask);
    ss_c(i) = var(QSMs{1}(gray_matter_mask>0));
    ss_msmv(i) = var(QSMs{2}(gray_matter_mask>0));

    rois_vsharp(i,:) = QSM_fs_rois(R,QSMs{1});
    rois_msmv(i,:) = QSM_fs_rois(R,QSMs{2});
    
end

  alpha = 0.01;
  [p,h] = signrank(ss_msmv,ss_c,'Alpha',alpha);

  ss_vsharp = ss_c;
  ss_vsharp_msmv = ss_msmv;
  
  figure(7);
  method = categorical({'VSHARP-MEDI','VSHARP+mSMV-MEDI'});
  method = reordercats(categorical({'VSHARP-MEDI','VSHARP+mSMV-MEDI'}));
  boxplot([ss_c(:),ss_msmv(:)],method,'grouporder',{'VSHARP-MEDI','VSHARP+mSMV-MEDI'})
  sigstar({[1,2]},[0.01],0)
  ax = gca;
  set(gca,'TickLabelInterpreter','LaTex')
  ax.XAxis.FontSize = 24;
  ax.YRuler.Exponent = 0;
  ylabel('$\sigma_{\mathrm{gray matter}}^2 \ \mathrm{(ppm)}^2$','Interpreter','LaTex','FontSize',24)
  ylim([0,0.014])

  algs = {'MEDI+VSHARP'};
  algs_rois = {rois_vsharp}
  for j = 1:length(algs)
      figure(8)
      set(gca,'FontSize',24)
      [fitres,gof] = createFit(algs_rois{j},rois_msmv(:));
      xlabel(strcat(algs{j},{' '},'(ppb)'),'Interpreter','LaTeX','FontSize',24)
      ylabel('MEDI+VSHARP-mSMV (ppb)','Interpreter','LaTeX','FontSize',24)
      legend('Measured ROI means', strcat('y =',{' '},num2str(round(fitres.p1,4)),'x','+',num2str(round(fitres.p2,4)),...
        ' and ', ' r =',{' '},num2str(round(sqrt(gof.rsquare),4))), 'Location', 'southeast', 'Interpreter', 'LaTex','FontSize',18);
      ylim([0,0.2])
      figure(9)
      ba(algs_rois{j},rois_msmv(:),{'SMV','mSMV'},0.2,0.2,0)
      title(strcat(algs{j},' agreement'),'Interpreter','LaTeX','FontSize',24)
  end
