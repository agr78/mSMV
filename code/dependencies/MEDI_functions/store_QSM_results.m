% An interal function to parse input arguments for MEDI_L1
%   Save the results in a certain folder
%   Default folder is ./results/
%   Adapted from Ildar Khalidov
%   Modified by Tian Liu on 2011.02.02
%   Last modified by Tian Liu on 2013.07.24


function resultsfile = store_QSM_results(varargin )
[QSM, summary, iMag, RDF, Mask, resultsdir] = parse_input(varargin{:});

if exist(resultsdir,'dir') == 0
    mkdir(resultsdir);
end

fileno=getnextfileno(resultsdir,'x','.mat');
resultsfile=strcat(fullfile(resultsdir, 'x'),sprintf('%08u',fileno), '.mat');
save(resultsfile, 'QSM', 'summary','iMag','RDF','Mask');
end

function [QSM, summary, iMag, RDF, Mask, resultsdir] = parse_input(varargin)
QSM = varargin{1};
iMag = varargin{2};
RDF = varargin{3};
Mask = varargin{4};
summary = cell2struct(varargin(6:2:end),varargin(5:2:end),2 );
if isfield(summary, 'resultsdir')
    resultsdir=summary.resultsdir;
    summary=rmfield(summary, 'resultsdir');
else
    resultsdir=fullfile(pwd, 'results');
end
end
