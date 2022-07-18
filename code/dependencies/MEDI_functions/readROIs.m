function rois = readROIs(filename)
labelfile=strcat(filename,'.label');
fid=fopen(labelfile, 'r');
if fid
%     labels = textscan(fid,'%d %d %d %d %d %d %d %s');
    line = textscan(fid,'%s %s',...
        'CommentStyle','#','Delimiter','"');
    fclose(fid);
    labels=line{2};
    idx=[];
    for j=1:length(line{1})
        tmp = textscan(line{1}{j}, '%d');
        idx(j,1)=tmp{1}(1);
    end
    labels=labels(find(idx)); % remove zero index
    idx=idx(find(idx));
else
    error(['Unable to open ' labelfile]);
end
rois.idx = idx;
rois.label = labels;
niifile=strcat(filename,'.nii.gz');
nii=load_nii_gz(niifile);
rois.img = double(nii.img(end:-1:1,end:-1:1,:));
end

