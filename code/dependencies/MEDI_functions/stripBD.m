% stripBD.m
% strip off boundary layer of a binary mask

function [u] = stripBD(mask,n)

if (nargin < 2)
    n = 1;
end

u = mask;

for i = 1:n
    bw = bwperim(u);
    u = xor(bw, u);
end

end
