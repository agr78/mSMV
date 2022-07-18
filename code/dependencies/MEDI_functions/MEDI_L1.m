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

function [x, cost_reg_history, cost_data_history, resultsfile] = MEDI_L1(varargin)

[lambda, ~, RDF, N_std, iMag, Mask, matrix_size, matrix_size0, voxel_size, ...
    delta_TE, CF, B0_dir, merit, smv, radius, data_weighting, gradient_weighting, ...
    Debug_Mode, lam_CSF, Mask_CSF, opts] = parse_QSM_input(varargin{:});

%%%%%%%%%%%%%%% weights definition %%%%%%%%%%%%%%

data_weighting_mode = data_weighting;
gradient_weighting_mode = gradient_weighting;
opts.grad = @fgrad;
opts.div = @bdiv;
opts.B0_dir = B0_dir;

N_std = N_std.*Mask;
tempn = single(N_std);
D=dipole_kernel(matrix_size, voxel_size, B0_dir);

if (smv)
%     S = SMV_kernel(matrix_size, voxel_size,radius);
    SphereK = single(sphere_kernel(matrix_size, voxel_size,radius));
    if opts.smv_shrink_mask
        Mask = SMV(Mask, SphereK)>0.999;
    end
    D=(1-SphereK).*D;
    RDF = RDF - SMV(RDF, SphereK);
    RDF = RDF.*Mask;
    tempn = sqrt(SMV(tempn.^2, SphereK)+tempn.^2);
end
Dconv = @(dx) real(ifftn(D.*fftn(dx)));
opts.m = dataterm_mask(data_weighting_mode, tempn, Mask);
opts.wG = gradient_mask(gradient_weighting_mode, iMag, Mask, opts.grad, voxel_size, opts.percentage);


% Preconditioning
if ~isempty(findstr(upper(Debug_Mode),'NOP'))
    opts.P = 1;
end
flag_P = isstruct(opts.P) || (isnumeric(opts.P) && (numel(opts.P) ~= 1));
if flag_P
    fprintf('Preconditioning used\n');
    if isa(opts.P, 'struct')
        P=opts.P.op;
        PH=opts.P.opH;
    else
        P=@(x) opts.P.*x;
        PH=@(x) conj(opts.P).*x;
    end
    opts.wG = bsxfun(@times,opts.wG,Mask);
%     opts.cg_max_iter = 100;
%     opts.cg_tol = 0.0001;
%     opts.max_iter = 10;
%     opts.tol_norm_ratio = 0.01;
else
    P=@(x) x;
    PH=@(x) x;
end
PHP = @(x) PH(P(x));

regs=struct;
regs.WL1=struct; % do not change
for f=fieldnames(opts.regs)'
    regs.(f{:}) = opts.regs.(f{:});
end
% CSF regularization
flag_CSF = ~isempty(opts.Mask_CSF);
if flag_CSF
    fprintf('CSF regularization used\n');
    regs.CSF=reg_CSF(opts);
end
if opts.Lreg
    regs.Lconv=reg_Lconv(opts);
end

if opts.linear
    fprintf('Using linear formulation\n');
    B = @(m,RDF) m.*RDF;
    W = @(m, x)  m.*Dconv(x);
else
    B = @(m,RDF) m.*exp(1i*RDF);
    W = @(m, x)  m.*exp(1i*Dconv(x));
end
b0 = B(opts.m, RDF);

oldN_std=N_std;
fprintf(['Using ' opts.solver '\n']);
switch opts.solver
    case 'gaussnewton'
        [x, cost_reg_history, cost_data_history] = gaussnewton();
end

    function [x, cost_reg_history, cost_data_history] = gaussnewton()
        
        iter=0;
        x = zeros(matrix_size); %real(ifftn(conj(D).*fftn((abs(opts.m).^2).*RDF)));
        if (~isempty(findstr(upper(Debug_Mode),'SAVEITER')))
            store_CG_results(x/(2*pi*delta_TE*CF)*1e6.*Mask);%add by Shuai for save data
        end
        res_norm_ratio = Inf;
        cost_data_history = zeros(1,opts.max_iter);
        cost_reg_history = zeros(1,opts.max_iter);
        
        e=0.000001; %a very small number to avoid /0
%         e = e.*(2*pi*delta_TE*single(CF)/single(1e6))^2;  % Rescale epsilon
        if flag_P%~isempty(findstr(upper(Debug_Mode),'SCALEEPSP'))
            fprintf('Epsilon scaled with P\n');
            e = e*PH(P(ones(matrix_size)));
        end
        badpoint = zeros(matrix_size);
        while (res_norm_ratio>opts.tol_norm_ratio)&&(iter<opts.max_iter)
            tic
            iter=iter+1;
            w = W(opts.m, P(x));
            regs.WL1=reg_MEDI(opts, P(x), PHP);
            reg = @(dx) 0;
            for f=fieldnames(regs)'
                reg = @(dx) reg(dx) + PH(regs.(f{:}).opHop(P(real(dx))));
            end
            if opts.linear
                fidelity = @(dx) PH(Dconv(conj(opts.m).*opts.m.*Dconv(P(dx))));
                b = reg(x) + 2*lambda*PH(Dconv(real(conj(opts.m).*(w-b0))));
            else
                fidelity = @(dx) PH(Dconv(conj(w).*w.*Dconv(P(dx))));
                b = reg(x) + 2*lambda*PH(Dconv(real(conj(w).*conj(1i).*(w-b0))));
            end
            A =  @(dx) reg(dx) + 2*lambda*fidelity(dx);
            
            dx = real(cgsolve(A, -b, opts.cg_tol, opts.cg_max_iter, opts.cg_verbose));
            nrm = @(x) norm(x(:));
            res_norm_ratio = nrm(dx)/nrm(x);
            x = x + dx;
            
            wres=W(opts.m, P(x)) - b0;
            cost_data_history(iter) = norm(wres(:),2);
            if isfield(regs,'WL1')
            cost_reg_history(iter) = regs.WL1.cost(P(x));
            end
            
            if merit
                wres = wres - mean(wres(Mask(:)==1));
                a = wres(Mask(:)==1);
                factor = std(abs(a))*6;
                wres = abs(wres)/factor;
                wres(wres<1) = 1;
                badpoint(wres>1)=1;
                 N_std(Mask==1) = N_std(Mask==1).*wres(Mask==1).^2;
                tempn = double(N_std);
                if (smv)
                    tempn = sqrt(SMV(tempn.^2, SphereK)+tempn.^2);
                end
                opts.m = dataterm_mask(data_weighting_mode, tempn, Mask);
                b0 = B(opts.m, RDF);
            end
            
            fprintf('iter: %d; res_norm_ratio:%8.4f; cost_L2:%8.4f; cost:%8.4f.\n',iter, res_norm_ratio,cost_data_history(iter), cost_reg_history(iter));
            toc
            
            
        end
        
        
        
        %convert x to ppm
        x = P(x)/(2*pi*delta_TE*CF)*1e6.*Mask;
        
        % Zero reference using CSF
        if flag_CSF
            x = x - mean(x(opts.Mask_CSF));
        end
        
        if (matrix_size0)
            x = x(1:matrix_size0(1), 1:matrix_size0(2), 1:matrix_size0(3));
            iMag = iMag(1:matrix_size0(1), 1:matrix_size0(2), 1:matrix_size0(3));
            RDF = RDF(1:matrix_size0(1), 1:matrix_size0(2), 1:matrix_size0(3));
            Mask = Mask(1:matrix_size0(1), 1:matrix_size0(2), 1:matrix_size0(3));
            matrix_size = matrix_size0;
        end
        
        resultsfile = store_QSM_results(x, iMag, RDF, Mask,...
            'resultsdir', opts.resultsdir, ...
            'Norm', 'L1','Method','MEDIN','Lambda',lambda,...
            'SMV',smv,'Radius',radius,'IRLS',merit,...
            'voxel_size',voxel_size,'matrix_size',matrix_size,...
            'Data_weighting_mode',data_weighting_mode,'Gradient_weighting_mode',gradient_weighting_mode,...
            'L1_tol_ratio',opts.tol_norm_ratio, 'Niter',iter,...
            'CG_tol',opts.cg_tol,'CG_max_iter',opts.cg_max_iter,...
            'B0_dir', B0_dir);
        
    end
end





              
