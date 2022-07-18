function Mask_p = percentile_mask(Mask,V,p)
    V = Mask.*V;
    P = prctile(V(:),p);
    Mask_p = Mask.*imbinarize(V,P);
end