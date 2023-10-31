function ba(a,mSMV,alg_strings,yscale,xu,dm)

    x = (a(:)+mSMV(:))./2;
    y = a(:)-mSMV(:);
    scatter(x,y)
    chi_b = mean(y(:));
    title(strcat(alg_strings,' agreement'),'Interpreter','LaTeX','FontSize',24)
    xlabel(['Mean (ppm)'],'Interpreter','LaTeX','FontSize',24)
    ylabel('Difference (ppm)','Interpreter','LaTeX','FontSize',24)
    hold on
    sigma = std(y(:));
    plot(-xu:0.005:xu,chi_b+1.96*sigma.*ones(size(-xu:0.005:xu)),'k')
    hold on
    plot(-xu:0.005:xu,chi_b-1.96*sigma.*ones(size(-xu:0.005:xu)),'k')
    hold on
    plot(-xu:0.005:xu,chi_b.*ones(size(-xu:0.005:xu)),'k')
    grid on
    box on
    xlim([-xu,xu])
    utxt = {strcat('$\mu + 1.96\sigma =',{' '},string(round(chi_b+1.96*sigma,3)),'$')};
    text(0,chi_b+1.96*sigma+0.015,utxt,'Interpreter','LaTex','FontSize',18)
    ltxt = {strcat('$\mu - 1.96\sigma =',{' '},string(round(chi_b-1.96*sigma,3)),'$')};
    text(0,chi_b-1.96*sigma-0.015,ltxt,'Interpreter','LaTex','FontSize',18)
    ylim([-yscale yscale])
    if dm == 1
        plot_dm_wrapper
    end
    
