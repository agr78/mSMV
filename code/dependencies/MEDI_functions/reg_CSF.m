function reg = reg_CSF(opts)
if isempty(opts.Mask_CSF)
    error(['Error please save Mask_CSF into ' opts.filename '.']);
end
LT_reg = @(x) opts.Mask_CSF.*(x - mean(x(opts.Mask_CSF)));
norm2 = @(x) sum(abs(x(:)).^2);
reg.lambda = opts.lam_CSF/2;
reg.cost = @(x) reg.lambda*norm2(LT_reg(x));
reg.op = @(x) LT_reg(dx);
reg.opH = @(y) 2*reg.lambda*LT_reg(y);
reg.opHop = @(x) 2*reg.lambda*LT_reg(LT_reg(x));
end

