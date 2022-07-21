%% function [thre_tkd,b0dir] = parse_varargin_TKD(arg)
%
% Description: parser for qsmTKD.m
%
% Kwok-shing Chan @ DCCN
% k.chan@donders.ru.nl
% Date created: 6 September 2017
% Date last modified: 27 Feb 2020 (v0.8.0)
%
function [thre_tkd,b0dir] = parse_varargin_TKD(arg)

% predefine parameters
thre_tkd    = 0.15;
b0dir       = [0,0,1];

% use user defined input if any
if ~isempty(arg)
    for kvar = 1:length(arg)
        if strcmpi(arg{kvar},'threshold')
            thre_tkd = arg{kvar+1};
        end
        if strcmpi(arg{kvar},'b0dir')
            b0dir = arg{kvar+1};
        end
    end
end

end