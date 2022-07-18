function varargout = vis(varargin)
% VIS M-file for Vis.fig
%      VIS, by itself, creates a new VIS or raises the existing
%      singleton*.
%
%      H = VIS returns the handle to a new VIS or the handle to
%      the existing singleton*.
%
%      VIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIS.M with the given input arguments.
%
%      VIS('Property','Value',...) creates a new VIS or raises the
%      existing singleton*.  Starting from the left, property value pairs
%      are
%      applied to the GUI before Vis_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Vis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Vis

% Last Modified by GUIDE v2.5 31-Jul-2019 15:28:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Vis_OpeningFcn, ...
                   'gui_OutputFcn',  @Vis_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Vis is made visible.
function Vis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Vis (see VARARGIN)

% Choose default command line output for Vis
handles.output = hObject;

    handles.img=varargin{1};

handles.voxelsize = [1 1 1 1];
handles.title = 'VIS';
handles.roilist = {};
handles.roicallback = -1;
handles.roi_data_file = 'roi_data.mat';
handles.colormap='';
handles.truecolor=0;
handles.curslice=1;
handles.curcoil=1;
windowlevel_mode='auto';
cpart_val = 3;
if (length(varargin)>1)
    if isstr(varargin{2})
        for i=2:2:length(varargin)
            switch varargin{i}
                case 'Title'
                    handles.title=varargin{i+1};
                case 'VoxelSize'
                    handles.voxelsize = varargin{i+1};
                case 'ROI'
                    handles.roilist = varargin{i+1};
                case 'Slice'
                    handles.curslice = varargin{i+1};
                case 'Coil'
                    handles.curcoil = varargin{i+1};   
                case 'WindowLevel'
                    handles.window = varargin{i+1}(1);
                    handles.level = varargin{i+1}(2);
                    windowlevel_mode='manual';
                case 'CPart'
                    if strcmpi(varargin{i+1},'Real')
                        cpart_val = 1; 
                    elseif strcmpi(varargin{i+1},'Imag')
                        cpart_val = 2; 
                    elseif strcmpi(varargin{i+1},'Mag')
                        cpart_val = 3; 
                    elseif strcmpi(varargin{i+1},'Phase')
                        cpart_val = 4; 
                    end
                case 'ROI_callback'
                    handles.roicallback = varargin{i+1};
                case 'UserData'
                    handles.UserData=varargin{i+1};
                case 'ROIDataFile'
                    handles.roi_data_file=varargin{i+1};
                case 'Colormap'
                    handles.colormap=varargin{i+1};
                case 'TrueColor'
                    if isstr(varargin{i+1})
                        if strcmpi(varargin{i+1}, 'true')
                            handles.truecolor=1;
                        end
                    else isnumeric(varargin{i+1})
                        if varargin{i+1}~=0
                            handles.truecolor=1;
                        end
                    end
                otherwise
                    error(['Unknown option ' varargin{i} 'with value ' varargin{i+1} ]);
            end
        end
    else
        handles.voxelsize = varargin{2};
    end
    handles.voxelsize=handles.voxelsize(:);
    if (length(handles.voxelsize)<4)
        handles.voxelsize = padarray(handles.voxelsize, [4-length(handles.voxelsize) 0], 1, 'post');
    end
    
end
if handles.truecolor
    if size(handles.img,3) ~= 3
        error(['Image is not a truecolor image: 3rd dimension is not of size 3']);
    end
    handles.idxslice=4;
    handles.idxcoil=5;
else
    handles.idxslice=3;
    handles.idxcoil=4;
end
% size(handles.img)
handles.numslices=size(varargin{1},handles.idxslice);
handles.numcoils=size(varargin{1},handles.idxcoil);

if (1 == handles.numslices)
    set(handles.windowslider,'sliderstep',[0.5 0.5],'max',1,'min',0.9,'Value',handles.curslice);
else
    sliderstepline = [1/(handles.numslices-1) 1/(handles.numslices-1)];
    set(handles.windowslider,'sliderstep',sliderstepline,'max',handles.numslices,'min',1,'Value',handles.curslice);
end

if (1 == handles.numcoils)
    set(handles.windowslider,'sliderstep',[0.5 0.5],'max',1,'min',0.9,'Value',handles.curslice);
else
    sliderstepline = [1/(handles.numcoils-1) 1/(handles.numcoils-1)];
    set(handles.levelslider,'sliderstep',sliderstepline,'max',handles.numcoils,'min',1,'Value',handles.curcoil);
end
handles.wlmode=0;
handles.wlfudge=-1;
handles.scrollmode=0;
handles.buttondownpt=[0 0];
handles.cpartstr={'Real', 'Imag', 'Mag', 'Phase'};
handles.cpart={'real', 'imag', 'abs', 'angle'};
handles.roimode = 0;
handles.roi.radius = -1;
handles.roi.center = [1 1];

handles.newroi.radius = -1;
handles.newroi.center = [1 1];
handles.newroi.slice = handles.curslice;
handles.newroi.name = '';
handles.newroi.mask = [0];
handles.newroi.data = [0];
handles.newroi.dynamic = 0;
handles.oldroi_id = -1;
handles.oldroi_center = [ -1 -1 ];
handles.oldroi_radius = -100;
handles.oldroi_slice = -100;
handles.oldroi_cpart = -1;
handles.updateROIslice = 1;
coord=repmat({':'},[1 numel(size(handles.img))]);
coord{handles.idxslice}=handles.curslice;
% handles.roitmp=reshape(handles.img(:,:,handles.curslice,:),[], handles.numcoils);
handles.roitmp=reshape(handles.img(coord{:}),[], handles.numcoils);
if iscell(handles.roilist) 
    if length(handles.roilist)
        for i=1:length(handles.roilist)
            roilist(i)=handles.newroi;
            roilist(i).name=handles.roilist{i};
        end
        handles.roilist = roilist;
        handles.roimode = 1;
    else
        handles.roilist=handles.newroi;
    end
elseif length(handles.roilist)
    for i=1:length(handles.roilist)
        if ~isfield(handles.roilist(i), 'name')
            handles.roilist(i).name=['roi' num2str(i, '%03d')];
        end
        if isempty(handles.roilist(i).name)
            handles.roilist(i).name=['roi' num2str(i, '%03d')];
        end
        handles.roimode = 1;
    end
else
    handles.roilist=handles.newroi;
end
set(handles.roibox,'Value',handles.roimode);
set(handles.ROI_popupmenu, 'String', roinames(handles));
set(handles.ROI_popupmenu, 'Value',1);
if handles.roimode
    if handles.roilist(1).dynamic; idcoil = handles.curcoil; else idcoil=1; end
    handles.curslice = handles.roilist(1).slice(idcoil);
    handles.roi = handles.roilist(1);
end
handles.max_num_rois=32;
handles.roi_mean_first=1;
set(handles.figure1, 'DoubleBuffer', 'on');
handles.imhandle = -1;
handles.do_plot_is_running = 0;
handles.impos=[0 0];
handles.curvemode = 0;
handles.curvefigure = -1;
handles.curveplot = -1;
handles.curveline = -1;
handles.statusfigure = -1;
handles.statuslist = -1;
handles.funcmapfigure = -1;
handles.roicreate = 0;
handles.roimove = 0;
handles.roimoveoff = [0 0];
handles.roiresize = 0;
handles.roiresizeoff = 1;
handles.roihandle = -1;
handles.line_mode = 0;
handles.line_numpoints = 0;
handles.line_x = [1 1];
handles.line_y = [1 1];
handles.line_create = 0;
handles.linehandle = -1;
handles.do_interpol = 0;
guidata(hObject, handles);
set(handles.cpartpopup, 'String', handles.cpartstr);

set(handles.cpartpopup, 'Value',cpart_val);
if strcmp(get(hObject,'Visible'),'off')
     do_plot(hObject,handles, windowlevel_mode);
end
set(hObject,'Name',handles.title);
addToolbarExplorationButtons(gcf);

% UIWAIT makes Vis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ishandle(handles.curvefigure)
    close(handles.curvefigure);
end
if ishandle(handles.statusfigure)
    close(handles.statusfigure);
end

% Hint: delete(hObject) closes the figure
delete(hObject);

% --- Outputs from this function are returned to the command line.
function varargout = Vis_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function A = extract_image(handles, slice, coil)
if nargin<2
    slice=handles.curslice;
end
if nargin<3
    coil=handles.curcoil;
end
coord=repmat({':'},[1 min(numel(size(handles.img)),4)]);
coord{handles.idxslice}=slice;
coord{handles.idxcoil}=coil;
% imgstring = [handles.cpart{get(handles.cpartpopup, 'Value')} '(handles.img(:,:,handles.curslice,handles.curcoil))'];
imgstring = [handles.cpart{get(handles.cpartpopup, 'Value')} '(handles.img(coord{:}))'];
if handles.do_interpol
    A=eval(imgstring);
    vox=min(handles.voxelsize(1:2));
    dx=0.5/handles.voxelsize(1)*vox;
    dy=0.5/handles.voxelsize(2)*vox;
    F = griddedInterpolant(double(A));
    xq = (1:dx:size(A,1))';
    yq = (1:dy:size(A,2))';
    F.Method = 'linear';
    imgstring = 'F({xq,yq})';
end
A=eval(imgstring);

function do_plot(hObject, handles, varargin)
% set(handles.statustext, 'String', 'Updating. Please wait...');
extraarg={};
if (length(varargin) > 0)
    if (~isempty(find(ismember(varargin, 'auto'))))
        extraarg={'auto'};
    end
    if (~isempty(find(ismember(varargin, 'manual'))))
        extraarg={'manual'};
    end
end
set_wl(hObject, extraarg);
handles=guidata(hObject);

% hold;
% imagesc(handles.img); colormap(gray);
% coord=repmat({':'},[1 min(numel(size(handles.img)),4)]);
% coord{handles.idxslice}=handles.curslice;
% coord{handles.idxcoil}=handles.curcoil;
% % imgstring = [handles.cpart{get(handles.cpartpopup, 'Value')} '(handles.img(:,:,handles.curslice,handles.curcoil))'];
% imgstring = [handles.cpart{get(handles.cpartpopup, 'Value')} '(handles.img(coord{:}))'];
% do_interpol=1;
% if do_interpol
%     A=eval(imgstring);
%     F = griddedInterpolant(double(A));
%     xq = (1:0.5:size(A,1))';
%     yq = (1:0.5:size(A,2))';
%     F.Method = 'linear';
%     imgstring = 'F({xq,yq})';
% end
A=extract_image(handles);
%imshow(eval(imgstring)); 
if ~ishandle(handles.imhandle)
    axes(handles.image);
    hAxes=gca;
%     imgstring
%     coord
    handles.imhandle=imshow(A,'Interpolation','bilinear');
    if ~strcmp(handles.colormap,'') 
        colormap(hAxes, eval(handles.colormap));colorbar;
    end
    hAxes.Toolbar.Visible = 'off'; % Turns off the axes toolbar
else
    set(handles.imhandle,'CData',A);
end
guidata(hObject, handles);
if ~handles.do_interpol
    daspect(handles.image,handles.voxelsize(1:3));
end
set_wl(hObject, extraarg);
if(handles.roimode)
    guidata(hObject, handles);
    handles = computeROI(hObject);
    if ishandle(handles.roihandle)
        delete(handles.roihandle)
    end
    ctrs=[];
    radi=[];
    labels={};
    for i=1:length(handles.roilist)
        if handles.roilist(i).dynamic
%             handles.roilist(i).radius
%             handles.roilist(i).slice
            idcoil = handles.curcoil;
            if (   (handles.roilist(i).radius(idcoil) > 0) ...
                    && (handles.roilist(i).slice(idcoil) == handles.curslice) )
                ctrs = [ctrs; handles.roilist(i).center(idcoil,:)];
                radi = [radi; handles.roilist(i).radius(idcoil)];
                labels{length(labels)+1}=num2str(i);
            end
        else
            if (   (handles.roilist(i).radius > 0) ...
                    && (handles.roilist(i).slice == handles.curslice) )
                ctrs = [ctrs; handles.roilist(i).center];
                radi = [radi; handles.roilist(i).radius];
                labels{length(labels)+1}=num2str(i);
            end
        end
    end
    if length(ctrs)
        handles.roihandle=viscircles2(handles.image,ctrs, radi,labels,'LineWidth', 1);
    end
    %handles.roihandle=viscircles2(handles.image,handles.roilist(id).center, ...
    %    handles.roilist(id).radius,'LineWidth', 1);
    %         roi=getROI(handles);
    
    %         handles = guidata(hObject);
    id=get(handles.ROI_popupmenu, 'Value');
    roidata_string = [handles.cpart{get(handles.cpartpopup, 'Value')} '(handles.roilist(id).data)'];
    roidata = eval(roidata_string);
    mn=mean(squeeze(roidata(:,handles.curcoil)));
    st=std(squeeze(roidata(:,handles.curcoil)));
    set(handles.roitext, 'String', [num2str(mn,4) '+/-' num2str(st,4) ]);
    guidata(hObject, handles);
    
else
    if ishandle(handles.roihandle)
        delete(handles.roihandle)
    end
end
if (handles.line_mode)
    if (handles.line_numpoints == 2)
        if ishandle(handles.linehandle)
            delete(handles.linehandle)
        end
        handles.linehandle=line(handles.line_x, handles.line_y,'LineWidth',1,'Color',[1 0 0]);
    end
    guidata(hObject, handles);
else
    if ishandle(handles.linehandle)
        delete(handles.linehandle)
    end
end
set(handles.slicetext, 'String', [num2str(handles.curslice)]);
set(handles.coiltext, 'String', [num2str(handles.curcoil)]);
if (handles.curvemode)
    update_curveplot(hObject, handles);
end



function set_wl(hObject, varargin)
handles = guidata(hObject);
% coord=repmat({':'},[1 numel(size(handles.img))]);
% coord{handles.idxslice}=handles.curslice;
% coord{handles.idxcoil}=handles.curcoil;
% imgstring = [handles.cpart{get(handles.cpartpopup, 'Value')} '(handles.img(coord{:}))'];
if (length(varargin)>0)
    if (strcmp(varargin{1}, 'auto') + strcmp(varargin{1}, 'manual'))
%         img2=eval(imgstring);
        img2=extract_image(handles);
        img2=img2(:);
        if handles.roimode
            id=get(handles.ROI_popupmenu, 'Value');
            if (handles.roilist(id).dynamic) 
                idx = handles.curcoil;
                if handles.roilist(id).radius(idx) > 0
                    handles=computeROI(hObject);
                    handles.maxi=squeeze(max(img2(handles.roilist(id).mask(idx,:))));
                    handles.mini=squeeze(min(img2(handles.roilist(id).mask(idx,:))));
                end
            else
                if handles.roilist(id).radius > 0
                    handles=computeROI(hObject);
                    handles.maxi=max(img2(handles.roilist(id).mask(:)));
                    handles.mini=min(img2(handles.roilist(id).mask(:)));
                end
            end
           
        else
            handles.maxi=max(img2);
            handles.mini=min(img2);
        end
        if (handles.maxi == handles.mini) handles.maxi = handles.mini + 1; end;
        if strcmp(varargin{1}, 'auto')
            handles.window=(handles.maxi-handles.mini);
            handles.level=(handles.maxi+handles.mini)/2;
        end
%         if (handles.maxi>handles.mini)
%              sliderstepline = [0.05 0.1]/(handles.maxi>handles.mini);
%         else
%             sliderstepline = [0.05 0.1];
%         end
%         set(handles.windowslider,'sliderstep',sliderstepline,'max',handles.maxi,'min',handles.mini,'Value',handles.window);
%         set(handles.levelslider,'sliderstep',sliderstepline,'max',handles.maxi,'min',handles.mini,'Value',handles.level);
        
    end
end

% axes(handles.image);
if handles.wlfudge<0
    if (handles.maxi>handles.mini+eps)
        handles.wlfudge=(handles.maxi-handles.mini)*0.00001;
    else
        handles.wlfudge=1;
    end
    if length(varargin)>0
        if strcmp(varargin{1}, 'manual')
            handles.wlfudge=0;
        end
    end
end
caxis([handles.level-handles.window/2-handles.wlfudge handles.level+handles.window/2]);
set(handles.WLTextValue, 'String', ...
    sprintf('%4.4g/\n%4.4g', handles.window, handles.level));
guidata(hObject, handles);   

% --- Executes during object creation, after setting all properties.
function windowslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to windowslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function windowslider_Callback(hObject, eventdata, handles)
% hObject    handle to windowslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% handles.window = get(hObject, 'Value');
oldslice = handles.curslice;
handles.curslice = max(1, min(handles.numslices, round(get(hObject, 'Value'))));
% guidata(hObject, handles);
% set_wl(hObject);
if (oldslice ~= handles.curslice)
    guidata(hObject, handles);
    do_plot(hObject,handles);
end

% --- Executes during object creation, after setting all properties.
function levelslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to levelslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function levelslider_Callback(hObject, eventdata, handles)
% hObject    handle to levelslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% handles.level = get(hObject, 'Value');
oldcoil = handles.curcoil;
handles.curcoil = max(1, min(handles.numcoils, round(get(hObject, 'Value'))));
% guidata(hObject, handles);
% set_wl(hObject);
if (oldcoil ~= handles.curcoil)
    guidata(hObject, handles);
    do_plot(hObject,handles);
end

function names=roinames(handles)
for i=1:length(handles.roilist)
    names{i}=[num2str(i) ' ' handles.roilist(i).name];
end

function y = valid_radius(x)
if x>=0
    y=max(1,x);
else
    y=-1;
end

function handles= computeROI(hObject)
% if isMultipleCall();  return;  end
handles = guidata(hObject);
id=get(handles.ROI_popupmenu, 'Value');
if handles.roilist(id).dynamic; idcoil = handles.curcoil; else idcoil=1; end
% disp(['dynamic ===> ' num2str(handles.roilist(id).dynamic)]);
% disp(handles.blabla);
% size(handles.roilist(id).center)
% idcoil
% size(handles.roilist(id).center)
if ((handles.oldroi_id == id) ...
        && min(handles.oldroi_center == handles.roilist(id).center(idcoil,:)) ...
        && (handles.oldroi_radius == handles.roilist(id).radius(idcoil))...
        && (handles.oldroi_slice == handles.curslice))
%     disp('Not updating')
    return;
end
if handles.updateROIslice
    handles.roilist(id).slice(idcoil:end)=handles.curslice;
    handles.updateROIslice = 0;
end
if (handles.oldroi_slice ~= handles.curslice) ...
        || (handles.oldcpart ~= get(handles.cpartpopup, 'Value'))
%     disp('new slice or cpart')
    if (handles.roilist(id).dynamic)
        handles.roitmp=zeros([size(handles.img,1) size(handles.img,2) handles.numcoils]);
%         handles.roilist(id).slice
        for coil=1:handles.numcoils
%             handles.roilist(id).slice
            handles.roitmp(:,:,coil)=handles.img(:,:,handles.roilist(id).slice(coil),coil);
        end
        handles.roitmp=reshape(handles.roitmp,[], handles.numcoils);
    else
%         coord=repmat({':'},[1 min(4,numel(size(handles.img)))]);
%         coord{handles.idxslice}=handles.roilist(id).slice;
%         handles.roitmp=reshape(handles.img(coord{:}),[], handles.numcoils);
        handles.roitmp=reshape(extract_image(handles,handles.roilist(id).slice,':'),[], handles.numcoils);

    end
end
handles.oldroi_id = id;
handles.oldroi_center = handles.roilist(id).center(idcoil);
handles.oldroi_radius = handles.roilist(id).radius(idcoil);
handles.oldroi_slice = handles.curslice;
handles.oldcpart = get(handles.cpartpopup, 'Value');

% handles.roilist(id).data=randn(20,handles.numcoils);
[YY, XX] = meshgrid(1:size(handles.img,2),1:size(handles.img,1));
handles.roilist(id).mask=[];
handles.roilist(id).data=[];
% id
% size(handles.roilist(id).center)
if handles.roilist(id).dynamic
    for coil=1:handles.numcoils
        Y = YY - handles.roilist(id).center(coil,1);
        X = XX - handles.roilist(id).center(coil,2);
        radius = [X.^2 + Y.^2].^0.5;
        mtmp=logical(radius<=handles.roilist(id).radius(coil));
        dtmp=handles.roitmp(mtmp,coil);
        mtmp=reshape(mtmp, 1, []);
        dmtp=reshape(dtmp, [], 1);
        if isempty(handles.roilist(id).mask)
            handles.roilist(id).mask=repmat(mtmp, [handles.numcoils 1]);
            handles.roilist(id).data=repmat(dtmp, [1 handles.numcoils]);
        else
            handles.roilist(id).mask(coil,:)=mtmp;
            handles.roilist(id).data(:,coil)=dtmp;
        end
        
    end
else
    Y = YY - handles.roilist(id).center(1);
    X = XX - handles.roilist(id).center(2);
    radius = [X.^2 + Y.^2].^0.5;
    handles.roilist(id).mask=logical(radius<=handles.roilist(id).radius);
    handles.roilist(id).data=handles.roitmp(handles.roilist(id).mask,:);
end
guidata(hObject, handles);
% 
% function roi=getROI(handles)
% coord=repmat({':'},[1 numel(size(handles.img))]);
% coord{handles.idxslice}=handles.curslice;
% itmp=handles.img(coord{:});
% itmp=reshape(itmp, [], handles.numcoils);
% [Y, X] = meshgrid(1:size(handles.img,2),1:size(handles.img,1));
% Y = Y - handles.roi.center(1);
% X = X - handles.roi.center(2);
% radius = [X.^2 + Y.^2].^0.5;
% roi.center=handles.roi.center;
% roi.radius=handles.roi.radius;
% roi.slice=handles.curslice;
% roi.mask=(radius<=handles.roi.radius);
% roi.data=itmp(roi.mask,:); 

% function setROI(handles, roi)
% handles.curslice = roi.slice;
% handles.roi = roi;

        
function line=getLINE(handles)
%     coord=repmat({':'},[1 numel(size(handles.img))]);
% coord{handles.idxslice}=handles.curslice;
% coord{handles.idxcoil}=handles.curcoil;
% itmp=handles.img(coord{:});
itmp=extract_image(handles);
% itmp=reshape(itmp, [], handles.numcoils);
Y = 1:size(handles.img,1);
X = 1:size(handles.img,2);
dXI = (handles.line_x(1,2)-handles.line_x(1,1))*1;
dYI = (handles.line_y(1,2)-handles.line_y(1,1))*1;
nI = ceil(sqrt(dXI^2+dYI^2));
dXI = dXI/(nI-1);
dYI = dYI/(nI-1);
line.X=handles.line_x(1,1)+dXI*(0:(nI-1));
line.Y=handles.line_y(1,1)+dYI*(0:(nI-1));
line.data = interp2(X,Y,itmp,line.X,line.Y);

function [curve lstr]=getCURVE(hObject, handles)
handles=guidata(hObject);
pixstr='';
curve=0;
if (handles.roimode)
%     id=get(handles.ROI_popupmenu, 'Value');
%    if (handles.roilist(id).radius > 0)
%         handles = computeROI(hObject); 
% %         handles =  guidata(hObject);
%         pixstr = ['mean(' handles.cpart{get(handles.cpartpopup, 'Value')} '(handles.roilist(id).data),1)'];
%     end
    handles=computeROI(hObject);
    pixstr = '[';
    lstr = {};
    for i=1:length(handles.roilist)
        if (handles.roilist(i).radius > 0)
            lstr{length(lstr)+1}=handles.roilist(i).name;
            pixstr = [ pixstr ' mean(' handles.cpart{get(handles.cpartpopup, 'Value')} ...
                        '(handles.roilist(' num2str(i) ').data''),2)'];
        end
    end
    pixstr = [ pixstr ']'];
% elseif (handles.line_mode ...
%         && (handles.line_numpoints == 2) ...
%         && (handles.line_create == 0))
%     line = getLINE(handles);
%     pixstr = [handles.cpart{get(handles.cpartpopup, 'Value')} '(line.data)'];
else
    lstr{1}=[num2str(handles.impos(1)) ','...
          num2str(handles.impos(2)) ',' ...
          num2str(handles.curslice)];
    coord=repmat({':'},[1 numel(size(handles.img))]);
    coord{1}=handles.impos(2);
    coord{2}=handles.impos(1);
    coord{handles.idxslice}=handles.curslice;
    pixstr=[handles.cpart{get(handles.cpartpopup, 'Value')} ...
        '(handles.img(coord{:}))'];
end
if (0 == strcmp(pixstr, ''))
    curve=squeeze(eval(pixstr));
end
        
        
function update_curveplot(hObject, handles)
if isMultipleCall();  return;  end
handles = guidata(hObject);
[yy labels] = getCURVE(hObject, handles);
if ~length(yy)
    return
end
nc=size(yy,2);
yy2=nan(size(yy,1), handles.max_num_rois);
yy2(:,1:nc)=yy;
yy2 = num2cell(yy2.',2);
if ishandle(handles.curvefigure)
    if ishandle(handles.curveline)
       set(handles.curveline, ...
           'XData', [handles.curcoil handles.curcoil], ...
           'YData', [0 0]);
    end
    if ishandle(handles.curveplot)
        set(handles.curveplot, {'YData'}, yy2);
        for i=1:handles.max_num_rois
            if i<=nc
                set(get(get(handles.curveplot(i), 'Annotation'),'LegendInformation'), 'IconDisplayStyle','on');
                set(handles.curveplot(i), 'DisplayName', labels{i});
            else
                set(get(get(handles.curveplot(i), 'Annotation'),'LegendInformation'), 'IconDisplayStyle','off');
            end
        end
        leghandle = findall(handles.curvefigure, 'tag', 'legend');
        set(leghandle, 'String', labels);
    end
    if ishandle(handles.curveline)
       set(handles.curveline, ...
           'XData', [handles.curcoil handles.curcoil], ...
           'YData', get(get(handles.curvefigure, 'CurrentAxes'),'ylim'));
    end
    if isa(handles.roicallback, 'function_handle')
        if ishandle(handles.statuslist) 
%             tic;
            text=handles.roicallback(handles);
%             toc;
%             set(handles.statuslist, 'UserData', 'My Text ');
            set(handles.statuslist, 'String', text);
        end
        
    end
end


function myKeyPressFcn(hObject, eventdata, handles)
h=get(handles.figure1);
pressedChar=double(h.CurrentCharacter);
modifiers = get(handles.figure1,'CurrentModifier');
wasShiftPressed = ismember('shift',   modifiers);  % true/false
wasCtrlPressed  = ismember('control', modifiers);  % true/false
wasAltPressed   = ismember('alt',     modifiers);  % true/false

oldslice = handles.curslice;
oldcoil = handles.curcoil;
pressedChar;
if ( 31 == pressedChar)
    handles.curslice = mod(handles.curslice, handles.numslices) + 1;
    handles.updateROIslice = wasShiftPressed;
elseif ( 30 == pressedChar)
    handles.curslice = mod(handles.curslice-2, handles.numslices) + 1;
    handles.updateROIslice = wasShiftPressed;
elseif ( 29 == pressedChar)
    handles.curcoil = mod(handles.curcoil, handles.numcoils) + 1;
elseif ( 28 == pressedChar)
    handles.curcoil = mod(handles.curcoil-2, handles.numcoils) + 1;
elseif (97 == pressedChar)
    set_wl(hObject, 'auto');
elseif (113 == pressedChar)
    close(hObject);
elseif (104 == pressedChar)
    helpdlg({...
        'h     = help',...
        'p     = plot roi curve',...
        'enter = save roi curve',...
        'a     = auto W/L',...
        'up/do = scroll z',...
        'le/ri = scroll t',...
        'c     = continuous curve'});
elseif (99 == pressedChar)
    handles.curvemode = 1 - handles.curvemode;
    if (handles.curvemode)       
        if ~ishandle(handles.curvefigure)
%             handles.curvefigure=figure;
%             handles.curveplot=init_curveplot(handles);
            guidata(hObject, handles);
            init_curveplot(hObject, handles);
            handles=guidata(hObject);
        end
    else
%         if ishandle(handles.curvefigure)
%             close(handles.curvefigure);
%         end
    end
    set(handles.roicurvebox,'Value',handles.curvemode);
    guidata(hObject, handles);
elseif ((13 == pressedChar)|(112 == pressedChar))
    handles=guidata(hObject);
    if handles.roimode
        id=get(handles.ROI_popupmenu, 'Value');
        if handles.roilist(id).radius > 0
            handles=computeROI(hObject);
%             handles=guidata(hObject);
            if (13 == pressedChar)
                ANSWER = inputdlg('Variable name','ROI',1,{'roi'});
                evalin('base', ['global ' ANSWER{1} ';']);
                eval(['global ' ANSWER{1} ';']);
                eval([ANSWER{1} '=handles.roilist(id);']);
            else
                plotstring = ['mean(' handles.cpart{get(handles.cpartpopup, 'Value')} '(handles.roilist(id).data),1)'];
                figure; plot(eval(plotstring));
            end
        end
    end
    if (handles.line_mode ...
            && (handles.line_numpoints == 2) ...
            && (handles.line_create == 0))
        line = getLINE(handles);
        if (13 == pressedChar)
            ANSWER = inputdlg('Variable name','LINE',1,{'roi'});
            evalin('base', ['global ' ANSWER{1} ';']);
            eval(['global ' ANSWER{1} ';']);
            eval([ANSWER{1} '=line;']);
        else
            plotstring = [handles.cpart{get(handles.cpartpopup, 'Value')} '(line.data)'];
            figure; plot(eval(plotstring));
        end
    end
elseif (109 == pressedChar)
    if isa(handles.roicallback, 'function_handle')
        map=handles.roicallback(handles, 'MAP');
        if ~isempty(map)
            vis(map);
        end
%         if ~ishandle(handles.funcmapfigure)
%             disp(['Call to funcmap']);
%             map=handles.roicallback(handles, 'MAP');
%             if ~isempty(map)
%                 guidata(hObject, handles);
%                 init_funcmap(hObject, handles);
%                 handles=guidata(hObject);
%                 set(handles.funcmapplot,'CData',abs(map));
%             end
%         end
    end
elseif (82 == pressedChar) %R
    if 1 ~=get(handles.cpartpopup, 'Value')
        set(handles.cpartpopup, 'Value',1);
        guidata(hObject, handles);
        do_plot(hObject,handles);
    end
elseif (73 == pressedChar) %I
    if 2 ~=get(handles.cpartpopup, 'Value')
        set(handles.cpartpopup, 'Value',2);
        guidata(hObject, handles);
        do_plot(hObject,handles);
    end
elseif (77 == pressedChar) %M
    if 3 ~=get(handles.cpartpopup, 'Value')
        set(handles.cpartpopup, 'Value',3);
        guidata(hObject, handles);
        do_plot(hObject,handles);
    end
elseif (80 == pressedChar) %P
    if 4 ~=get(handles.cpartpopup, 'Value')
        set(handles.cpartpopup, 'Value',4);
        guidata(hObject, handles);
        do_plot(hObject,handles);
    end
end
if ((oldslice ~= handles.curslice) || (oldcoil ~= handles.curcoil))
    guidata(hObject, handles);
    do_plot(hObject,handles);
end

function imageButtonDownFcn(hObject, eventdata, handles)
h=get(handles.image)
get(h, 'SelectionType')


function myWindowButtonDownFcn(hObject, eventdata, handles)
handles.buttondownpt=get(hObject, 'CurrentPoint');
seltype=get(hObject, 'SelectionType');
% seltype
mouse_handled = 0;
if (handles.roimode)
    cpt=get(handles.image, 'CurrentPoint');
    id=get(handles.ROI_popupmenu, 'Value');
    impos=[1 1] + floor(cpt(1,1:2));
    if handles.roilist(id).dynamic; cidx=handles.curcoil; else cidx = 1;end
    c = handles.roilist(id).center(cidx,:);
    r = handles.roilist(id).radius(cidx);
    if (r < 0)    
        if ([impos size(handles.img,2) size(handles.img,1)] >=[1 1 impos])
            handles.roilist(id).center(cidx,:) = impos;
            handles.roilist(id).slice(cidx) = handles.curslice;
            handles.roicreate = 1;
            handles.updateROIslice = 1;
            mouse_handled = 1;
            guidata(hObject, handles);
        end
    else
        if (norm(impos-c)<0.90*r)
            handles.roimove=1;
            handles.roimoveoff=impos-c;
            mouse_handled = 1;
            guidata(hObject, handles);
        elseif (norm(impos-c)>=-3+r ...
                && norm(impos-c)<=3+r)
            handles.roiresize = 1;
            handles.roiresizeoff = norm(impos-c)-r;
            mouse_handled = 1;
            guidata(hObject, handles);
        end
    end
end
if (handles.line_mode)
    cpt=get(handles.image, 'CurrentPoint');
    impos=[1 1] + floor(cpt(1,1:2));
%     disp(['line_numpoints = ' num2str(handles.line_numpoints) ]);
    switch handles.line_create 
        case 0
            if (valid(handles, impos))
                handles.line_create = 1;
                handles.line_x(1,1)=impos(1);
                handles.line_y(1,1)=impos(2);
                handles.line_numpoints = 1;
                mouse_handled = 1;
            end
        case 1
            handles.line_create = 0;
    end
    guidata(hObject, handles);
end
if ~mouse_handled
    if strcmp('alt', seltype)
        handles.wlmode=1;
        handles.wldown=[handles.window handles.level];
        guidata(hObject, handles);
    elseif strcmp('normal', seltype)
        handles.scrollmode=1;
        handles.slicedown=handles.curslice;
        handles.coildown=handles.curcoil;
        guidata(hObject, handles);
    end
end

function myWindowButtonMotionFcn(hObject, eventdata, handles)
cpt=get(handles.image, 'CurrentPoint');
impos=[1 1] + floor(cpt(1,1:2));
valid_impos=0;
if ([impos size(handles.img,2) size(handles.img,1)] >=[1 1 impos])
    valid_impos = 1;
    handles.impos = impos;
    guidata(hObject, handles);
    coord=repmat({':'},[1 numel(size(handles.img))]);
    coord{1}=impos(2);
    coord{2}=impos(1);
    coord{handles.idxslice}=handles.curslice;
    coord{handles.idxcoil}=handles.curcoil;
    pixstr=[handles.cpart{get(handles.cpartpopup, 'Value')} '(handles.img(coord{:}))'];
    pixval=eval(pixstr);
    set(handles.pixelvalue, 'String', ['(',num2str(impos(1)),',',num2str(impos(2)),')=',num2str(pixval)]); 
    if (handles.curvemode)
        if ~ishandle(handles.curvefigure)
%             handles.curvefigure=figure;
%             handles.curveplot=init_curveplot(handles);
            guidata(hObject, handles);
            init_curveplot(hObject, handles);
            handles=guidata(hObject);
        end
        update_curveplot(hObject, handles);
%         curveval = getCURVE(handles);
%         ishandle(handles.curvefigure)
%         if ishandle(handles.curvefigure)
%             if ishandle(handles.curveplot)
%                 set(handles.curveplot,'ydata',curveval);
%             end
%         else
%             handles.curvefigure=figure;
%             handles.curveplot=plot(curveval);
%         end
    end
    guidata(hObject, handles);
end
if (handles.wlmode )
    rect=get(hObject, 'Position');
    rect=rect(3:4);
    pos=get(hObject, 'CurrentPoint')-handles.buttondownpt;
    pos = pos./rect*(handles.maxi-handles.mini);
    handles.window = mychop(handles.wldown(1) + pos(1), 0, handles.maxi-handles.mini);
    handles.level  = mychop(handles.wldown(2) + pos(2), handles.mini, handles.maxi);
    guidata(hObject, handles);
    set_wl(hObject);
end
if (handles.scrollmode )
    rect=get(hObject, 'Position');
    rect=rect(3:4);
    pos=get(hObject, 'CurrentPoint')-handles.buttondownpt;
    oldslice = handles.curslice;
    handles.curslice = mychop(handles.slicedown - round(pos(2)/rect(2)*handles.numslices), 1, handles.numslices);
    oldcoil = handles.curcoil;
    handles.curcoil = mychop(handles.coildown + round(pos(1)/rect(1)*handles.numcoils), 1, handles.numcoils);
    if ((oldslice ~= handles.curslice) || (oldcoil ~= handles.curcoil))
        guidata(hObject, handles);
        do_plot(hObject,handles);
    end
end
if (handles.roimode)
    id=get(handles.ROI_popupmenu, 'Value');
    if handles.roilist(id).dynamic; cidx=handles.curcoil; else cidx = 1;end
    c = handles.roilist(id).center(cidx,:);
    r = handles.roilist(id).radius(cidx);
    if (handles.roicreate )
        if (valid_impos)
            handles.roilist(id).radius(cidx)=valid_radius(norm(impos-c));
            guidata(hObject, handles);
            do_plot(hObject,handles);
        end 
    end
    if (handles.roimove)
        if (valid_impos)
            handles.roilist(id).center(cidx:end,1) = impos(1)-handles.roimoveoff(1);
            handles.roilist(id).center(cidx:end,2) = impos(2)-handles.roimoveoff(2);
            guidata(hObject, handles);
            do_plot(hObject,handles);
        end
    end
    if (handles.roiresize )
        if (valid_impos)
            handles.roilist(id).radius(:)=...
                valid_radius(norm(impos-c)-handles.roiresizeoff);
            guidata(hObject, handles);
            do_plot(hObject,handles);
        end
    end
end
if (handles.line_mode && ~handles.curvemode)
    if (handles.line_create == 1)
        if (valid_impos)
            handles.line_x(1,2)=impos(1);
            handles.line_y(1,2)=impos(2);
            handles.line_numpoints = 2;
            guidata(hObject, handles);
            do_plot(hObject,handles);
        end 
    end
end
    

function myWindowButtonUpFcn(hObject, eventdata, handles)
if strcmp('alt', get(hObject, 'SelectionType'))
    handles.wlmode=0;
    guidata(hObject, handles);
end;
if strcmp('normal', get(hObject, 'SelectionType'))
    handles.scrollmode=0;
    guidata(hObject, handles);
end;
if (handles.roicreate)
    handles.roicreate = 0;
    guidata(hObject, handles);
end
if (handles.roimove)
    handles.roimove = 0;
    guidata(hObject, handles);
end
if (handles.roiresize)
    handles.roiresize = 0;
    guidata(hObject, handles);
end
% if (handles.line_mode)
%     if (handles.line_numpoints == 1)
%         handles.line_numpoints = 2;
%         guidata(hObject, handles);
%         do_plot(hObject,handles);
%     end
% end

% --- Executes on selection change in navcoilpopup.
function cpartpopup_Callback(hObject, eventdata, handles)
% hObject    handle to navcoilpopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns navcoilpopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from navcoilpopup
do_plot(hObject,handles);


% --- Executes on button press in autoWLbutton.
function autoWLbutton_Callback(hObject, eventdata, handles)
% hObject    handle to autoWLbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, handles);
set_wl(hObject, 'auto');


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function image_CreateFcn(hObject, eventdata, handles)
% hObject    handle to image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate image


% --- Executes during object creation, after setting all properties.
function cpartpopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cpartpopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function autoWLbutton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to autoWLbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object deletion, before destroying properties.
function cpartpopup_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to cpartpopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over cpartpopup.
function cpartpopup_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to cpartpopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on cpartpopup and no controls selected.
function cpartpopup_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to cpartpopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object deletion, before destroying properties.
function autoWLbutton_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to autoWLbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over autoWLbutton.
function autoWLbutton_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to autoWLbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on autoWLbutton and no controls selected.
function autoWLbutton_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to autoWLbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function slicetext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slicetext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object deletion, before destroying properties.
function slicetext_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to slicetext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over slicetext.
function slicetext_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to slicetext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function coiltext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to coiltext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object deletion, before destroying properties.
function coiltext_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to coiltext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over coiltext.
function coiltext_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to coiltext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on figure1 and no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
myKeyPressFcn(hObject, eventdata, handles)

% --- Executes on key release with focus on figure1 and no controls selected.
function figure1_KeyReleaseFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function m=mychop(a, mn, mx)
if (a<mn)
    m=mn;
elseif (a>mx)
    m=mx;
else
    m=a;
end
    


% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on button press in roibox.
function roibox_Callback(hObject, eventdata, handles)
% hObject    handle to roibox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of roibox
handles.roimode = get(hObject, 'Value');
if (0 == handles.roimode) 
    handles.roi.radius = -1; 
    handles.roicreate = 0;
    handles.roimove = 0;
    handles.roiresize = 0;
end
guidata(hObject, handles);
do_plot(hObject,handles);

function h = viscircles2(varargin)
%VISCIRCLES Create circle.
%   VISCIRCLES(CENTERS, RADII) adds circles with specified CENTERS and
%   RADII to the current axes. CENTERS is a 2-column matrix with
%   X-coordinates of the circle centers in the first column and
%   Y-coordinates in the second column. RADII is a vector which specifies
%   radius for each circle. By default the circles are red.
%
%   VISCIRCLES(AX, CENTERS, RADII) adds circles to the axes specified by
%   AX.
%
%   H = VISCIRCLES(AX, CENTERS, RADII) returns a vector of handles to
%   hggroup objects, one for each circle.
%
%   H = VISCIRCLES(...,PARAM1,VAL1,PARAM2,VAL2,...) passes the name-value
%   pair arguments to specify additional properties of the circles.
%   Parameter names can be abbreviated.
%
%   'EdgeColor'
%       {ColorSpec} | none
%       Color of the circles edges. Specifies the color of the circle
%       edges as a color or specifies that no edges be drawn.
%
%   'LineStyle'
%       {-} | -- | : | -. | none
%       Line style of circle edge.
%       Line Style Specifiers Table
%
%   'LineWidth'
%       size in points
%       Width of the circles edge line. Specify this value in points. 1 point = 1/72 inch. The default value is 2 points.
%
%   Example
%   -------
%   This example finds both bright and dark circles in the image
%
%         I = imread('circlesBrightDark.png');
%         imshow(I)
% 
%         Rmin = 30;
%         Rmax = 65;
% 
%         % Find all the bright circles in the image
%         [centersBright, radiiBright] = imfindcircles(I,[Rmin Rmax], ...
%                                       'ObjectPolarity','bright');
% 
%         % Find all the dark circles in the image
%         [centersDark, radiiDark] = imfindcircles(I, [Rmin Rmax], ...
%                                       'ObjectPolarity','dark');
% 
%         % Plot bright circles in blue
%         viscircles(centersBright, radiiBright,'EdgeColor','b');
% 
%         % Plot dark circles in dashed red boundaries
%         viscircles(centersDark, radiiDark,'LineStyle','--');
%                    
% See also IMDISTLINE, IMFINDCIRCLES, IMTOOL.

%   Copyright 2011 The MathWorks, Inc.
%   $Revision: 1.1.6.2.2.1 $  $Date: 2011/12/19 06:30:32 $

[ax, centers, radii, labels, name_value_pairs] = parseInputs(varargin{:});

hh = zeros(size(centers, 1), 1);
for k = 1:size(centers,1)
    cx = centers(k, 1);
    cy = centers(k, 2);
    r = radii(k);
    
    x = cx - r;
    y = cy - r;
    width = 2*r;
    height = width;
    
    % Create hggroup object that will contain the two circles as children
    hh(k) = hggroup('Parent', ax);
    
    % Create a thin circle using the user-specified options
    thinCircHdl = rectangle('Parent', hh(k), ...
                            'Position', [x y width height], ...
                            'Curvature', [1 1], ...
                             name_value_pairs{:});
    label = text(x,y,labels{k},'Parent', hh(k), 'Color', [1 0 0]);
end

if nargout > 0
    h = hh;
end

function [ax, centers, radii, labels, name_value_pairs] = parseInputs(varargin)

mynarginchk(2, Inf);

needNewAxes = 0;

first_string = min(find(cellfun(@ischar, varargin), 1, 'first'));
if isempty(first_string)
    first_string = length(varargin) + 1;
end

name_value_pairs = varargin(first_string:end);

% Set default EdgeColor to red and default LineWidth to 2. We pre-pend
% {'EdgeColor', 'red', 'LineWidth', 2} to the list of name-value pairs for
% straight pass through to RECTANGLE.
name_value_pairs = [{'EdgeColor', 'red', 'LineWidth', 2}, name_value_pairs];

if first_string == 4
    % viscircles(centers, radii)    
    needNewAxes = 1;   
    centers = varargin{1};
    radii = varargin{2};
    labels = varargin{3};
elseif first_string == 5
    % viscircles(ax, centers, radii)
    ax = varargin{1};
    validateAxes(ax);
    
    centers = varargin{2};
    radii = varargin{3};
    labels = varargin{4};
    
else
    error(message('images:validate:invalidSyntax'))
end

validateCentersAndRadii(centers, radii, first_string);  

if(needNewAxes)    
    ax = gca;
end


    function validateCentersAndRadii(centers, radii, first_string)
        
        if(size(centers,1) ~= length(radii))
            error(message('images:validate:unequalNumberOfRows','CENTERS','RADII'))
        end
        
        if(~isempty(centers))
%             validateattributes(centers,{'numeric'},{'nonsparse','real', ...
%                 'ncols',2}, mfilename,'centers',first_string-2);
%             validateattributes(radii,{'numeric'},{'nonsparse','real','nonnegative', ...
%                 'vector'}, mfilename,'radii',first_string-1);
            
            centers = double(centers); 
            radii   = double(radii); 
        end
        
    

    function validateAxes(ax)
        
        if ~ishghandle(ax)
            error(message('images:validate:invalidAxes','AX'))
        end
        
        objType = get(ax,'type');
        if ~strcmp(objType,'axes')
            error(message('images:validate:invalidAxes','AX'))
        end
   
       


% --- Executes on mouse press over axes background.
function image_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function mynarginchk (minargs, maxargs)
 
if (nargin ~= 2)
    print_usage;
elseif (~isnumeric (minargs) || ~isscalar (minargs))
    error ('minargs must be a numeric scalar');
elseif (~isnumeric (maxargs) || ~isscalar (maxargs))
    error ('maxargs must be a numeric scalar');
elseif (minargs > maxargs)
    error ('minargs cannot be larger than maxargs')
end
 
args = evalin ('caller', 'nargin;');
if (args < minargs)
    error ('not enough input arguments');
elseif (args > maxargs)
    error ('too many input arguments');
end



% --- Executes during object creation, after setting all properties.
function roibox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roibox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in linebox.
function linebox_Callback(hObject, eventdata, handles)
% hObject    handle to linebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.line_mode = get(hObject, 'Value');
if (0 == handles.line_mode)
    handles.line_numpoints = 0;
%     handles.roi.radius = -1; 
%     handles.roicreate = 0;
%     handles.roimove = 0;
%     handles.roiresize = 0;
end
guidata(hObject, handles);
do_plot(hObject,handles);

% Hint: get(hObject,'Value') returns toggle state of linebox

function v=valid(handles, impos)
v=0;
if ([impos size(handles.img,2) size(handles.img,1)] >=[1 1 impos]) v=1; end


% --- Executes on selection change in ROI_popupmenu.
function ROI_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ROI_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ROI_popupmenu
if handles.roimode
    id = get(hObject,'Value');
    if handles.roilist(id).dynamic; idcoil = handles.curcoil; else idcoil=1; end
    handles.curslice=handles.roilist(id).slice(idcoil);
    if strcmp(handles.roilist(id).name,'')
        ANSWER = inputdlg('Set ROI name','ROI',1,{['roi' num2str(id, '%03d')]});
        handles.roilist(id).name=ANSWER{1};
        set(handles.ROI_popupmenu, 'String', roinames(handles));
    end
    guidata(hObject, handles);
    do_plot(hObject,handles);
end

% --- Executes during object creation, after setting all properties.
function ROI_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ROI_save_button.
function ROI_save_button_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
save(handles.roi_data_file, '-struct', 'handles', 'roilist');
msgbox(['Saved to ' handles.roi_data_file]);

% --- Executes on button press in ROI_delete_button.
function ROI_delete_button_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_delete_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.roimode
    id=get(handles.ROI_popupmenu, 'Value');
    n=length(handles.roilist);
    if n==1
        handles.roilist(1)=handles.newroi;
        handles.roilist(1).slice=handles.curslice.*ones(size(handles.roilist(1).slice));
        handles.roilist(1).name='';
        newid=1;
    else
        idx=1:n;
        handles.roilist=handles.roilist(idx~=id);
        newid=max(min(id,n-1),1);
    end
    set(handles.ROI_popupmenu, 'String', roinames(handles));
    set(handles.ROI_popupmenu, 'Value',newid);
    guidata(hObject, handles);
%     update_curveplot(hObject, handles);
    do_plot(hObject,handles);
%     hLegend = findall(handles.curvefigure,'tag','legend');
%     uic = get(hLegend,'UIContextMenu');
%     uimenu_refresh = findall(uic,'Label','Refresh');
%     callback = get(uimenu_refresh,'Callback');
%     hgfeval(callback,[],[]);
end


% --- Executes on button press in roicurvebox.
function roicurvebox_Callback(hObject, eventdata, handles)
% hObject    handle to roicurvebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of roicurvebox
handles.curvemode = get(hObject, 'Value');
guidata(hObject, handles);
    if (handles.curvemode)       
        if ~ishandle(handles.curvefigure)
%             handles.curvefigure=figure;
%             handles.curveplot=init_curveplot(handles);
            init_curveplot(hObject, handles);
            handles=guidata(hObject);
        end
    else
%         if ishandle(handles.curvefigure)
%             close(handles.curvefigure);
%         end
    end
do_plot(hObject,handles);


% --- Executes on button press in ROI_new_button.
function ROI_new_button_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_new_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.roimode
    id=length(handles.roilist)+1;
    ANSWER = inputdlg('Set ROI name','ROI',1,{['roi' num2str(id, '%03d')]});
    handles.roilist(id)=handles.newroi;
    handles.roilist(id).slice=handles.curslice;
    handles.roilist(id).name=ANSWER{1};
    set(handles.ROI_popupmenu, 'String', roinames(handles));
    set(handles.ROI_popupmenu, 'Value',id);
    guidata(hObject, handles);
%     update_curveplot(hObject, handles);
    do_plot(hObject,handles);
%     hLegend = findall(handles.curvefigure,'tag','legend');
%     uic = get(hLegend,'UIContextMenu');
%     uimenu_refresh = findall(uic,'Label','Refresh');
%     callback = get(uimenu_refresh,'Callback');
%     hgfeval(callback,[],[]);
end

% --- Executes on button press in ROI_dup_button.
function ROI_dup_button_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_dup_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.roimode
    id_curr=get(handles.ROI_popupmenu, 'Value');
    id=length(handles.roilist)+1;
    ANSWER = inputdlg('Set ROI name','ROI',1,{['roi' num2str(id, '%03d')]});
    handles.roilist(id)=handles.roilist(id_curr);
    handles.roilist(id).name=ANSWER{1};
    set(handles.ROI_popupmenu, 'String', roinames(handles));
    set(handles.ROI_popupmenu, 'Value',id);
    guidata(hObject, handles);
%     update_curveplot(hObject, handles);
    do_plot(hObject,handles);
%     hLegend = findall(handles.curvefigure,'tag','legend');
%     uic = get(hLegend,'UIContextMenu');
%     uimenu_refresh = findall(uic,'Label','Refresh');
%     callback = get(uimenu_refresh,'Callback');
%     hgfeval(callback,[],[]);
end

function init_curveplot(hObject, handles)
if isMultipleCall();  return;  end
handles=guidata(hObject);
set(0,'Units','pixels') ;
scnsize = get(0,'ScreenSize');
set(handles.figure1,'Units','pixels');
outerpos = get(handles.figure1,'OuterPosition');
newsize=[scnsize(3) scnsize(4)]*3/8;
pos=[outerpos(1)+outerpos(3)+1, ...
    outerpos(2)+outerpos(4)-newsize(2), ...
    newsize(1), ...
    newsize(2) ];
handles.curvefigure=figure('OuterPosition', pos, ...
                           'Name', [handles.title ' ROI plot'],...
                           'NumberTitle','off');
handles.curveplot = plot(zeros(handles.max_num_rois,handles.max_num_rois));
for i=1:length(handles.curveplot)
    if 1==i; flag='on'; else flag='off'; end
    set(get(get(handles.curveplot(i), 'Annotation'),'LegendInformation'), 'IconDisplayStyle',flag);
    set(handles.curveplot(i), 'DisplayName', '');
end
handles.curveline=line('XData', [handles.curcoil handles.curcoil], ...
                       'YData', get(get(handles.curvefigure, 'CurrentAxes'),'ylim'));
legend(handles.curveplot);
ax=get(handles.curvefigure, 'CurrentAxes');
if verLessThan('matlab','8.4')
    set(ax,'LegendColorbarListeners',[]); 
    setappdata(ax,'LegendColorbarManualSpace',1);
    setappdata(ax,'LegendColorbarReclaimSpace',1);
else
    ax.AutoListeners__ = {};
end

if isa(handles.roicallback, 'function_handle')
    newsize(2)=scnsize(4)/8;
    pos(2)=pos(2)-newsize(2);
    pos(4)=newsize(2);
    handles.statusfigure = figure('OuterPosition', pos, ...
                                  'Name', [handles.title ' ROI results'],...
                                  'NumberTitle','off');
    handles.statuslist = uicontrol('Style', 'listbox', ...
        'Units', 'normalized', ...
        'Position', [0, 0, 1, 1], ...
        'String', {'Hepatic Perfusion Index : '});
%     slh=handle(handles.statuslist);
%     lst=handle.listener(slh, findprop(slh, 'UserData'), 'PropertyPostSet', @statuslist_Callback); 
%     setappdata(slh, 'MyListeners', lst)
end
guidata(hObject, handles);
update_curveplot(hObject, handles);

% function statuslist_Callback(hObject, eventdata, handles)
% disp(['hello']);

function init_funcmap(hObject, handles)
if isMultipleCall();  return;  end
handles=guidata(hObject);
set(0,'Units','pixels') ;
scnsize = get(0,'ScreenSize');
set(handles.figure1,'Units','pixels');
outerpos = get(handles.figure1,'OuterPosition');
pos=outerpos; pos(1)=outerpos(1)-outerpos(3)-1;
handles.funcmapfigure=figure('OuterPosition', pos, ...
                           'Name', [handles.title ' Functional Plot'],...
                           'NumberTitle','off');
handles.funcmapplot = imshow(zeros(size(handles.img, 1), size(handles.img, 2)));
guidata(hObject, handles);

% legend(handles.curveplot);
% ax=get(handles.curvefigure, 'CurrentAxes');
% set(ax,'LegendColorbarListeners',[]); 
% setappdata(ax,'LegendColorbarManualSpace',1);
% setappdata(ax,'LegendColorbarReclaimSpace',1);

function flag=isMultipleCall()
s = dbstack();
% s(1) corresponds to isMultipleCall
if numel(s)<=2, flag=false; return; end
% compare all functions on stack to name of caller
count = sum(strcmp(s(2).name,{s(:).name}));
% is caller re-entrant?
if count>1, flag=true; else flag=false; end





% --- Executes on button press in dynamicbox.
function dynamicbox_Callback(hObject, eventdata, handles)
% hObject    handle to dynamicbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
if handles.roimode
    id=get(handles.ROI_popupmenu, 'Value');
    dmode = get(hObject,'Value');
    r = handles.roilist(id).radius;
    c = handles.roilist(id).center;
    s = handles.roilist(id).slice;
    if dmode
        handles.roilist(id).dynamic=1;
        if 1==numel(r); newr=r; else newr=r(handles.curcoil); end
        handles.roilist(id).radius=repmat(newr, [handles.numcoils 1]);
        if 2==numel(c); newc=c; else newc=c(curcoil,:); end
        handles.roilist(id).center=repmat(newc, [handles.numcoils 1]);
        if 1==numel(s); news=s; else news=s(handles.curcoil); end
        handles.roilist(id).slice=repmat(news, [handles.numcoils 1]);
    else
        handles.roilist(id).dynamic=0;
        if 1==numel(r); newr=r; else newr=r(handles.curcoil); end
        handles.roilist(id).radius=newr;
        if 2==numel(c); newc=c; else newc=c(handles.curcoil); end
        handles.roilist(id).center=newc;
        if 1==numel(s); news=s; else news=s(handles.curcoil); end
        handles.roilist(id).slice=news;
    end
%     id
%     size(handles.roilist(id).center)
%     size(handles.roilist(id).radius)
    guidata(hObject, handles);
end


% Hint: get(hObject,'Value') returns toggle state of dynamicbox


% --- Executes on button press in interp.
function interp_Callback(hObject, eventdata, handles)
% hObject    handle to interp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of interp
handles = guidata(hObject);
handles.do_interpol = get(hObject,'Value');
handles.imhandle=-1;
guidata(hObject, handles);
do_plot(hObject,handles);
