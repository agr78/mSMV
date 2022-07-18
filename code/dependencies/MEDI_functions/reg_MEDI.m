function reg = reg_MEDI(param, x, PHP)
e=0.000001; %a very small number to avoid /0
% e = e.*(2*pi*param.delta_TE*single(param.CF)/single(1e6))^2;  % Rescale epsilon
% fprintf('Epsilon scaled with P\n');
e = e*PHP(ones(param.matrix_size));
Vr = 1./sqrt(abs(param.wG.*param.grad(real(x),param.voxel_size)).^2+e);
norm1 = @(x) sum(abs(x(:)));
reg.lambda = 1;
reg.cost = @(x) norm1(param.wG.*param.grad(x));
reg.op = @(x) sqrt(Vr).*param.wG.*param.grad(real(x),param.voxel_size);
reg.opH = @(y) param.div(param.wG.*(sqrt(Vr).*y),param.voxel_size);
reg.opHop = @(x) reg.lambda*param.div(param.wG.*Vr.*param.wG.*param.grad(real(x),param.voxel_size),param.voxel_size);
end

