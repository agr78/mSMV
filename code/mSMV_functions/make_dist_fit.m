function make_dist_fit(RDF_bk_dist,nbins)
    u = mean(RDF_bk_dist); data = RDF_bk_dist-u; 
    range = max(data)-min(data)
    figure;
    hold on;
    h = histogram(data,nbins,'Normalization','Probability');
    pd = fitdist(data,'Normal')
    xValues = -0.4:0.001:0.4;  % for computing the pdf
    y = pdf(pd,xValues);   % adjust to match probability based on nbins & range
    y = rescale(y,0,0.7,'InputMin',min(y(:)),'InputMax',max(y(:)));
    plot(xValues,y); xlim([-1,1])
    title('Sampled background field distribution')
    xlabel('\chi')
    ylabel('\it P(\chi)')
    %make_dist_fit(RDF_bk(:),round(sum(J(:))/5))
end