for j = 1:10
    if j <10
    load(strcat('00',num2str(j),'input_RDFqsms_msmv_cor_r2s.mat'),'Masks','QSMs','voxel_size','matrix_size');
    else
    load(strcat('0',num2str(j),'input_RDFqsms_msmv_cor_r2s.mat'),'Masks','QSMs','voxel_size','matrix_size');
    end
    for k = 1:4
        QSMs_ax{k,j} = permute(QSMs{k},[2 1 3 4]);
        Masks_ax{k,j} = permute(Masks{k},[2 1 3 4]);
        QSMs_cor{k,j} = cor_view(QSMs_ax{k,j},Masks_ax{k,j},voxel_size);
        QSMs_sag{k,j}= sag_view(QSMs_ax{k,j},Masks_ax{k,j},voxel_size);
    end

end

args = QSMs_ax;
[m,n] = size(QSMs_ax);
for k = 1:n
    if k < 10
        ROIs{k} = readROIs(strcat('rois/ROI.HS/ROI','.00',string(k)));
    else 
        ROIs{k} = readROIs(strcat('rois/ROI.HS/ROI','.0',string(k)));
    end 
        ROIs{k}.img = permute(ROIs{k}.img,[2 1 3 4]);

        for j = 1:numel(ROIs{k}.idx)
            for i = 1:m
                idxM = ROIs{k}.img == ROIs{k}.idx(j);
                mns(i,j,k) = mean(args{i,k}(idxM>0));
            end
        end
end
mns = mns*1000;
f1 = figure(1);
subplot(1,2,1)
[fitres,gof] = createFit(mns(2,:,:),mns(3,:,:));
title('Healthy subjects $\chi_{ROI}$ fit','Interpreter','LaTeX','FontSize',18)
xlabel('SMV (ppb)','Interpreter','LaTeX','FontSize',14)
ylabel('mSMV (ppb)','Interpreter','LaTeX','FontSize',14)
legend('Measured ROI means', strcat('y =',{' '},num2str(fitres.p1),'x','+',num2str(fitres.p2),...
    ' and ', ' r =',{' '},num2str(sqrt(gof.rsquare))), 'Location', 'southeast', 'Interpreter', 'TeX' );
smv_q = mns(2,:,:);
msmv_q = mns(3,:,:);
subplot(1,2,2)
x = (smv_q(:)+msmv_q(:))./2;
xu = 170;
y = smv_q(:)-msmv_q(:);
scatter(x,y)
chi_b = mean(y(:));
title('SMV agreement','Interpreter','LaTeX','FontSize',18)
xlabel(['$\frac{\chi_{mSMV}+\chi_{SMV}}{2}$ (ppb)'],'Interpreter','LaTeX','FontSize',14)
ylabel('$\chi_{mSMV} - \chi_{SMV}$ (ppb)','Interpreter','LaTeX','FontSize',14)
hold on
sigma = std(y(:));
plot(0:xu,chi_b+1.96*sigma.*ones(size(0:xu)),'k')
hold on
plot(0:xu,chi_b-1.96*sigma.*ones(size(0:xu)),'k')
hold on
plot(0:xu,chi_b.*ones(size(0:xu)),'k')
grid on
box on
utxt = {strcat('\mu + 1.96\sigma =',{' '},string(chi_b+1.96*sigma))};
text(120,ceil(chi_b+1.96*sigma)+2,utxt)
ltxt = {strcat('\mu - 1.96\sigma =',{' '},string(chi_b-1.96*sigma))};
text(120,(ceil(chi_b-1.96*sigma)-2),ltxt)
xlim([0,xu])
ylim([-100 100])
hold off
%%
clear x y
PDF = mns(1,:,:);
SMV = mns(2,:,:);
mSMV = mns(3,:,:);
VSHARP = mns(4,:,:);
algs = {PDF SMV VSHARP};
algs_strings = {'PDF' 'SMV' 'VSHARP'};
f2 = figure(2);
f3 = figure(3);
for j = 1:length(algs)
    figure(2);
    a = algs{j};
    x = (a(:)+mSMV(:))./2;
    y = a(:)-mSMV(:);
    f2 = subplot(1,3,j);
    scatter(x,y)
    chi_b = mean(y(:));
    title(strcat(algs_strings{j},' agreement'),'Interpreter','LaTeX','FontSize',18)
    xlabel(['$\frac{\chi_{mSMV}+\chi_0}{2}$ (ppb)'],'Interpreter','LaTeX','FontSize',14)
    ylabel('$\chi_{mSMV} - \chi_0$ (ppb)','Interpreter','LaTeX','FontSize',14)
    hold on
    sigma = std(y(:));
    plot(0:xu,chi_b+1.96*sigma.*ones(size(0:xu)),'k')
    hold on
    plot(0:xu,chi_b-1.96*sigma.*ones(size(0:xu)),'k')
    hold on
    plot(0:xu,chi_b.*ones(size(0:xu)),'k')
    grid on
    box on
    utxt = {strcat('\mu + 1.96\sigma =',{' '},string(chi_b+1.96*sigma))};
    text(120,ceil(chi_b+1.96*sigma)+2,utxt)
    ltxt = {strcat('\mu - 1.96\sigma =',{' '},string(chi_b-1.96*sigma))};
    text(120,(ceil(chi_b-1.96*sigma)-2),ltxt)
    xlim([0,xu])
    ylim([-100 100])

    figure(3);
    f3 = subplot(1,3,j);
    [fitres,gof] = createFit(a,mSMV);
    title(strcat(algs_strings{j},' fit'),'Interpreter','LaTeX','FontSize',18)
    xlabel('$\chi_0$ (ppb)','Interpreter','LaTeX','FontSize',14)
    ylabel('$\chi_{mSMV}$ (ppb)','Interpreter','LaTeX','FontSize',14)
    legend('Measured ROI means', strcat('y =',{' '},num2str(fitres.p1),'x','+',num2str(fitres.p2),...
        ' and ', ' r =',{' '},num2str(sqrt(gof.rsquare))), 'Location', 'southeast', 'Interpreter', 'TeX' );

end