function Ml = msmv(in_file,out_file);
    % Load local field
    load(in_file)
    radius = 5;
    matrix_size = size(RDF);
    RDF_s0 = Mask.*(RDF-SMV(RDF,matrix_size,voxel_size,radius));
    M_SMVe = MaskErode(Mask,matrix_size,voxel_size,radius);
    H = fspecial3('laplacian');
    L = imfilter(RDF-RDF_s0,H);
    Ml = (Mask-MaskErode(Mask,matrix_size,voxel_size,radius)).*abs(L) > mean(abs(L(M_SMVe>0)));
    Mlc = Mask.*~Ml;

     if ~contains(in_file,'sim')
        % Vessel filter
        filt = abs(RDF-SMV(RDF,matrix_size,voxel_size,1));
        Mv = imbinarize(filt,std(filt(:))); 
        
        % Preserve the vessels that extend to the edge
        Ml = Ml == 1 & Mv == 0;
        disp('Applying vessel mask')
    end
    pne = prctile(abs(RDF_s0(Mlc==1)),75);
    RDF_s0(Ml == 1) = rescale(RDF_s0(Ml == 1),...
    -pne,pne,...
    "InputMax",max(RDF_s0(Ml == 1)),"InputMin",...
    min(RDF_s0(Ml == 1)));

    RDF = RDF_s0;
    save(out_file,'B0_dir','CF','delta_TE','iFreq', 'iFreq_raw', 'iMag',...
    'Mask', 'Mask_CSF', 'matrix_size', 'N_std', 'RDF', 'voxel_size');
end