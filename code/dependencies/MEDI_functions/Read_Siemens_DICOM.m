function [iField,voxel_size,matrix_size,CF,delta_TE,TE,B0_dir,files]=Read_Siemens_DICOM(DicomFolder)

filelist = dir(DicomFolder);
i=1;
while i<=length(filelist)
    if filelist(i).isdir==1
        filelist = filelist([1:i-1 i+1:end]);   % eliminate folders
    else
        i=i+1;
    end
end

fnTemp = [DicomFolder '/' filelist(1).name];

info = dicominfo(fnTemp);
matrix_size(1) = single(info.Width);
matrix_size(2) = single(info.Height);

matrix_size(3) = 1;

NumEcho = single(info.EchoTrainLength);
voxel_size(1,1) = single(info.PixelSpacing(1));
voxel_size(2,1) = single(info.PixelSpacing(2));
voxel_size(3,1) = single(info.SliceThickness);

CF = info.ImagingFrequency *1e6;
isz=[matrix_size(1) matrix_size(2) matrix_size(3)*NumEcho];
iPhase = single(zeros(isz));
iMag = single(zeros(isz));
filesM={};
filesP={};

TE = single(zeros([NumEcho 1]));
p_ImagePositionPatient = zeros(3, matrix_size(3)*NumEcho);
m_ImagePositionPatient = zeros(3, matrix_size(3)*NumEcho);
r_EchoNumber = zeros(matrix_size(3)*NumEcho,1);
minSlice = 1e10;
maxSlice = -1e10;

% for (deidentified?) VIDA dicoms there is no longer an EchoTime field
% detecting here
filename=[DicomFolder '/' filelist(1).name];
info2 = get_dcm_tags(filename, {'EchoNumber'});
progress='';
if ~isfield(info2, 'EchoNumber')
    TE=[];
    % need to loop through all images to find the 
    % EchoTime->EchoNumber mapping
    for i = 1:length(filelist)
        for ii=1:length(progress); fprintf('\b'); end
        progress=sprintf('Collecting echo times %d', i);
        fprintf(progress);
        filename=[DicomFolder '/' filelist(i).name];
        info2 = get_dcm_tags(filename, {'EchoTime'});
        if isempty(find(TE==info2.EchoTime*1e-3))
            TE = sort([TE; info2.EchoTime*1e-3]);
        end
    end
    fprintf('\n')
    if numel(TE) ~= NumEcho
        error(['Number of echo times found (' num2str(numel(TE)) ...
               ') is different from EchoTrainLength (' num2str(NumEcho) ').']);
    end
end

rctr = 0; ictr=0;
progress='';
for i = 1:length(filelist)
    filename=[DicomFolder '/' filelist(i).name];
    info2 = get_dcm_tags(filename);
    
    if info2.SliceLocation<minSlice
        minSlice = info2.SliceLocation;
        minLoc = info2.ImagePositionPatient;
    end
    if info2.SliceLocation>maxSlice
        maxSlice = info2.SliceLocation;
        maxLoc = info2.ImagePositionPatient;
    end
    if isfield(info2, 'EchoNumber')
        if info2.EchoNumber>NumEcho
            TE = [TE; zeros([info2.EchoNumber - NumEcho 1])];
            NumEcho = info2.EchoNumber;
        end
        if TE(info2.EchoNumber)==0
            TE(info2.EchoNumber)=info2.EchoTime*1e-3;
        end
    else
        info2.EchoNumber=find(TE==info2.EchoTime*1e-3);
    end
    if (info2.ImageType(18)=='P')||(info2.ImageType(18)=='p')
        rctr = rctr + 1;
        for ii=1:length(progress); fprintf('\b'); end
        progress=sprintf('Reading file %d', rctr+ictr);
        fprintf(progress);
        p_ImagePositionPatient(:,rctr) = info2.ImagePositionPatient;
        r_EchoNumber(rctr) = info2.EchoNumber;
        ph = transpose(single(dicomread(filename)));
        iPhase(:,:,rctr)  = (ph*info2.RescaleSlope + info2.RescaleIntercept)/single(max(ph(:)))*pi;%phase
        filesP{rctr} = filename;
    elseif (info2.ImageType(18)=='M')||(info2.ImageType(18)=='m')
        ictr = ictr + 1;
        for ii=1:length(progress); fprintf('\b'); end
        progress=sprintf('Reading file %d', rctr+ictr);
        fprintf(progress);
        m_ImagePositionPatient(:,ictr) = info2.ImagePositionPatient;
        i_EchoNumber(ictr) = info2.EchoNumber;
        iMag(:,:,ictr)  = transpose(single(dicomread(filename)));%magnitude
        filesM{ictr} = filename;
    end
end
fprintf('\n');

matrix_size(3) = round(norm(maxLoc - minLoc)/voxel_size(3))+1 ;

Affine2D = reshape(info.ImageOrientationPatient,[3 2]);
Affine3D = [Affine2D (maxLoc-minLoc)/( (matrix_size(3)-1)*voxel_size(3))];
B0_dir = Affine3D\[0 0 1]';
files.Affine3D=Affine3D;
files.minLoc=minLoc;
files.maxLoc=maxLoc;
n_exp=matrix_size(3)*NumEcho;

p_sz=size(p_ImagePositionPatient); p_sz(1)=1;
p_minLoc=repmat(minLoc, p_sz);
if n_exp ~= p_sz(2)
    warning(['Number of phase images (' ... 
        num2str(p_sz(2)) ...
        ') is different from the expected number (' ...
        num2str(n_exp) ...
        ').'])
end

p_slice = int32(round(sqrt(sum((p_ImagePositionPatient-p_minLoc).^2,1))/voxel_size(3)) +1);
p_ind = sub2ind([matrix_size(3) NumEcho], p_slice(:), int32(r_EchoNumber(:)));
iPhase(:,:,p_ind) = iPhase;
files.P=cell(matrix_size(3), NumEcho);
files.P(p_ind)=filesP;
if n_exp ~= size(iPhase,3)
    iPhase = padarray(iPhase, double([0 0 n_exp-size(iPhase,3)]), 'post');
    warning(['Some phase images are missing']); 
end

m_sz=size(m_ImagePositionPatient); m_sz(1)=1;
if n_exp ~= m_sz(2)
    warning(['Number of magnitude images (' ... 
        num2str(m_sz(2)) ...
        ') is different from the expected number (' ...
        num2str(n_exp) ...
        ').'])
end
if m_sz(2) ~= p_sz(2)
    warning(['Number of phase images (' ... 
        num2str(p_sz(2)) ...
        ') is different from number of magnitude images (' ...
        num2str(m_sz(2)) ...
        ').'])
end
m_minLoc=repmat(minLoc, m_sz);

m_slice = int32(round(sqrt(sum((m_ImagePositionPatient-m_minLoc).^2,1))/voxel_size(3)) +1);
m_ind = sub2ind([matrix_size(3) NumEcho], m_slice(:), int32(i_EchoNumber(:)));
iMag(:,:,m_ind) = iMag;
files.M=cell(matrix_size(3), NumEcho);
files.M(m_ind)=filesM;
if n_exp ~= size(iMag,3)
    iMag = padarray(iMag, double([0 0 n_exp-size(iMag,3)]), 'post');
    warning(['Some magnitdue images are missing']); 
end

iField = reshape(iMag.*exp(-1i*iPhase), ...
    [matrix_size(1) matrix_size(2) matrix_size(3) NumEcho]);
% iField = permute(iField,[2 1 3 4 5]); %This is because the first dimension is row in DICOM but COLUMN in MATLAB
% iField(:,:,1:2:end,:) = -iField(:,:,1:2:end,:);
if length(TE)==1
    delta_TE = TE;
else
    delta_TE = TE(2) - TE(1);
end

end

function info = get_dcm_tags(filename, tags)
if nargin<2
    tags={'SliceLocation','ImagePositionPatient',...
        'EchoTime','EchoNumber','ImageType','RescaleSlope','RescaleIntercept'};
end
if any(ismember(tags,'EchoNumber'))
    tags=[tags(:)', {'EchoNumbers'}];
end
attrs=dicomattrs(filename);
info=struct;
for t=tags
    t=char(t);
    [gr, el] = dicomlookup(t);
    if ~strcmp(t,'ImageType')
        for i=1:length(attrs)
            if (attrs(i).Group==gr)&(attrs(i).Element==el)
                eval(['info.' t '= sscanf(char(attrs(i).Data), ''%f\\'');'])
                break;
            end
        end
    else
        for i=1:length(attrs)
            if (attrs(i).Group==gr)&(attrs(i).Element==el)
                info.ImageType = char(attrs(i).Data);
            end
        end
    end
end
if isfield(info,'EchoNumbers')
    info.EchoNumber=info.EchoNumbers;
end
end