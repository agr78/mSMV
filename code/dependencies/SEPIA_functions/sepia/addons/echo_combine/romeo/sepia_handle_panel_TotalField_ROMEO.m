%% h = sepia_handle_panel_TotalField_ROMEO(hParent,h,position)
%
% Input
% --------------
% hParent       : parent handle of this panel
% h             : global structure contains all handles
% position      : position of this panel
%
% Output
% --------------
% h             : global structure contains all new and other handles
%
% Description: This GUI function creates a panel for ROMEO method
%
% Kwok-shing Chan @ DCCN
% k.chan@donders.ru.nl
% Date created: 12 June 2021 (v1.0)
% Date modified: 
%
%
function h = sepia_handle_panel_TotalField_ROMEO(hParent,h,position)
% set up method name displayed on GUI
sepia_universal_variables;

%% set default values
defaultThreshold = 0.5;
%defaultMcpc3dsSelection = 1;

%% Tooltips
% tooltips
tooltip.unwrap.panel.unwrap         = 'Select a phase unwrapping algorithm for spatial unwrapping';
tooltip.unwrap.panel.exclude        = ['Apply threshold on relative residual to exclude unreliable voxels based on ',...
                                        'mono-exponential decay model (only available for non-Laplacian methods)'];
tooltip.unwrap.panel.exclude_edit	= ['Higher value means accepting larger error between the data fitting and measurement'];

%% layout of the panel
nrow        = 3;
rspacing    = 0.01;
ncol        = 2;
cspacing    = 0.01;
[height,bottom,width,left] = sepia_layout_measurement(nrow,rspacing,ncol,cspacing);

%% Parent handle of children panel 

h.phaseUnwrap.panel.ROMEOTotalField = uipanel(hParent,...
    'Title','ROMEO total field calculation',...
    'position',position,...
    'backgroundcolor',get(h.fig,'color'),'Visible','off');

%% Children of panel
    
    panelParent = h.phaseUnwrap.panel.ROMEOTotalField;

    % width of each element in a functional column, in normalised unit
    wratio = 0.5;
    
    krow = 1;
    % row 1, left
    % MCPC-3D-S phase offset correction popup
    methodOffsetCorrect = {'Off', 'On', 'Bipolar (>= 3 echoes)'};
    [h.phaseUnwrap.ROMEOTotalField.text.offsetCorrect,h.phaseUnwrap.ROMEOTotalField.popup.offsetCorrect] = sepia_construct_text_popup(...
        panelParent,'MCPC-3D-S phase offset correction:', methodOffsetCorrect, [left(1) bottom(krow) width height], wratio);
    
    % row 1, right
    % eddy current correction for bipolar readout, 'checkbox' functional
    h.phaseUnwrap.ROMEOTotalField.checkbox.eddyCorrect = uicontrol('Parent',panelParent ,...
        'Style','checkbox','String','SEPIA Bipolar readout correction (alternative to MPCP-3D-S bipolar)',...
        'units','normalized','Position',[left(2) bottom(krow) width height],...
        'backgroundcolor',get(h.fig,'color'));
    
    krow = krow + 1;
    % row 2, left
    % Mask used for ROMEO
    methodMask = {'SEPIA mask', 'ROMEO robustmask', 'ROMEO qualitymask', 'No Mask'};
    [h.phaseUnwrap.ROMEOTotalField.text.mask,h.phaseUnwrap.ROMEOTotalField.popup.mask] = sepia_construct_text_popup(...
        panelParent,'Mask for unwrapping:', methodMask, [left(1) bottom(krow) width/2 height], wratio);
    % Threshold setting for qualitymask
    qualitymaskDefaultThreshold = 0.5;
    h.phaseUnwrap.ROMEOTotalField.edit.qualitymaskThreshold = uicontrol('Parent',panelParent ,...
        'Style','edit',...
        'String',num2str(qualitymaskDefaultThreshold),...
        'units','normalized','position',[left(1)+0.4 bottom(krow) 0.04 height],...
        'backgroundcolor','white',...
        'Enable','off');
    % use romeo mask
    h.phaseUnwrap.ROMEOTotalField.checkbox.useRomeoMask = uicontrol('Parent',panelParent ,...
        'Style','checkbox','String','Use ROMEO Mask in SEPIA',...
        'units','normalized','position',[left(2) bottom(krow) width/2 height],...
        'backgroundcolor',get(h.fig,'color'),...
        'Enable','on');
    
    % row 2, right
    % save unwrapped echo phase option, 'checkbox'
    h.phaseUnwrap.ROMEOTotalField.checkbox.saveEchoPhase = uicontrol('Parent',panelParent ,...
        'Style','checkbox','String','Save unwrapped echo phase',...
        'units','normalized','position',[left(2)+width/2 bottom(krow) width/2 height],...
        'backgroundcolor',get(h.fig,'color'),...
        'Enable','on');
    
    % row 3
    krow = krow + 1;
    % exclusion of unreliable voxels, 'checkbox|field|text|popup'
    h.phaseUnwrap.ROMEOTotalField.checkbox.excludeMask = uicontrol('Parent',panelParent ,...
        'Style','checkbox','String','Exclude voxels using residual, threshold:',...
        'units','normalized','position',[left(1) bottom(krow) 0.4 height],...
        'backgroundcolor',get(h.fig,'color'),...
        'Enable','off');
    h.phaseUnwrap.ROMEOTotalField.edit.excludeMask = uicontrol('Parent',panelParent ,...
        'Style','edit',...
        'String',num2str(defaultThreshold),...
        'units','normalized','position',[left(1)+0.4 bottom(krow) 0.04 height],...
        'backgroundcolor','white',...
        'Enable','off');
    % excluding method
    h.phaseUnwrap.ROMEOTotalField.text.excludeMethod = uicontrol('Parent',panelParent ,...
        'Style','text','String','and apply in ',...
        'units','normalized','position',[left(1)+0.46 bottom(krow) 0.1 height],...
        'HorizontalAlignment','left',...
        'backgroundcolor',get(h.fig,'color'));
    h.phaseUnwrap.ROMEOTotalField.popup.excludeMethod = uicontrol('Parent',panelParent ,...
        'Style','popup',...
        'String',methodExcludedName,...
        'Enable','off',...
        'units','normalized','position',[left(1)+0.56 bottom(krow) 0.23 height]); 
    

%% set tooltips
set(h.phaseUnwrap.ROMEOTotalField.checkbox.excludeMask,      'Tooltip',tooltip.unwrap.panel.exclude);
set(h.phaseUnwrap.ROMEOTotalField.edit.excludeMask,          'Tooltip',tooltip.unwrap.panel.exclude_edit);

%% set callbacks
set(h.phaseUnwrap.ROMEOTotalField.checkbox.excludeMask,     'Callback', {@CheckboxEditPair_Callback,{h.phaseUnwrap.ROMEOTotalField.edit.excludeMask,h.phaseUnwrap.ROMEOTotalField.popup.excludeMethod},1});
set(h.phaseUnwrap.ROMEOTotalField.edit.excludeMask,         'Callback', {@EditInputMinMax_Callback,defaultThreshold,0,0,1});
set(h.phaseUnwrap.ROMEOTotalField.edit.qualitymaskThreshold,'Callback', {@EditInputMinMax_Callback,defaultThreshold,0,0,1});
set(h.phaseUnwrap.ROMEOTotalField.popup.mask,               'Callback', {@romeo_mask_selection_Callback,h});

% Enable exlude options 
set(h.phaseUnwrap.ROMEOTotalField.checkbox.excludeMask, 'Enable', 'on', 'Value', 0);
set(h.phaseUnwrap.ROMEOTotalField.edit.excludeMask,     'Enable', 'off');
set(h.phaseUnwrap.ROMEOTotalField.popup.excludeMethod,  'Enable', 'off');
set(h.phaseUnwrap.ROMEOTotalField.checkbox.useRomeoMask,'Enable', 'off')

end

%% Callback functions
function romeo_mask_selection_Callback(source,eventdata,h)
    if strcmp(source.String{source.Value,1}, 'ROMEO qualitymask')
       set(h.phaseUnwrap.ROMEOTotalField.edit.qualitymaskThreshold, 'Enable', 'on');
    else
        set(h.phaseUnwrap.ROMEOTotalField.edit.qualitymaskThreshold, 'Enable', 'off');
    end
    
    if strcmp(source.String{source.Value,1}, 'ROMEO qualitymask') || strcmp(source.String{source.Value,1}, 'ROMEO robustmask')
        set(h.phaseUnwrap.ROMEOTotalField.checkbox.useRomeoMask, 'Enable', 'on')
    else
        set(h.phaseUnwrap.ROMEOTotalField.checkbox.useRomeoMask, 'Enable', 'off', 'Value', false);
    end
end
