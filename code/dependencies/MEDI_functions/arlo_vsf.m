function r2 = arlo(te,y)

nte = length(te);
if nte<2
    r2 = [];
    return
end

sz=size(y);
edx = numel(sz);
if sz(edx)~=nte
    error(['Last dimension of y has size ' num2str(sz(edx)) ...
        ', expected ' num2str(nte) ]);
end

S_sj = zeros(sz(1),sz(2),sz(3));
S_sjdj = zeros(sz(1),sz(2),sz(3));

for j=1:nte-2
    dTE = te(j+1) - te(j);
    S_sj = y(:,:,:,j).^2 + S_sj;
    dj = y(:,:,:,j) - y(:,:,:,j+2);
    S_sjdj = y(:,:,:,j).*dj + S_sjdj;
end

r2 = ((dTE/3).*S_sj+S_sjdj)./(S_sj+((dTE/3).*S_sjdj));
r2(isnan(r2)) = 0;
r2(isinf(r2)) = 0;
