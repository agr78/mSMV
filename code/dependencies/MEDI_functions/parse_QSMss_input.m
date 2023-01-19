% An interal function to parse input arguments for MEDI_L1
%   Created by Tian Liu on 2011.03.16
%   Modified by Tian Liu and Shuai Wang on 2011.03.15
%   Last modified by Tian Liu on 2013.07.24

function [lam, iFreq, RDF, N_std, iMag, Mask, matrix_size, matrix_size0, voxel_size, ...
    delta_TE, CF, B0_dir, merit, smv, radius, data_weighting, gradient_weighting, ... 
    Debug_Mode, lam_CSF, Mask_CSF, alpha, beta, R2p, chi_n_init, chi_p_init, solver, percentage] = parse_QSMss_input(varargin)

merit = 1;
smv = 1;
lam = 1000;
radius = 5;
data_weighting = 1;
gradient_weighting = 1;
pad = 0;
matrix_size0 = 0;
Debug_Mode = 'NoDebug';
solver='gaussnewton';
% CSF regularization
lam_CSF = 100;
filename = ['RDF.mat'];
percentage = 0.9;
if size(varargin,2)>0
    for k=1:size(varargin,2)
        if strcmpi(varargin{k},'filename')
            filename=varargin{k+1};
        end
        if strcmpi(varargin{k},'lambda')
            lam=varargin{k+1};
        end
        if strcmpi(varargin{k},'data_weighting')
            data_weighting=varargin{k+1};
        end
        if strcmpi(varargin{k},'gradient_weighting')
            gradient_weighting=varargin{k+1};
        end
        if strcmpi(varargin{k},'merit')
            merit=1;
        end
        if strcmpi(varargin{k},'nomerit')
            merit=0;
        end
        if strcmpi(varargin{k},'smv')
            smv = 1;
            radius = varargin{k+1};
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
        if strcmpi(varargin{k},'solver')
            solver=varargin{k+1};
        end
        if strcmpi(varargin{k},'percentage')
            percentage = varargin{k+1};
        end
    end
end

load(filename,'iFreq','RDF', 'N_std', 'iMag', 'Mask', 'matrix_size', 'voxel_size', 'delta_TE' ,'CF', 'B0_dir','alpha','beta','R2p','chi_p_init','chi_n_init');
% CSF regularization
if ismember('Mask_CSF', who('-file', filename))
    Mask_CSF = logical(getfield(load(filename, 'Mask_CSF'), 'Mask_CSF'));
else
    Mask_CSF = [];
end

if exist('delta_TE','var')==0
    delta_TE = input('TE spacing = ');
    save(filename,'delta_TE','-append');
end

if exist('CF','var')==0
    CF = input('Central Frequency = ');
    save(filename,'CF','-append');
end

if exist('B0_dir','var')==0
    B0_dir = input('B0 direction = ');
    save(filename,'B0_dir','-append');
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
