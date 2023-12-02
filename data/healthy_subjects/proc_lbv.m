cases = dir();
for i = 1:numel(cases)
    if ~contains(cases(i).name,'.') && ~contains(cases(i).name,'..')
        cd(cases(i).name)
        acq = dir();
        cd(acq(3).name)
        contrasts = dir();
        for i = 1:numel(contrasts)
            if contains(contrasts(i).name,'AXL_GRE') 
                [iField,voxel_size,matrix_size,CF,delta_TE,TE,B0_dir,B0_mag,files] = Read_DICOM(contrasts(i).name);
                iMag = squeeze(sqrt(sum(abs(iField).^2,4)));
                Mask = BET(iMag,matrix_size,voxel_size);
                [iFreq_raw,N_std] = Fit_ppm_complex(iField);
                iFreq = romeo(iFreq_raw, iMag, Mask);

                tol = 0.01; 
                depth = -1; 
                N1 = 30; 
                N2 = 100; 
                N3 = 100; 
                peel = 1;
                RDF = LBV(iFreq,Mask,matrix_size,voxel_size,tol,depth,peel,N1,N2,N3);
                fid = fopen(strcat('mask_p1.bin'),'r');
                Mask = reshape(fread(fid,matrix_size(1)*matrix_size(2)*matrix_size(3),'int'),matrix_size);
                iField_c = BGCor(iField, iFreq-(Mask.*(RDF-SMV(RDF,matrix_size,voxel_size,5))), TE); 
                R2s = arlo(TE,abs(iField_c));
                Mask_CSF = extract_whole_CSF(R2s,Mask,voxel_size,0,5);
            end
   
        end
        save RDF_lbv -v7.3
        cd ../..
    end
end

            
%%

for j = 1:11
    file_name = strcat('RDF',string(j),'_lbv.mat')
    load(file_name)
    radius = 5;
    disp(strcat('Processing ',{' '},file_name))
    % Store variables that will be overwritten
    RDF_c = RDF;
    Mask_c = Mask;
 
    % Preprocess local field with mSMV
    msmv_filename = strcat('RDF_lbv_',string(j),'_msmv_kl_mk.mat');
    msmv(file_name,msmv_filename)
    dmsmv_filename = strcat('RDF_lbv_',string(j),'_dmsmv_kl_mk.mat');
    msmv(file_name,dmsmv_filename,'no_prefilter')
 
    % Reconstruct using MEDI-L1 with the appropriate dipole kernel for each method
    reg_lam = 1000;
    reg_csf = 100;
    Masks = {Mask_c Mask_c Mask_c};
    QSM_dmsmv =  MEDI_L1('filename',dmsmv_filename,'lambda',reg_lam,'lambda_CSF',reg_csf,'dipole_filter',0);
    QSM_msmv =  MEDI_L1('filename',msmv_filename,'lambda',reg_lam,'lambda_CSF',reg_csf,'dipole_filter',1,'smv',radius);
    QSM_ctrl =  MEDI_L1('filename',file_name,'lambda',reg_lam,'lambda_CSF',reg_csf,'dipole_filter',0);
    QSMs = {QSM_ctrl QSM_dmsmv QSM_msmv};
 
    save(strcat('qsms',string(j),'_msmv_lbv.mat'),'QSMs','Masks','matrix_size','voxel_size')
end

%%
for i = 1:11

    filename = strcat('RDF',string(i),'.mat');
    load(filename,'gray_matter_mask');
    load(strcat('rois',string(i),'.mat'))
    R = fliplr(rois);
    load(strcat('qsms',string(i),'_msmv_lbv.mat'),'QSMs','Masks');
    gmm = Masks{1}.*fliplr(gray_matter_mask);
    ss_c(i) = var(QSMs{1}(gray_matter_mask>0));
    ss_msmv(i) = var(QSMs{3}(gray_matter_mask>0));

    rois_lbv(i,:) = QSM_fs_rois(R,QSMs{1});
    rois_msmv(i,:) = QSM_fs_rois(R,QSMs{3});
    
end

  alpha = 0.01;
  [p,h] = signrank(ss_msmv,ss_c,'Alpha',alpha);

  ss_lbv = ss_c;
  ss_lbv_msmv = ss_msmv;

  figure(4);  
  method = categorical({'LBV-MEDI','LBV+mSMV-MEDI'});
  method = reordercats(categorical({'LBV-MEDI','LBV+mSMV-MEDI'}));
  boxplot([ss_c(:),ss_msmv(:)],method,'grouporder',{'LBV-MEDI','LBV+mSMV-MEDI'})
  sigstar({[1,2]},[0.01],0)
  ax = gca;
  set(gca,'TickLabelInterpreter','LaTex')
  ax.XAxis.FontSize = 24;
  ax.YRuler.Exponent = 0;
  ylabel('$\sigma_{\mathrm{gray matter}}^2 \ \mathrm{(ppm)}^2$','Interpreter','LaTex','FontSize',24)
  ylim([0,0.014])

  algs = {'LBV+MEDI'};
  algs_rois = {rois_lbv}
  for j = 1:length(algs)
      figure(5)
      set(gca,'FontSize',24)
      [fitres,gof] = createFit(algs_rois{j},rois_msmv(:));
      xlabel(strcat(algs{j},{' '},'(ppm)'),'Interpreter','LaTeX','FontSize',24)
      ylabel('LBV+MEDI-mSMV (ppm)','Interpreter','LaTeX','FontSize',24)
      legend('Measured ROI means', strcat('y =',{' '},num2str(round(fitres.p1,4)),'x','+',num2str(round(fitres.p2,4)),...
        ' and ', ' r =',{' '},num2str(round(sqrt(gof.rsquare),4))), 'Location', 'southeast', 'Interpreter', 'LaTex','FontSize',18);
      ylim([0,0.2])
      figure(6)
      ba(algs_rois{j},rois_msmv(:),{'SMV','mSMV'},0.2,0.2,0)
      title(strcat(algs{j},' agreement'),'Interpreter','LaTeX','FontSize',24)
  end
