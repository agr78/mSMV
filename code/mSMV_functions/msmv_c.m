function [RDF_s,RDF_s0] = msmv(in_file,out_file);
    load(in_file)
    radius = 5;
    matrix_size = size(RDF);
    RDF_s0 = Mask.*(RDF-SMV(RDF,matrix_size,voxel_size,radius));
    H = fspecial3('laplacian');
    L = imfilter(RDF,H);
    Ml = (Mask-MaskErode(Mask,matrix_size,voxel_size,radius)).*abs(L) > mean(abs(L(:)));
   
    % New
    Mlc = Mask.*(~Ml);
    epsilon = 0.1;
    Ml = Ml+epsilon;
    Mlc = Mlc+epsilon;
    AHA = @(dx) conj(RDF_s0).*Ml.*Ml.*RDF_s0.*dx;
    AHb = conj(RDF_s0).*Ml.*Mlc.*RDF_s0;
    dx = cgsolve(AHA,AHb,1e-16,100,1);
    RDF_s = Mlc.*RDF_s0+Ml.*dx.*Mlc;
    RDF = Mask.*RDF_s;
    save(out_file,'B0_dir','CF','delta_TE','iFreq', 'iFreq_raw', 'iMag',...
    'Mask', 'Mask_CSF', 'matrix_size', 'N_std', 'RDF', 'voxel_size');
end