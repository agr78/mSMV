for j = 1:10
    load(strcat('romeo_RDF_anon_',string(j),'QSMs'),'Masks','QSMs','voxel_size','matrix_size');
    for k = 3:4
        QSMs_ax{k-2,j} = permute(QSMs{k},[2 1 3 4]);
        Masks_ax{k-2,j} = permute(Masks{k},[2 1 3 4]);
        QSMs_cor{k-2,j} = cor_view(QSMs_ax{k,j},Masks_ax{k,j},voxel_size);
        QSMs_sag{k-2,j}= sag_view(QSMs_ax{k,j},Masks_ax{k,j},voxel_size);
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
figure;
subplot(1,2,1)
[fitres,gof] = createFit(mns(2,:,:),mns(3,:,:));
title('Healthy subjects \chi_{ROI} fit')
xlabel('SMV (ppb)','Interpreter','LaTeX','FontSize',14)
ylabel('mSMV (ppb)','Interpreter','LaTeX','FontSize',14)
legend('Measured ROI means', strcat('y =',{' '},num2str(fitres.p1),'x','+',num2str(fitres.p2),...
    ' and ', ' r^2 =',{' '},num2str(gof.rsquare)), 'Location', 'southeast', 'Interpreter', 'TeX' );


smv = mns(2,:,:);
msmv = mns(3,:,:);
x = (smv(:)+msmv(:))./2;
y = smv(:)-msmv(:);
subplot(1,2,2)
scatter(x,y)
chi_b = mean(y(:));
xlim([0,170])
ylim([-100 100])
title('Healthy subject \chi_{ROI} agreement')
xlabel('$\frac{\chi_{mSMV}+\chi_{SMV}}{2}$ (ppb)','Interpreter','LaTeX','FontSize',14)
ylabel('$\chi_{mSMV} - \chi_{SMV}$ (ppb)','Interpreter','LaTeX','FontSize',14)
hold on
sigma = std(y(:));
plot(x,chi_b+1.96*sigma.*ones(size(x)),'k')
hold on
plot(x,chi_b-1.96*sigma.*ones(size(x)),'k')
hold on
plot(x,chi_b.*ones(size(x)),'k')
grid on
box on
utxt = {strcat('\mu + 1.96\sigma =',{' '},string(chi_b+1.96*sigma))};
text(120,15,utxt)
ltxt = {strcat('\mu - 1.96\sigma =',{' '},string(chi_b-1.96*sigma))};
text(120,-15,ltxt)