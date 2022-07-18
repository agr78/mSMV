function out = apply_wl( in, window, level )

%APPLY_WL Summary of this function goes here
%   Detailed explanation goes here
m1=level-window/2;
m2=level+window/2;
out=in;
out(in(:)<m1)=m1;
out(in(:)>m2)=m2; 
%out = out/2; 
out = (out+(window/2))/window; % To fix gray background, added
                 
end