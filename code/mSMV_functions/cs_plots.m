method = categorical({'Cortical gray matter','Veins','Pathology','Shadow','Brain stem'});
method = reordercats(method,{'Cortical gray matter','Veins','Pathology','Shadow','Brain stem'});
blue = [0 0.4470 0.7410];
red = [0.8500 0.3250 0.0980];
yellow = [0.9290 0.6940 0.1250];
ylim([0 5]);
xlim([0,20])
A1 = [pdf_c_x smv_c_x msmv_c_x 0];
b1 = bar([1 2 3 4], A1); 
b1.FaceColor = 'flat';
b1.CData(1,:) = blue;
b1.CData(2,:) = red;
b1.CData(3,:) = yellow;
hold on 
A2 = [pdf_v_x smv_v_x msmv_v_x 0];
b2 = bar([5 6 7 8],A2); 
b2.FaceColor = 'flat';
b2.CData(1,:) = blue;
b2.CData(2,:) = red;
b2.CData(3,:) = yellow;
hold on 
A3 = [pdf_p_x smv_p_x msmv_p_x 0];
b3 = bar([9 10 11 12],A3); 
b3.FaceColor = 'flat';
b3.CData(1,:) = blue;
b3.CData(2,:) = red;
b3.CData(3,:) = yellow;
hold on 
A4 = [pdf_s_x smv_s_x msmv_s_x 0];
b4 = bar([13 14 15 16],A4); 
b4.FaceColor = 'flat';
b4.CData(1,:) = blue;
b4.CData(2,:) = red;
b4.CData(3,:) = yellow;
hold on 
A5 = [pdf_st_x smv_st_x msmv_st_x];
b5 = bar([17 18 19],A5);
b5.FaceColor = 'flat';
b5.CData(1,:) = blue;
b5.CData(2,:) = red;
b5.CData(3,:) = yellow;
title('Clinical scoring')
ylabel('Score')
ax = gca;
ax.XTick = [2 6 10 14 18];
ax.XTickLabel = {string(method(1)) string(method(2)) string(method(3)) string(method(4)) string(method(5))};
groups = {[2,3],[1,3],[6,7],[5,7],[10,11],[13,15],[17,19]};
sigstar(groups,[0.005,0.005,0.005,0.005,0.05,0.005,0.005])
h = zeros(3, 1);
h(1) = bar(NaN,NaN,'FaceColor', blue);
h(2) = bar(NaN,NaN,'FaceColor',red);
h(3) = bar(NaN,NaN,'FaceColor',yellow);
legend(h, 'PDF','SMV','mSMV');
hold off


%%
alpha = 0.05;
[pc,hc] = signrank(smv_c,msmv_c,'alpha',alpha,'tail','left')
[pv,hv] = signrank(smv_v,msmv_v,'alpha',alpha,'tail','left')
[pp,hp] = signrank(smv_p,msmv_p,'alpha',alpha,'tail','left')
[ps,hs] = signrank(smv_ss,msmv_ss,'alpha',alpha,'tail','left')
[pst,hst] = signrank(smv_st,msmv_st,'alpha',alpha,'tail','left')

[pcx,hcx] = signrank(pdf_c,msmv_c,'alpha',alpha,'tail','left')
[pvx,hvx] = signrank(pdf_v,msmv_v,'alpha',alpha,'tail','left')
[ppx,hpx] = signrank(pdf_p,msmv_p,'alpha',alpha,'tail','left')
[psx,hsx] = signrank(pdf_ss,msmv_ss,'alpha',alpha,'tail','left')
[pstx,hstx] = signrank(pdf_st,msmv_st,'alpha',alpha,'tail','left')