function iField_pad = auto_pad(iField)
    [r,c,d,t] = size(iField);
    s = sort([r,c,d]);
    h = s(3); m = s(2); l = s(1);
    pad_dim = max([h,m,l]);
    pad_m = round((pad_dim-m)/2);
    I1 = [1 0 0];
    I2 = [0 1 0];
    if size(iField,1) < size(iField,2)
        I = I1;
    else
        I = I2;
    end
    iField_pad = padarray(iField,pad_m.*I,"symmetric","both");
    if size(iField_pad,1) ~= size(iField_pad,2)
        if size(iField_pad,1) < size(iField_pad,2)
            I = I2;
        else
            I = I1;
        end
        iField_pad = padarray(iField_pad,1.*I,"replicate","post");
    else
    end
end