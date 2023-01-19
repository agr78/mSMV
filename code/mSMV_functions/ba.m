function ba(a,mSMV,alg_strings,yscale,dm)

    figure;
    x = (a(:)+mSMV(:))./2;
    y = a(:)-mSMV(:);
    scatter(x,y)
    chi_b = mean(y(:));
    title(strcat(alg_strings,' agreement'))
    xlabel(['$\frac{\chi_{mSMV}+\chi_0}{2}$ (ppb)'],'Interpreter','LaTeX','FontSize',14)
    ylabel('$\chi_{mSMV} - \chi_0$ (ppb)','Interpreter','LaTeX','FontSize',14)
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
    text(15,10,utxt)
    ltxt = {strcat('\mu - 1.96\sigma =',{' '},string(chi_b-1.96*sigma))};
    text(15,-10,ltxt)
    ylim([-yscale yscale])
    if dm == 1
        plot_dm_wrapper
    end
    
