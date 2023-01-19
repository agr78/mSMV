function Ml = lapmask(RDF,Mask,voxel_size,radius);
    matrix_size = size(RDF);
    RDF_s0 = Mask.*(RDF-SMV(RDF,matrix_size,voxel_size,radius));
    H = fspecial3('laplacian');
    L = imfilter(RDF,H);
    Ml = (Mask-MaskErode(Mask,matrix_size,voxel_size,radius)).*abs(L) > mean(abs(L(:)));
    Mlc = (~Ml).*(Mask-MaskErode(Mask,matrix_size,voxel_size,radius));
    pne = prctile(abs(RDF_s0(Mlc==1)),95);
    RDF_s0(Ml == 1) = rescale(RDF_s0(Ml == 1),...
    -pne,pne,...
    "InputMax",max(RDF_s0(Ml == 1)),"InputMin",...
    min(RDF_s0(Ml == 1)));
%    
%     % New
%     Mlc = Mask.*(~Ml);
%     epsilon = 0.1;
%     Ml = Ml+epsilon;
%     Mlc = Mlc+epsilon;
%     AHA = @(dx) conj(RDF_s0).*Ml.*Ml.*RDF_s0.*dx;
%     AHb = conj(RDF_s0).*Ml.*Mlc.*RDF_s0;
%     dx = cgsolve(AHA,AHb,1e-16,100,1);
%     RDF_s = Mlc.*RDF_s0+Ml.*dx.*Mlc;

end