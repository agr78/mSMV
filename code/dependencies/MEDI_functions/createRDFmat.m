function createRDFmat(RDFfile, varargin)
%CREATERDFMAT Summary of this function goes here
%   Detailed explanation goes here
saveArgs={};
if 0==nargin
    RDFfile='RDF.mat';
end
if size(varargin,2)>0
    k=1;
    while(k<=size(varargin,2))
        if ischar(varargin{k})
            if strcmp(varargin{k}(1), '-')
                % this is an option for save
                saveArgs={saveArgs{:}, varargin{k}};
            else                
                eval([ varargin{k} ' = varargin{k+1};']);
                saveArgs={saveArgs{:}, varargin{k}};
                disp(['Using provided ' varargin{k} '.'])
                k=k+1;
            end
        else
            disp(['Ignoring argument ' num2str(k)])
        end
        k=k+1;
    end
end
varMandatory={'RDF','iFreq','iFreq_raw','iMag','N_std','Mask','matrix_size',...
     'voxel_size','delta_TE','CF','B0_dir','files'};
varOptional={'Mask_CSF'};

varMandatory=setdiff(varMandatory, saveArgs,'stable'); 
varOptional=setdiff(varOptional, saveArgs,'stable');

for v=varMandatory
    v=v{:};
    if 1~=exist(v)
        try
            eval([ v '= evalin(''caller'',''' v ''');']);
            saveArgs={saveArgs{:}, v};
        catch
            error(['Variable ' v ' not defined.']);
        end
        
    end
end
for v=varOptional
    v=v{:};
    if 1~=exist(v)
        try
            eval([ v '= evalin(''caller'',''' v ''');']);
            saveArgs={saveArgs{:}, v};
        catch
            warning(['Variable ' v ' not defined.']);
        end
    end
end
disp(['Saving ' RDFfile '.']);
eval(['save(''' RDFfile ''', saveArgs{:} );']);

end

