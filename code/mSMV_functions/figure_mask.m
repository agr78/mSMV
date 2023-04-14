function fMask = figure_mask(Mask,c)

    fMask = ~Mask.*((~Mask)-c);

end