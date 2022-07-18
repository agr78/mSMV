%  Load NIFTI dataset from *nii.gz
%

function nii = load_nii_gz(filename, varargin)
tdir=tempname;
f=gunzip(filename,tdir);
nii=load_nii(f{1});
delete(f{:});
rmdir(tdir);
end

   
%  https://sourceware.org/gdb/wiki/BuildingOnDarwin

%On 10.12 (Sierra) or later with SIP, you need to run this:

% echo "set startup-with-shell off" >> ~/.gdbinit
