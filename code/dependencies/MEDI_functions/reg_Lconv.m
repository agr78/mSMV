function reg = reg_Lconv(opts)
if isempty(opts.R2s)
    error(['Error please save R2s into ' opts.filename '.']);
end
[LMask, K] = SMV(opts.R2s,opts.matrix_size,opts.voxel_size, opts.Lradius);
Lconv = @(dx) SMV(dx, K);
LMask = opts.Mask.*(exp(-abs(opts.Lkappa*LMask)));
norm2 = @(x) sum(abs(x(:)).^2);
reg.lambda = opts.Lalpha;
reg.cost = @(x) norm2(LMask.*Lconv(x));
reg.op = @(x) LMask.*Lconv(dx);
reg.opH = @(y) 2*reg.lambda*Lconv(LMask.*y);
reg.opHop = @(x) 2*reg.lambda*Lconv(LMask.^2.*Lconv(x));

end

