% An interal function to parse input arguments for MEDI_L1
%   Created by Tian Liu on 2011.03.16
%   Modified by Tian Liu and Shuai Wang on 2011.03.15
%   Last modified by Tian Liu on 2013.07.24
%   Last modified by Alexandra Roberts on 2023.27.12

function [lam, iFreq, RDF, N_std, iMag, Mask, matrix_size, matrix_size0, voxel_size, ...
    delta_TE, CF, B0_dir, merit, smv, radius, data_weighting, gradient_weighting, ... 
    Debug_Mode, lam_CSF, Mask_CSF, opts] = parse_QSM_input(varargin)

merit = 1;
smv = 1;
msmv = 0;
lam = 1000;
radius = 5;
data_weighting = 1;
gradient_weighting = 1;
pad = 0;
matrix_size0 = 0;
Debug_Mode = 'NoDebug';
% CSF regularization
lam_CSF = 100;

opts = struct;
opts.filename = ['RDF.mat'];
opts.solver='gaussnewton';
opts.percentage = 0.9;
opts.linear = false;    
opts.Lalpha = 100;
opts.Lkappa = 0.1;
opts.Lradius = 1;
opts.Lreg = 0;
opts.cg_verbose = 0;
opts.cg_max_iter = 100;
opts.cg_tol = 0.01;
opts.max_iter = 10;
opts.tol_norm_ratio = 0.1;
opts.regs = struct;
opts.smv_shrink_mask = 1;
opts.resultsdir = fullfile(pwd, 'results');

if size(varargin,2)>0
    for k = 1:size(varargin,2)
        if strcmpi(varargin{k},'lambda')
            lam = varargin{k+1};
        end
        if strcmpi(varargin{k},'data_weighting')
            data_weighting = varargin{k+1};
        end
        if strcmpi(varargin{k},'gradient_weighting')
            gradient_weighting = varargin{k+1};
        end
        if strcmpi(varargin{k},'merit')
            merit = 1;
        end
        if strcmpi(varargin{k},'nomerit')
            merit = 0;
        end
        if strcmpi(varargin{k},'smv') || strcmpi(varargin{k},'msmv')
            smv = 1;
            msmv = strcmpi(varargin{k},'msmv');
            if length(varargin)>k
                radius = varargin{k+1};
                if msmv
                    str = 'mSMV'; 
                else
                    str = 'SMV';
                    msmv = 0;
                end
                fprintf('Using %s with radius %s\n',str,string(radius))
            end
        end
        if strcmpi(varargin{k},'nosmv')
            smv = 0;
        end
        if strcmpi(varargin{k},'zeropad')
            pad = varargin{k+1};
        end
        if strcmpi(varargin{k},'DEBUG')
            Debug_Mode = varargin{k+1};
        end
        if strcmpi(varargin{k},'lambda_CSF')
            lam_CSF = varargin{k+1};
        end
        fn=fieldnames(opts);
        for j=1:length(fn)
            if strcmpi(varargin{k},fn{j})
                opts.(fn{j}) = varargin{k+1};
            end
        end
    end
end

load(opts.filename,'iFreq','RDF', 'N_std', 'iMag', 'Mask', 'matrix_size', 'voxel_size', 'delta_TE' ,'CF', 'B0_dir');
opts.matrix_size = matrix_size;
opts.voxel_size = voxel_size;
opts.lam_CSF = lam_CSF;
opts.Mask = Mask;
opts.msmv = msmv;
if msmv
    opts.smv_shrink_mask = 0; 
end

% CSF regularization
if ismember('Mask_CSF', who('-file', opts.filename))
    Mask_CSF = logical(getfield(load(opts.filename, 'Mask_CSF'), 'Mask_CSF'));
else
    Mask_CSF = [];
end
opts.Mask_CSF = Mask_CSF;

if ismember('weightS', who('-file', opts.filename))
    opts.weightS = getfield(load(opts.filename, 'weightS'), 'weightS');
else
    opts.weightS = [];
end

if exist('delta_TE','var') == 0
    delta_TE = input('TE spacing = ');
    save(opts.filename,'delta_TE','-append');
end

if exist('CF','var') == 0
    CF = input('Central Frequency = ');
    save(opts.filename,'CF','-append');
end

if exist('B0_dir','var') == 0
    B0_dir = input('B0 direction = ');
    save(opts.filename,'B0_dir','-append');
end

% Preconditioner
if ismember('P', who('-file', opts.filename))
    opts.P = getfield(load(opts.filename, 'P'), 'P');
else
    opts.P = 1;
end

% R2s
if ismember('R2s', who('-file', opts.filename))
    opts.R2s = getfield(load(opts.filename, 'R2s'), 'R2s');
else
    opts.R2s = [];
end

if sum(pad(:))
    matrix_size0 = matrix_size;
    matrix_size = matrix_size + pad;
    iFreq = padarray(iFreq, pad,'post');
    RDF = padarray(RDF, pad,'post');
    N_std = padarray(N_std, pad,'post');
    iMag = padarray(iMag, pad,'post');
    Mask = padarray(Mask, pad,'post');

    % CSF regularization
    if ~isempty(Mask_CSF)
        Mask_CSF = padarray(Mask_CSF, pad,'post');
    end
end

end
