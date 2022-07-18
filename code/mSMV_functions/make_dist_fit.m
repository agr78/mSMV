function make_dist_fit(RDF_bk_dist,nbins)
    u = mean(RDF_bk_dist); data = RDF_bk_dist-u; 
    range = max(data)-min(data);
    figure;
    hold on;
    h = histogram(data,nbins,'Normalization','Probability');
    pd = fitdist(data,'Normal')
    xValues = -1:0.001:1;  % for computing the pdf
    y = pdf(pd,xValues);   % adjust to match probability based on nbins & range
    plot(xValues,y*range/nbins); xlim([-1,1])
    title('Sampled background field distribution')
    xlabel('\chi')
    ylabel('\it P(\chi)')
    %make_dist_fit(RDF_bk(:),round(sum(J(:))/5))
end