function ba(a,mSMV,alg_strings,yscale,xu,dm)

    x = (a(:)+mSMV(:))./2;
    y = a(:)-mSMV(:);
    scatter(x,y)
    chi_b = mean(y(:));
    title(strcat(alg_strings,' agreement'),'Interpreter','LaTeX','FontSize',18)
    xlabel(['$\frac{\chi_{mSMV}+\chi_0}{2}$ (ppb)'],'Interpreter','LaTeX','FontSize',18)
    ylabel('$\chi_{mSMV} - \chi_0$ (ppb)','Interpreter','LaTeX','FontSize',18)
    hold on
    sigma = std(y(:));
    plot(-xu:xu,chi_b+1.96*sigma.*ones(size(-xu:xu)),'k')
    hold on
    plot(-xu:xu,chi_b-1.96*sigma.*ones(size(-xu:xu)),'k')
    hold on
    plot(-xu:xu,chi_b.*ones(size(-xu:xu)),'k')
    grid on
    box on
    utxt = {strcat('\mu + 1.96\sigma =',{' '},string(chi_b+1.96*sigma))};
    text(15,10,utxt)
    ltxt = {strcat('\mu - 1.96\sigma =',{' '},string(chi_b-1.96*sigma))};
    text(15,-10,ltxt)
    ylim([-yscale yscale])
    if dm == 1
        plot_dm_wrapper
    end
    
