%% h = sepia_handle_panel_unwrap_optimum_weights(hParent,h,position)
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
% Description: This GUI function creates a panel for LBV method
%
% Kwok-shing Chan @ DCCN
% k.chan@donders.ru.nl
% Date created: 11 June 2021 (v1.0)
% Date modified: 
%
%
function h = sepia_handle_panel_EchoCombine_optimum_weights(hParent,h,position)
% set up method name displayed on GUI
sepia_universal_variables;

%% set default values
defaultThreshold = 0.5;

%% Tooltips
% tooltips
tooltip.unwrap.panel.unwrap         = 'Select a phase unwrapping algorithm for spatial unwrapping';
tooltip.unwrap.panel.eddy           = 'Correct phase offset between odd and even number echoes if bipolar readout was used in acquisition';
tooltip.unwrap.panel.exclude        = ['Apply threshold on relative residual to exclude unreliable voxels based on ',...
                                        'mono-exponential decay model (only available for non-Laplacian methods)'];
tooltip.unwrap.panel.exclude_edit	= ['Higher value means accepting larger error between the data fitting and measurement'];
tooltip.unwrap.panel.saveUnwrap     = ['If total field is computed using optimal weights combination with multi-echo data, ',...
                                        'it is possible to save the unwrapped phase for each echo.'];

%% layout of the panel
nrow        = 3;
rspacing    = 0.01;
ncol        = 2;
cspacing    = 0.01;
[height,bottom,width,left] = sepia_layout_measurement(nrow,rspacing,ncol,cspacing);

%% Parent handle of children panel 

h.phaseUnwrap.panel.OptimumWights = uipanel(hParent,...
    'Title','Optimum weights',...
    'position',position,...
    'backgroundcolor',get(h.fig,'color'),'Visible','on');

%% Children of TKD panel
    
    panelParent = h.phaseUnwrap.panel.OptimumWights;

    % width of each element in a functional column, in normalised unit
    wratio = 0.5;
    
    % row 1, left 
    krow = 1;
    % phase unwrapping method, 'text|popup' 
    [h.phaseUnwrap.optimumWeights.text.phaseUnwrap,h.phaseUnwrap.optimumWeights.popup.phaseUnwrap] = sepia_construct_text_popup(...
        panelParent,'Phase unwrapping:', methodUnwrapName, [left(1) bottom(krow) width height], wratio);
    
    % row 2, left
    krow = 2;
    % eddy current correction for bipolar readout, 'checkbox' functional
    h.phaseUnwrap.optimumWeights.checkbox.eddyCorrect = uicontrol('Parent',panelParent ,...
        'Style','checkbox','String','Bipolar readout correction',...
        'units','normalized','Position',[left(1) bottom(krow) width height],...
        'backgroundcolor',get(h.fig,'color'));
    
    % row 2, right
    % save unwrapped echo phase option, 'checkbox', 3th row
    h.phaseUnwrap.optimumWeights.checkbox.saveEchoPhase = uicontrol('Parent',panelParent ,...
        'Style','checkbox','String','Save unwrapped echo phase',...
        'units','normalized','position',[left(2) bottom(krow) width height],...
        'backgroundcolor',get(h.fig,'color'),...
        'Enable','on');
    
    % row 3
    krow = 3;
    % exclusion of unreliable voxels, 'checkbox|field|text|popup'
    h.phaseUnwrap.optimumWeights.checkbox.excludeMask = uicontrol('Parent',panelParent ,...
        'Style','checkbox','String','Exclude voxels using residual, threshold:',...
        'units','normalized','position',[left(1) bottom(krow) 0.4 height],...
        'backgroundcolor',get(h.fig,'color'),...
        'Enable','off');
    h.phaseUnwrap.optimumWeights.edit.excludeMask = uicontrol('Parent',panelParent ,...
        'Style','edit',...
        'String',num2str(defaultThreshold),...
        'units','normalized','position',[left(1)+0.4 bottom(krow) 0.04 height],...
        'backgroundcolor','white',...
        'Enable','off');
    % excluding method
    h.phaseUnwrap.optimumWeights.text.excludeMethod = uicontrol('Parent',panelParent ,...
        'Style','text','String','and apply in ',...
        'units','normalized','position',[left(1)+0.46 bottom(krow) 0.1 height],...
        'HorizontalAlignment','left',...
        'backgroundcolor',get(h.fig,'color'));
    h.phaseUnwrap.optimumWeights.popup.excludeMethod = uicontrol('Parent',panelParent ,...
        'Style','popup',...
        'String',methodExcludedName,...
        'Enable','off',...
        'units','normalized','position',[left(1)+0.56 bottom(krow) 0.23 height]); 
    

%% set tooltips
set(h.phaseUnwrap.optimumWeights.text.phaseUnwrap,          'Tooltip',tooltip.unwrap.panel.unwrap);
set(h.phaseUnwrap.optimumWeights.checkbox.eddyCorrect,      'Tooltip',tooltip.unwrap.panel.eddy);
set(h.phaseUnwrap.optimumWeights.checkbox.excludeMask,      'Tooltip',tooltip.unwrap.panel.exclude);
set(h.phaseUnwrap.optimumWeights.edit.excludeMask,          'Tooltip',tooltip.unwrap.panel.exclude_edit);
set(h.phaseUnwrap.optimumWeights.checkbox.saveEchoPhase,    'Tooltip',tooltip.unwrap.panel.saveUnwrap);

%% set callbacks
set(h.phaseUnwrap.optimumWeights.checkbox.excludeMask,	'Callback', {@CheckboxEditPair_Callback,{h.phaseUnwrap.optimumWeights.edit.excludeMask,h.phaseUnwrap.optimumWeights.popup.excludeMethod},1});
set(h.phaseUnwrap.optimumWeights.edit.excludeMask,      'Callback', {@EditInputMinMax_Callback,defaultThreshold,0,0,1});
set(h.phaseUnwrap.optimumWeights.popup.phaseUnwrap,     'Callback', {@popupPhaseUnwrap_Callback,h});

end

%% Callback functions
% Phase unwrapping method specific panel setting
function popupPhaseUnwrap_Callback(source,eventdata,h)

sepia_universal_variables;

% get selected background removal method
method = source.String{source.Value,1} ;

% Reset the option 
set(h.phaseUnwrap.optimumWeights.checkbox.excludeMask, 'Enable', 'off', 'Value', 0);
set(h.phaseUnwrap.optimumWeights.edit.excludeMask,     'Enable', 'off');
set(h.phaseUnwrap.optimumWeights.popup.excludeMethod,  'Enable', 'off');
% method the user chosen will affect if exclusion method can be used or not 
for k = 1:length(methodUnwrapName)
    if strcmpi(method,methodUnwrapName{k})
        set(h.phaseUnwrap.optimumWeights.checkbox.excludeMask, 'Enable', gui_unwrap_exclusion{k});
    end
end

end