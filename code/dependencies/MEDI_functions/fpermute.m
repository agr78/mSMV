
function out = fpermute( in, dims)
%RPERM Summary of this function goes here
%   Detailed explanation goes here
out=permute(in, abs(dims));
for i=1:length(dims)
    if(dims(i)<0) out=flipdim(out,i); 
    end
end
 
end
