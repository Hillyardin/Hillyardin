%#################################
% GutMap 2014-2024
%#################################% 

function varargout = heatmapAnalysisControlPanel(varargin)
% This is the help text for the Heatmap Analysis module of GutMap.
%
%
%   'What am I looking at?'
%
% The window with the title 'heatmapAnalysisControlPanel' is a subprogram
% of the program GutMap, which you ran from the command prompt. The function of
% this module is to allow intuitive access to the information
% contained in heatmaps, the color coded charts which contain information
% regarding gut width. From this window, you are able to access other
% windows which allow you to take cross-sectional cuts in the data, as well
% as the labelling of contraction waves.
%
%   'How do I actually do those things?'
%
% To get started, all you have to do is have the window selected, and
% either go to the 'Add files' menu and select 'Add Summary File...'. 
% This will allow you to choose files with extension .gmp (or older
% versions with .su2 and .su3), from the Edge Detection module of GutMap. 
% After selecting a file, or a whole folder through the 'Add folder' 
% option it will be added to the list of available files on the screen. 
% Click on the name of a file to see its heatmap.
% Some stats will appear, and the controls on the right will become enabled
% in addition to the color map in the main frame. Time is the horizontal
% axis, and gut position is vertical.
%
% From here, you can drag the black and blue lines in the 'Time' box to
% restrict the heatmap to a specified time in seconds, or fill in the boxes
% bneath these lines. The color scheme can be changed from the default red
% to blue form the 'Color Schemes' menu in the top bar, and the color scale
% can be modified by the numbers in the 'Color' box. A single change in the
% map can be reverted, and the 'Auto' option will return the color scheme
% to the first one produced. Locking the color range applies when you are
% looking at multiple files, as this stops the color range from changing
% when you change files.
%
% Once you have idenified a region of interest, 'Take Cross-Sections'
% allows you to take horizontal and vertical slices of the data in a new
% window. By clicking either of the 'Add' buttons a temporal or spatial
% cross section can be added, where temporal cross sections span time and
% so are horizontal, and spatial cross sections span the gut and so run
% vertically. The superimposed lines can be dragged across the map, but for
% now the plots won't update automatically on release, so you are required
% to click 'Update plots' to get the new graphs after dragging.
%
% 'Annotate contraction waves' allows you to draw lines over notable
% features in the plot, to obtain figures such as velocity, duration and
% location. Manual entry requires you to click the 'Manually annotate'
% button and then drag across the plot, while automatic annotation attempts
% to search for notable features. A table of these values are shown below
% the plot, and users can select annotations to remove.
% 

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @heatmapAnalysisControlPanel_OpeningFcn, ...
                   'gui_OutputFcn',  @heatmapAnalysisControlPanel_OutputFcn, ...
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


% --- Executes just before heatmapAnalysisControlPanel is made visible.
function heatmapAnalysisControlPanel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to heatmapAnalysisControlPanel (see VARARGIN)

% Choose default command line output for heatmapAnalysisControlPanel
handles.output = hObject;

% Find and store home window handle
homeInput = find(strcmp(varargin, 'Home'));
if ~isempty(homeInput)
    handles.homePanel = varargin{homeInput + 1};
else
    disp('Error: Heatmap analysis control panel not opened. No home window found.');
    delete(handles.output);
    return
end

% Set position nicely in line with home window
oldPosition = get(hObject, 'Position');
homePosition = get(handles.homePanel, 'Position');
xleft = round(homePosition(1) + homePosition(3)/2 - oldPosition(3)/2);
ybot  = round(homePosition(2) + homePosition(4) - oldPosition(4) - 20);
newPosition = [xleft ybot oldPosition(3) oldPosition(4)];
set(hObject, 'Position', newPosition);

% Set default zoom axes
zoomAxes = findobj(handles.output, 'Tag', 'zoomAxes');
z = get(zoomAxes, 'ZLim');
if max(z(:)) == 1
    axes(zoomAxes);
    
    leftSlider = line('XData', [0 0], 'YData' ,[0.1 0.9], 'lineWidth', 5, ...
         'ButtonDownFcn', {@zoom_callback, 'Left slider', handles.output}, ...
         'Tag', 'leftSlider');
    rightSlider = line([1 1], [0.1 0.9], 'lineWidth', 5, ...
         'ButtonDownFcn', {@zoom_callback, 'Right slider', handles.output}, ...
         'Tag', 'rightSlider');

    set(zoomAxes, 'ZLim', [0 2]);
    set(zoomAxes,'Color',[0.8 0.8 0.8]);
    set(zoomAxes,'Visible','on');
end

heatmapAxes = findobj(handles.output, 'Tag', 'heatmapAxes');

% Forbid zoom and pan
setAllowAxesZoom(zoom,zoomAxes,false);
setAllowAxesPan(pan,zoomAxes,false);
setAllowAxesZoom(zoom,heatmapAxes,false);
setAllowAxesPan(pan,heatmapAxes,false);
set(zoom, 'ActionPostCallback', {@zoom_callback, 'Update from figure', handles.output});
set(pan, 'ActionPostCallback', {@zoom_callback, 'Update from figure', handles.output});
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes heatmapAnalysisControlPanel wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = heatmapAnalysisControlPanel_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function backButton_Callback(hObject, eventdata, handles)
% Return to home window
set(handles.homePanel, 'Visible', 'on');
edgeDetectionControlPanel('Home', handles.homePanel);

function undoColor_Callback(hObject, eventdata, handles)
graphing_callback('Revert color', handles.output);

function autoColor_Callback(hObject, eventdata, handles)
graphing_callback('Auto color', handles.output);

function colorMin_Callback(hObject, eventdata, handles)
graphing_callback('Update colormap', handles.output);

function colorMin_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function colorMax_Callback(hObject, eventdata, handles)
graphing_callback('Update colormap', handles.output);

function colorMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colorMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function summaryList_Callback(hObject, eventdata, handles)
if ~isempty(get(hObject, 'UserData'))
    graphing_callback('Plot heatmap', handles.output);
end

function summaryList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to summaryList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function zoomMin_Callback(hObject, eventdata, handles)
zoom_callback(0, 0, 'Set left slider', handles.output);

function zoomMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zoomMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function zoomMax_Callback(hObject, eventdata, handles)
zoom_callback(0, 0, 'Set right slider', handles.output);

function zoomMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zoomMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(handles.homePanel, 'Visible'), 'off');
    delete(handles.homePanel);
end

% Hint: delete(hObject) closes the figure
delete(hObject);

function homeButton_Callback(hObject, eventdata, handles)
% hObject    handle to homeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.homePanel, 'Visible', 'on');
close(handles.output);

function newLabelButton_Callback(hObject, eventdata, handles)

function autoLabelButton_Callback(hObject, eventdata, handles)

function exportExcel_Callback(hObject, eventdata, handles)
io_callback('Export to Excel', handles.output);

function addSummary_Callback(hObject, eventdata, handles)
io_callback('Add summary', handles.output)

function aboutButton_Callback(hObject, eventdata, handles)
msgbox({'Analyse 2: Heatmap Analysis'; 'Allows you to inspect and compare heatmaps'; '';...
        'Author: Matthew Zygorodimos'; 'Last modified: 6th March 2014'; ...
        'Contact details: m.zygorodimos@gmail.com'},'About');
    
function howToButton_Callback(hObject, eventdata, handles)
help heatmapAnalysisControlPanel

function addSummaryDir_Callback(hObject, eventdata, handles)
io_callback('Add summary directory', handles.output)

function updateColorScheme(hObject, eventdata, handles)
checked = findall(findobj(handles.output, 'Tag', 'colorSchemes'), 'Checked', 'on');
set(checked(1), 'Checked', 'off');
set(hObject, 'Checked', 'on');
graphing_callback('New color scheme', handles.output);

function csButton_Callback(hObject, eventdata, handles)
% Obtain summary file data
sList = findobj(handles.output, 'Tag', 'summaryList');
sNumber = get(sList, 'Value');
sData   = get(sList, 'UserData');

% Obtain pixel coordinates of visible borders
sUnits  = sData{sNumber}.parameters;
XStep = sUnits(4);
YStep = sUnits(3);

imageHandle = findobj(handles.output, 'Tag', 'heatmapImage');
heatmapAxes = get(imageHandle, 'Parent');
XLims = get(heatmapAxes, 'XLim');
YLims = get(heatmapAxes, 'YLim');

M = size(get(imageHandle, 'CData'),1);
N = size(get(imageHandle, 'CData'),2);

Xmin = max(1,ceil(XLims(1)/XStep));
Xmax = min(floor(XLims(2)/XStep),N);
Ymin = max(1,ceil(YLims(1)/YStep));
Ymax = min(floor(YLims(2)/YStep),M);

% Open cross section panel
set(heatmapAxes, 'XLim', [Xmin Xmax] * XStep);
set(heatmapAxes, 'YLim', [Ymin Ymax] * YStep);
crossSectionPanel('Parent', handles.output, 'Limits', [Xmin Xmax; Ymin Ymax], ...
            'Units', [XStep YStep], 'HeatmapName', sList.String{sNumber});

function cwButton_Callback(hObject, eventdata, handles)
% Obtain summary file data
sList = findobj(handles.output, 'Tag', 'summaryList');
sNumber = get(sList, 'Value');
sData   = get(sList, 'UserData');

% Obtain pixel coordinates of visible borders
sUnits  = sData{sNumber}.parameters;
XStep = sUnits(4);
YStep = sUnits(3);

imageHandle = findobj(handles.output, 'Tag', 'heatmapImage');
heatmapAxes = get(imageHandle, 'Parent');
XLims = get(heatmapAxes, 'XLim');
YLims = get(heatmapAxes, 'YLim');

M = size(get(imageHandle, 'CData'),1);
N = size(get(imageHandle, 'CData'),2);

Xmin = max(1,ceil(XLims(1)/XStep));
Xmax = min(floor(XLims(2)/XStep),N);
Ymin = max(1,ceil(YLims(1)/YStep));
Ymax = min(floor(YLims(2)/YStep),M);

% Open contraction annotation panel
set(heatmapAxes, 'XLim', [Xmin Xmax] * XStep);
set(heatmapAxes, 'YLim', [Ymin Ymax] * YStep);
heatmapAnnotationPanel('Parent', handles.output, 'Limits', [Xmin Xmax; Ymin Ymax]);

function bindButton_Callback(hObject, eventdata, handles)
combineDialog('Parent', handles);

function compareButton_Callback(hObject, eventdata, handles)
sidebySidePanel('Parent', handles.output)

function differenceButton_Callback(hObject, eventdata, handles)



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
