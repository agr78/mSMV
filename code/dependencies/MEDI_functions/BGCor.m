%% Background Gradient for R2s correction
%  input:
%  BDF: background dipole field, [Hz] .* delta_TE, BDF = gamma.*B_b.*delta_TE
%  voxel_size: from DICOM, mm-by-mm-by-mm
%  TE: multi-echo TE train, msec
%
%  output:
%  Mag_megre: background gradient corrected magnitude for multi-GRE




function mgre = BGCor(iField, BDF, TE)

sz = size(iField);
Mag = abs(iField);
Phase = angle(iField);
dTE = mean(diff(TE));
TEs = repmat(reshape(TE,1,1,1,numel(TE)), [sz(1) sz(2) sz(3) 1]);

[ax, ay, az] = gradient(BDF);
ax = repmat(abs(ax), [1 1 1 sz(end)]);
ay = repmat(abs(ay), [1 1 1 sz(end)]);
az = repmat(abs(az), [1 1 1 sz(end)]);

gm = 2*dTE*pi./TE;
Gmax = repmat(reshape(gm,1,1,1,numel(gm)), [sz(1) sz(2) sz(3) 1]);
% ax(ax>=Gmax.*0.8) = Gmax(ax>=Gmax.*0.8).*0.8;
% ay(ay>=Gmax.*0.8) = Gmax(ay>=Gmax.*0.8).*0.8;
% az(az>=Gmax.*0.6) = Gmax(az>=Gmax.*0.6).*0.6;

sincx = sinc(ax.*TEs./(2*dTE*pi));
sincy = sinc(ay.*TEs./(2*dTE*pi));
sincz = sinc(az.*TEs./(2*dTE*pi));

Mag_mgre = Mag./abs(sincx.*sincy.*sincz);
mgre_real = Mag_mgre.*cos(Phase);
mgre_img = Mag_mgre.*sin(Phase);
mgre = mgre_real + 1i.*mgre_img;

end