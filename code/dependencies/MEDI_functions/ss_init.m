function [chi_p_init,chi_n_init,R2p,alpha,beta] = ss_init(QSM,Mask,R2s,delta_TE,CF)
        alpha = 1.91;
        beta = alpha;
        alpha = (alpha/3*CF/1e6)*2*pi;
        beta = (beta/3*CF/1e6)*2*pi;
        zpp = zeros(size(Mask));
        znp = zeros(size(Mask));
        d1 = max(max(Mask,[],2),[],3);
        d1f = find(d1,1,'first');
        d1l = find(d1,1,'last');
        d2 = max(max(Mask,[],1),[],3);
        d2f = find(d2,1,'first');
        d2l = find(d2,1,'last');
        d3 = max(max(Mask,[],1),[],2);
        d3f = find(d3,1,'first');
        d3l = find(d3,1,'last');
        parfor k1 = d1f:d1l
            for k2 = d2f:d2l
                for k3 = d3f:d3l
                    if Mask(k1,k2,k3) == 1
                        C = [alpha/100 -beta/100; 1 1];
                        d = real([double(R2s(k1,k2,k3))/100; double(QSM(k1,k2,k3))]);
                        ub = [4; 0];
                        lb = [0; -4];
                        opts = optimset('Display','off');
                        x = lsqlin(C,d,[],[],[],[],lb,ub,[0 0],opts);
                        zpp(k1,k2,k3) = x(1);
                        znp(k1,k2,k3) = x(2);
                    end
                end
            end
        end
        chi_p_init = zpp*(2*pi*delta_TE*CF)/1e6;
        chi_n_init = znp*(2*pi*delta_TE*CF)/1e6;
        R2p = R2s;