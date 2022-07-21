%% function [chi, lamdaOptimal] = cuQsmMacro(localField,mask,matrixSize,voxelSize,varargin)
%
% Usage: 
%       chi = qsmMacro(localField,mask,matrixSize,voxelSize,...
%               'method','TKD','threshold',0.15);
%       chi = qsmMacro(localField,mask,matrixSize,voxelSize,...
%               'method','ClosedFormL2','lambda',0.1,'optimise',false);
%       chi = qsmMacro(localField,mask,matrixSize,voxelSize,...
%               'method','iLSQR','lambda',0.1,'optimise',false,'tol',1e-3,...
%               'iteration',100,'weight',wmap,'initGuess',initGuessmap);
%       chi = qsmMacro(localField,mask,matrixSize,voxelSize,...
%               'method','STISuiteiLSQR','threshold',0.01,'iteration',100,...
%               'tol_step1',0.01,'tol_step2',0.001,'b0dir',[0,0,1],'TE',1,...
%               'B0',3,'padsize',[4,4,4]);
%       chi = qsmMacro(localField,mask,matrixSize,voxelSize,...
%               'method','FANSI','tol',1,'lambda',3e-5,'mu',5e-5,'iteration',50,'weight',wmap,...
%               'tgv','nonlinear');
%       chi = qsmMacro(totalField,mask,matrixSize,voxelSize,...
%               'method','SSVSHARP','tol',tol,'lambda',lambda,'iteration',maxiter,'magnitude',magn,...
%               'vkernel',Kernel_Sizes);
%       chi = qsmMacro(totalField,mask,matrixSize,voxelSize,...
%               'method','Star','b0dir',[0,0,1],'TE',1,'B0',3,'padsize',[4,4,4]);
%
% Description: Wrapper for QSM inversion problem (default using TKD)
%   Flags:
%       'method'        : QSM method, 
%                          'TKD', 'ClosedFormL2', 'iLSQR', 'FANSI',
%                          'ssvsharp', 'STISuiteiLSQR', 'Star'
%       'b0dir'         : B0 direction
%
%       TKD
%       ----------------
%       'threshold'     : threshold for TKD
%
%       ClosedFormL2
%       ----------------           
%       'lambda'        : regularisation value
%       'optimise'      : self-define regularisation based on curvature of 
%                         L-curve
%
%       iLSQR
%       ----------------
%       'lambda'        : regularisation value
%       'tol'           : error tolerance
%       'iteration' 	: no. of maximum iteration for iLSQR
%       'weight'    	: weighting of error computation
%       'initGuess'     : initial guess for iLSQR
%       'optimise'      : self-define regularisation based on curvature of 
%                         L-curve
%
%       STISuiteiLSQR
%       ----------------
%       'threshold'     : threshold for STISuiteiLSQR
%       'iteration' 	: no. of maximum iteration for iLSQR
%       'tol_step1'     : error tolerance
%       'tol_step2'     : error tolerance
%       'b0dir'         : main magnetic field direction
%       'TE'            : echo time
%       'fieldStrength' : magntic field strength of the scanner
%       'padsize'       : size for padarray to increase numerical accuracy
%
%       FANSI
%       ----------------
%       'lambda'        : user defined regularisation parameter for gradient L1 penalty
%       'mu'            : user defined regularisation parameter for gradient consistency 
%       'tol'           : tolerance for iteration
%       'iteration'     : maxlocalFieldimum number of iterations
%       'weight'        : weighting of error computation
%       'linear'        : linear solver
%       'nonlinear'     : nonlinear solver
%       'tgv'           : Total generalised variation constraint
%       'tv'            : Total variation constraints
%
%       Star
%       ----------------
%       'padsize'        : size for padarray to increase numerical accuracy
%
% Kwok-shing Chan @ DCCN
% k.chan@donders.ru.nl
% Date created: 20 May 2018
% Date last modified:
%
function [chi, lamdaOptimal] = cuQSMMacro(localField,mask,matrixSize,voxelSize,varargin)

g = gpuDevice(1);

lamdaOptimal = [];
localField = gpuArray(localField);
mask = gpuArray(mask);
matrixSize = gpuArray(matrixSize(:).');
voxelSize = gpuArray(voxelSize(:).');

%% Parsing argument input flags
if ~isempty(varargin)
    for kvar = 1:length(varargin)
        if strcmpi(varargin{kvar},'method')
            switch lower(varargin{kvar+1})
                case 'tkd'
                    method = 'TKD';
                    [thre_tkd,b0dir] = parse_varargin_TKD(varargin);
                    break
                case 'closedforml2'
                    method = 'CFL2';
                    [lambda,optimise,b0dir] = parse_varargin_CFL2norm(varargin);
                    break
                case 'ilsqr'
                    method = 'iLSQR';
                    [lambda, tol, maxiter, wmap, initGuess, optimise,b0dir] = parse_varargin_iLSQR(varargin);
                    if isempty(wmap)
                        wmap = ones(matrixSize);
                    end
                    if isempty(initGuess)
                        initGuess = zeros(matrixSize);
                    end
                    break
                case 'stisuiteilsqr'
                    method = 'STISuiteiLSQR';
                    algoPara = parse_varargin_STISuiteiLSQRv3(varargin);
                    algoPara.voxelsize= double(gather(voxelSize(:).'));
                    break
                case 'fansi'
                    method = 'FANSI';
                    [mu1,mu2,alpha1,tol,maxiter,wmap,solver,constraint,b0dir]=parse_varargin_FANSI(varargin);
                case 'ssvsharp'
                    method = 'SSVSHARP';
                    [lambda,magn,tol,maxiter,Kernel_Sizes,b0dir]=parse_varargin_SSQSM(varargin);
                case 'star'
                    method = 'Star';
                    [te,padSize,b0,b0dir] = parse_varargin_Star(varargin);
                case 'medi_l1'
                    method = 'MEDI_L1';
                    [N_std,magn,lambda,pad,te,CF,b0dir,isMerit,isSMV,radius,wData,wGrad,Debug_Mode,lam_CSF,Mask_CSF] = parse_varargin_MEDI_L1(varargin);
            end
        end
    end
else
    % predefine paramater: if no varargin, use TKD
    disp('No method selected. Using default setting...');
    method = 'TKD';
    thre_tkd = 0.15;
end

disp(['The following QSM algorithm will be used: ' method]);

%% qsm algorithm
switch method
    case 'TKD'
        disp(['TKD threshold = ' thre_tkd]);
        chi = qsmTKD(localField,mask,matrixSize,voxelSize,'threshold',thre_tkd,'b0dir',b0dir);
    case 'CFL2'
        [chi, lamdaOptimal] = qsmClosedFormL2(localField,mask,matrixSize,voxelSize,...
            'lambda',lambda,'optimise',optimise,'b0dir',b0dir);
    case 'iLSQR'
        chi = qsmIterativeLSQR(localField,mask,matrixSize,voxelSize,...
            'lambda',lambda,'tol',tol,'iteration',maxiter,'weight',wmap,...
            'initGuess',initGuess,'optimise',optimise,'b0dir',b0dir);
    case 'STISuiteiLSQR'
        % STI Suite iLSQR doesn't support GPU
        chi = QSM_iLSQR(double(gather(localField)),double(gather(mask)),'params',algoPara);
    case 'FANSI'
        chi = qsmFANSI(localField,mask,matrixSize,voxelSize,...
          'tol',tol,'lambda',alpha1,'mu',mu1,'mu2',mu2,'iteration',maxiter,'weight',wmap,...
          solver,constraint,'b0dir',b0dir);
    case 'SSVSHARP'
        chi = qsmSingleStepVSHARP(localField,mask,matrixSize,voxelSize,...
            'tol',tol,'lambda',lambda,'iteration',maxiter,'magnitude',magn,...
            'b0dir',b0dir,'vkernel',Kernel_Sizes);
    case 'Star'
        chi = QSM_star(localField,mask,'TE',te,'B0',b0,'H',b0dir,'padsize',padSize,'voxelsize',voxelSize);
    case 'MEDI_L1'
        chi = MEDI_L1_4qsmhub(localField,mask,matrixSize,voxelSize,...
            'lambda',lambda,'pad',pad,'TE',te,'CF',CF,'b0dir',b0dir,'merit',isMerit,...
            'smv',isSMV,'radius',radius,'data_weighting',wData,...
            'gradient_weighting',wGrad,'lam_CSF',lam_CSF,...
            'noisestd',N_std,'magnitude',magn,'Mask_CSF',Mask_CSF);
end

chi = gather(chi);

reset(g);

end
