% Morphology Enabled Dipole Inversion (MEDI)
%   [x, cost_reg_history, cost_data_history] = MEDI_L1(varargin)
%
%   output
%   x - the susceptibility distribution 
%   cost_reg_history - the cost of the regularization term
%   cost_data_history - the cost of the data fidelity term
%   
%   input
%   RDF.mat has to be in current folder.  
%   MEDI_L1('lambda',lam,...) - lam specifies the regularization parameter
%                               lam is in front of the data fidelity term
%
%   ----optional----   
%   MEDI_L1('smv', radius,...) - specify the radius for the spherical mean
%                                value operator using differential form
%   MEDI_L1('merit',...) - turn on model error reduction through iterative
%                          tuning
%   MEDI_L1('zeropad',padsize,...) - zero pad the matrix by padsize
%   MEDI_L1('lambda_CSF',lam_CSF,...) - automatic zero reference (MEDI+0)
%                                       also require Mask_CSF in RDF.mat
%
%   When using the code, please cite 
%   Z. Liu et al. MRM 2017;DOI:10.1002/mrm.26946
%   T. Liu et al. MRM 2013;69(2):467-76
%   J. Liu et al. Neuroimage 2012;59(3):2560-8.
%   T. Liu et al. MRM 2011;66(3):777-83
%   de Rochefort et al. MRM 2010;63(1):194-206
%
%   Adapted from Ildar Khalidov
%   Modified by Tian Liu on 2011.02.01
%   Modified by Tian Liu and Shuai Wang on 2011.03.15
%   Modified by Tian Liu and Shuai Wang on 2011.03.28 add voxel_size in grad and div
%   Last modified by Tian Liu on 2013.07.24
%   Last modified by Tian Liu on 2014.09.22
%   Last modified by Tian Liu on 2014.12.15
%   Last modified by Zhe Liu on 2017.11.06

function [x, cost_reg_history, cost_data_history, resultsfile] = MEDI_L1ss(varargin)

[lambda, ~, RDF, N_std, iMag, Mask, matrix_size, matrix_size0, voxel_size, ...
    delta_TE, CF, B0_dir, merit, smv, radius, data_weighting, gradient_weighting, ...
    Debug_Mode, lam_CSF, Mask_CSF, alpha, beta, R2p, chi_n_init, chi_p_init, solver, percentage] = parse_QSMss_input(varargin{:});

%%%%%%%%%%%%%%% weights definition %%%%%%%%%%%%%%
cg_max_iter = 100;%100;
cg_tol = 0.01;
max_iter = 10;
tol_norm_ratio = 0.01;
data_weighting_mode = data_weighting;
gradient_weighting_mode = gradient_weighting;
grad = @fgrad;
div = @bdiv;
% grad = @cgrad;
% div = @cdiv;

N_std = N_std.*Mask;
tempn = single(N_std);
D=dipole_kernel(matrix_size, voxel_size, B0_dir);

if (smv)
%     S = SMV_kernel(matrix_size, voxel_size,radius);
    SphereK = single(sphere_kernel(matrix_size, voxel_size,radius));
%    Mask = SMV(Mask, SphereK)>0.999;
    D=(1-SphereK).*D;
%    RDF = RDF - SMV(RDF, SphereK);
%    RDF = RDF.*Mask;
    
    tempn = sqrt(SMV(tempn.^2, SphereK)+tempn.^2);
end
R2p = R2p.*Mask;
% alpha = alpha*1000;
% beta = beta*1000;

mf = dataterm_mask(data_weighting_mode, tempn, Mask);
mr = heaviside(R2p-30).*mf./10+heaviside(30-R2p).*heaviside(R2p-1).*mf+heaviside(1-R2p).*mf./10;
% mr = mf;
br = mr.*R2p;
bf = 1i*mf.*RDF;
Ap = alpha*mr/(2*pi*delta_TE*CF)*1e6;
Am = beta*mr/(2*pi*delta_TE*CF)*1e6;

wGm = gradient_mask(gradient_weighting_mode, iMag, Mask, grad, voxel_size, percentage);
wGr = gradient_mask(gradient_weighting_mode, R2p, Mask, grad, voxel_size, 0.44);



% CSF regularization
flag_CSF = ~isempty(Mask_CSF);
if flag_CSF
    fprintf('CSF regularization used\n');
end
oldN_std=N_std;
fprintf(['Using ' solver '\n']);
switch solver
    case 'gaussnewton'
        [x, cost_reg_history, cost_data_history] = gaussnewton();
end

    function [x, cost_reg_history, cost_data_history] = gaussnewton()
        
%         if flag_CSF
%             LT_reg = @(x) Mask_CSF.*(x - mean(x(Mask_CSF)));
%         end

        
        iter=0;
        %x = zeros([matrix_size,2]); %real(ifftn(conj(D).*fftn((abs(m).^2).*RDF)));
         x = cat(4,chi_p_init, chi_n_init);
        if (~isempty(findstr(upper(Debug_Mode),'SAVEITER')))
            store_CG_results(x/(2*pi*delta_TE*CF)*1e6.*Mask);%add by Shuai for save data
        end
        
        res_norm_ratio = Inf;
        cost_data_history = zeros(1,max_iter);
        cost_reg_history = zeros(1,max_iter);
        
        e=0.000001; %a very small number to avoid /0
        badpoint = zeros(matrix_size);
        Dconv = @(dx) real(ifftn(D.*fftn(dx)));
        while (res_norm_ratio>tol_norm_ratio)&&(iter<max_iter)
            tic
            iter=iter+1;
                       
            regGm_sum = @(dx) div(wGm.*( (1./sqrt(abs(wGm.*grad(real(x(:,:,:,1)+x(:,:,:,2)),voxel_size)).^2+e)).*(wGm.*grad(real(dx),voxel_size))),voxel_size);
            regGr_pos = @(dx) div(wGr.*( (1./sqrt(abs(wGr.*grad(real(x(:,:,:,1)),voxel_size)).^2+e)).*(wGr.*grad(real(dx),voxel_size))),voxel_size);
            regGr_neg = @(dx) div(wGr.*( (1./sqrt(abs(wGr.*grad(real(x(:,:,:,2)),voxel_size)).^2+e)).*(wGr.*grad(real(dx),voxel_size))),voxel_size);
            pconv = Dconv(x(:,:,:,1));
            nconv = Dconv(x(:,:,:,2));
            b0 = br-Ap.*x(:,:,:,1)+Am.*x(:,:,:,2)+bf-(1i)*mf.*pconv-(1i)*mf.*nconv;
            b1 = -2*Ap.*b0-2*(-1i)*Dconv(mf.*b0);
            b2 =  2*Am.*b0-2*(-1i)*Dconv(mf.*b0);
           
            r1 = 2*regGm_sum(x(:,:,:,1)+x(:,:,:,2))+regGr_pos(x(:,:,:,1));
            r2 = 2*regGm_sum(x(:,:,:,1)+x(:,:,:,2))+regGr_neg(x(:,:,:,2));

                       
            A1 = @(dx) 2*(Ap.*Ap.*dx(:,:,:,1) + (1i)*Ap.*mf.*Dconv(dx(:,:,:,1)) + (-1i)*Dconv(mf.*Ap.*dx(:,:,:,1))+...
                          (-1i)*Dconv(mf.*(1i).*mf.*Dconv(dx(:,:,:,1)))) -...
                       2*(Ap.*Am.*dx(:,:,:,2) - (1i)*Ap.*mf.*Dconv(dx(:,:,:,2)) + (-1i)*Dconv(mf.*Am.*dx(:,:,:,2))-...
                          (-1i)*Dconv(mf.*(1i).*mf.*Dconv(dx(:,:,:,2))));                   
                                           
                      
            A2 = @(dx) -2*(Am.*Ap.*dx(:,:,:,1) + (1i)*Am.*mf.*Dconv(dx(:,:,:,1)) - (-1i)*Dconv(mf.*Ap.*dx(:,:,:,1))-...
                          (-1i)*Dconv(mf.*(1i).*mf.*Dconv(dx(:,:,:,1)))) +...
                        2*(Am.*Am.*dx(:,:,:,2) - (1i)*Am.*mf.*Dconv(dx(:,:,:,2)) - (-1i)*Dconv(mf.*Am.*dx(:,:,:,2))+...
                          (-1i)*Dconv(mf.*(1i).*mf.*Dconv(dx(:,:,:,2))));
                      
                      
                      
            rA1 = @(dx) 2*regGm_sum(dx(:,:,:,1)) + regGr_pos(dx(:,:,:,1)) + 2*regGm_sum(dx(:,:,:,2));
            rA2 = @(dx) 2*regGm_sum(dx(:,:,:,2)) + regGr_neg(dx(:,:,:,2)) + 2*regGm_sum(dx(:,:,:,1));
           
              if flag_CSF
                 LT_reg = @(x) Mask_CSF.*(x - mean(x(Mask_CSF)));
                 reg_CSF = @(dx) lam_CSF.*LT_reg(LT_reg(real(dx)));
                 r1 = r1 + reg_CSF(x(:,:,:,1));
                 r2 = r2 + reg_CSF(x(:,:,:,2));
                 rA1 = @(dx) rA1(dx) + reg_CSF(dx(:,:,:,1));
                 rA2 = @(dx) rA2(dx) + reg_CSF(dx(:,:,:,2));
              end
              
            bb = cat(4,lambda*b1+r1,lambda*b2+r2);
            AA = @(dx) cat(4,lambda*A1(dx)+rA1(dx), lambda*A2(dx)+rA2(dx));
            
            dx = real(cgsolve(AA, -bb, cg_tol, cg_max_iter, 0));
            upd = (dx(:,:,:,1)+dx(:,:,:,2));
            old = (x(:,:,:,1)+x(:,:,:,2));
            res_norm_ratio = norm(upd(:).*Mask(:))/norm(old(:).*Mask(:));
            x = x + dx;
            xp = x(:,:,:,1);
            xp(xp<0) = 0;
            xn = x(:,:,:,2);
            xn(xn>0) = 0;
            x = cat(4,xp,xn);
            
            
%             wres=m.*exp(1i*(real(ifftn(D.*fftn(x))))) - b0;
%             
%             cost_data_history(iter) = norm(wres(:),2);
%             cost=abs(wG.*grad(x));
%             cost_reg_history(iter) = sum(cost(:));
%             
%             
%             if merit
%                 wres = wres - mean(wres(Mask(:)==1));
%                 a = wres(Mask(:)==1);
%                 factor = std(abs(a))*6;
%                 wres = abs(wres)/factor;
%                 wres(wres<1) = 1;
%                 badpoint(wres>1)=1;
%                  N_std(Mask==1) = N_std(Mask==1).*wres(Mask==1).^2;
%                 tempn = double(N_std);
%                 if (smv)
%                     tempn = sqrt(SMV(tempn.^2, SphereK)+tempn.^2);
%                 end
%                 m = dataterm_mask(data_weighting_mode, tempn, Mask);
%                 b0 = m.*exp(1i*RDF);
%             end
            
            %fprintf('iter: %d; res_norm_ratio:%8.4f; cost_L2:%8.4f; cost:%8.4f.\n',iter, res_norm_ratio);%,cost_data_history(iter), cost_reg_history(iter));
            fprintf('iter: %d; res_norm_ratio:%8.4f;',iter, res_norm_ratio);%,cost_data_history(iter), cost_reg_history(iter));
            toc
            
            
        end
        
        
        
        %convert x to ppm
        x = x/(2*pi*delta_TE*CF)*1e6.*Mask;
        
        %Zero reference using CSF
        if flag_CSF
            %x = x - mean(x(Mask_CSF));
            xp = x(:,:,:,1);
            xp = xp - mean(xp(Mask_CSF));
            xp(xp<0) = 0;
            xn = x(:,:,:,2);
            xn = xn - mean(xn(Mask_CSF));
            xn(xn>0) = 0;
            x = cat(4,xp,xn);
            
        end
        x = x.*cat(4,Mask,Mask);
%         
%         if (matrix_size0)
%             x = x(1:matrix_size0(1), 1:matrix_size0(2), 1:matrix_size0(3));
%             iMag = iMag(1:matrix_size0(1), 1:matrix_size0(2), 1:matrix_size0(3));
%             RDF = RDF(1:matrix_size0(1), 1:matrix_size0(2), 1:matrix_size0(3));
%             Mask = Mask(1:matrix_size0(1), 1:matrix_size0(2), 1:matrix_size0(3));
%             matrix_size = matrix_size0;
%         end
        save res.mat x
%         resultsfile = store_QSM_results(x, iMag, RDF, Mask,...
%             'Norm', 'L1','Method','MEDIN','Lambda',lambda,...
%             'SMV',smv,'Radius',radius,'IRLS',merit,...
%             'voxel_size',voxel_size,'matrix_size',matrix_size,...
%             'Data_weighting_mode',data_weighting_mode,'Gradient_weighting_mode',gradient_weighting_mode,...
%             'L1_tol_ratio',tol_norm_ratio, 'Niter',iter,...
%             'CG_tol',cg_tol,'CG_max_iter',cg_max_iter,...
%             'B0_dir', B0_dir);
        
    end
end





              
