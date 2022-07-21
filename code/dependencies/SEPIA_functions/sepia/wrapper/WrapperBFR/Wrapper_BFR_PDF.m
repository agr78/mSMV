%% [RDF] = Wrapper_BFR_PDF(totalField,mask,matrixSize,voxelSize,algorParam, headerAndExtraData)
%
% Input
% --------------
% totalField    : total field map (background + tissue fields), in Hz
% mask          : signal mask
% matrixSize    : size of the input image
% voxelSize     : spatial resolution of each dimension of the data, in mm
% algorParam    : structure contains fields with algorithm-specific parameter(s)
% headerAndExtraData : structure contains extra header info/data for the algorithm
%
% Output
% --------------
% RDF           : local field map
%
% Description: This is a wrapper function to access PDF for SEPIA
%
% Kwok-shing Chan @ DCCN
% k.chan@donders.ru.nl
% Date created: 8 March 2020 (v0.8.0)
% Date modified: 13 August 2021 (v1.0)
%
%
function [RDF] = Wrapper_BFR_PDF(totalField,mask,matrixSize,voxelSize,algorParam, headerAndExtraData)
sepia_universal_variables;

% get algorithm parameters
algorParam  = check_and_set_algorithm_default(algorParam);
method      = algorParam.bfr.method;
tol         = algorParam.bfr.tol;
iteration  	= algorParam.bfr.iteration;
padSize   	= algorParam.bfr.padSize;

% get extra data such as magnitude/weights/B0 direction/TE/etc.
headerAndExtraData = check_and_set_SEPIA_header_data(headerAndExtraData);
B0_dir  = headerAndExtraData.sepia_header.B0_dir;
N_std   = get_variable_from_headerAndExtraData(headerAndExtraData, 'fieldmapSD', matrixSize);

% if no fieldmapSD variable provided in any formats
if isempty(N_std)
    N_std = ones(matrixSize)*1e-4;
end

% add path
sepia_addpath('MEDI');

%% Display algorithm parameters
disp('The following parameters are being used...');
disp(['Tolerance            = ' num2str(tol)]);
disp(['Maximum iterations   = ' num2str(iteration)]);
disp(['Pad size             = ' num2str(padSize)]);
%         disp(['CGsolver = ' num2str(CGdefault)]);

%% main
%         RDF = PDF(totalField,mask,matrixSize,voxelSize,'b0dir',B0_dir,...
%             'tol', tol,'iteration', iteration,'CGsolver', CGdefault,'noisestd',N_std);
RDF = PDF(totalField,N_std,mask,matrixSize,voxelSize,B0_dir,tol,...
    iteration,'imagespace',padSize);
       
end

%% set default parameter if not specified
function algorParam2 = check_and_set_algorithm_default(algorParam)

algorParam2 = algorParam;

try algorParam2.bfr.tol         = algorParam.bfr.tol;       catch; algorParam2.bfr.tol      = 0.1;  end
try algorParam2.bfr.iteration   = algorParam.bfr.iteration; catch; algorParam2.bfr.iteration= 30;   end
try algorParam2.bfr.padSize     = algorParam.bfr.padSize;   catch; algorParam2.bfr.padSize  = 40;   end

end