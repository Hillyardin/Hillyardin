%#################################
% GutMap 2014-2024
%#################################
function varargout = heatmapAnnotationPanel(varargin)
% HEATMAPANNOTATIONPANEL MATLAB code for heatmapAnnotationPanel.fig
%		Generates a window that allows the region of interest in the current heatmap
%		to be annotated with lines marking contraction wave events.
%
%      HEATMAPANNOTATIONPANEL, by itself, creates a new HEATMAPANNOTATIONPANEL or raises the existing
%      singleton*.
%
%      H = HEATMAPANNOTATIONPANEL returns the handle to a new HEATMAPANNOTATIONPANEL or the handle to
%      the existing singleton*.
%
%      HEATMAPANNOTATIONPANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HEATMAPANNOTATIONPANEL.M with the given input arguments.
%
%      HEATMAPANNOTATIONPANEL('Property','Value',...) creates a new HEATMAPANNOTATIONPANEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before heatmapAnnotationPanel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to heatmapAnnotationPanel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help heatmapAnnotationPanel

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @heatmapAnnotationPanel_OpeningFcn, ...
                   'gui_OutputFcn',  @heatmapAnnotationPanel_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before heatmapAnnotationPanel is made visible.
function heatmapAnnotationPanel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to heatmapAnnotationPanel (see VARARGIN)

% Choose default command line output for heatmapAnnotationPanel
handles.output = hObject;

% Obtain values on the pixel border values
limitInput = find(strcmp(varargin, 'Limits'));
if ~isempty(limitInput)
    handles.limits = varargin{limitInput + 1};
else
    disp('Error: Cross section panel not opened. No parent limits found.');
    delete(handles.output);
    return
end

% Obtain and store the parent panel
parentInput = find(strcmp(varargin, 'Parent'));
if ~isempty(parentInput)
    handles.parent = varargin{parentInput + 1};
else
    disp('Error: Cross section panel not opened. No parent window found.');
    delete(handles.output);
    return
end

% Obtain color range
CMin = str2num(get(findobj(handles.parent, 'Tag', 'colorMin'), 'String'));
CMax = str2num(get(findobj(handles.parent, 'Tag', 'colorMax'), 'String'));

heatmapAxes = findobj(handles.output, 'Tag', 'heatmapAxes');

% Obtain axis limits
XLim = get(get(findobj(handles.parent, 'Tag', 'heatmapImage'), 'Parent'), 'XLim');
YLim = get(get(findobj(handles.parent, 'Tag', 'heatmapImage'), 'Parent'), 'YLim');

CData = get(findobj(handles.parent, 'Tag', 'heatmapImage'), 'CData');

Xlimits = handles.limits(1,:);
Ylimits = handles.limits(2,:);

% plot cropped image with scale and inherited colors
set(heatmapAxes, 'XLim', XLim, 'YLim', YLim);
imageHandle = imagesc(XLim, YLim, CData(Ylimits(1):Ylimits(2), Xlimits(1):Xlimits(2)), 'Parent', heatmapAxes, [CMin CMax]);
set(imageHandle, 'Tag', 'heatmapImage');

colormap('jet');
cmap = flipdim(colormap,1);     % Set hot colors to contracted and cool colors to dilated
colormap(cmap);
colorbar;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes heatmapAnnotationPanel wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = heatmapAnnotationPanel_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% --- Executes on button press in manualLabel.
function manualLabel_Callback(hObject, eventdata, handles)
contraction_callback('Create label', handles.output);


function autoLabel_Callback(hObject, eventdata, handles)
contraction_callback('Auto label', handles.output);


function labelTable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to labelTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
% handles    structure with handles and user data (see GUIDATA)
indices = eventdata.Indices;
tableData = get(hObject, 'Data');
lData     = get(findobj(handles.output, 'Tag', 'heatmapImage'), 'UserData');

% If name changed, store new name
if indices(2) == 1
    tableData{indices(1), 1} = eventdata.EditData;
    lData(indices(1)).name   = eventdata.EditData;
end

% If selection changed, store change and change color of line.
if indices(2) == 2
    lData(indices(1)).selected = eventdata.NewData;
    
    if lData(indices(1)).selected
        setColor(lData(indices(1)).line, 'r');
    else
        setColor(lData(indices(1)).line, 'b');
    end
    
end

set(hObject, 'Data', tableData);
set(findobj(handles.output, 'Tag', 'heatmapImage'), 'UserData', lData);

function labelTable_CreateFcn(hObject, eventdata, handles)
set(hObject, 'Data', {});


% --- Executes on button press in removeLabel.
function removeLabel_Callback(hObject, eventdata, handles)
% hObject    handle to removeLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tableData = get(findobj(handles.output, 'Tag', 'labelTable'), 'Data');
lData     = get(findobj(handles.output, 'Tag', 'heatmapImage'), 'UserData');

L = length(lData);

% Remove all selected labels
for i = L:-1:1
    if lData(i).selected
        delete(lData(i).line);
        lData = lData([1:i-1 i+1:end]);
        tableData = tableData([1:i-1 i+1:end], :);
    end
end

set(findobj(handles.output, 'Tag', 'heatmapImage'), 'UserData', lData);
set(findobj(handles.output, 'Tag', 'labelTable'), 'Data', tableData);

function updateButton_Callback(hObject, eventdata, handles)
contraction_callback('Populate labels', handles.output);
