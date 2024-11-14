%#################################
% GutMap 2014-2024
%#################################

function varargout = edgeDetectionControlPanel(varargin)
% This is the help text for the Edge Detection module of GutMap.
%
%   'What am I looking at?'
%
% The window with the title 'edgeDetectionControlPanel' is a subprogram of
% the program GutMap, which you ran from the command prompt. The function of
% this module is to detect edges in video files, and to bring the
% information that is important for gut motility studies into a more
% compressed format. From this window, you the user are able to scroll
% through any of the videos you have added, and adjust the contrast and
% brightness of the video as you see fit. Once you are happy with the clean
% edges in your video, you can then select the region in the video you are
% interested in, and begin generating a 'heatmap'.
%
%   'How do I actually do those things?'
%
% To get started, all you have to do is have the window selected, and
% either go to the 'Add files' menu and select 'Add Video...'. 
% This will allow you to choose a video with the extension .avi, and will add
% it the the list of available videos on the screen. Then click on the name
% of the video to see a preview! You should see the first frame of the
% video, and some stats appear, as well as the controls on the right
% becoming enabled. As an alternative, you can add a whole folder of
% videos, but this will take some time.
%
% To scroll through the video, you can move the top slider, labelled 'Time
% in video' left and right. As a warning, sometimes clicking too fast on
% the left or right arrows generates an error. If the video doesn't seem to
% be changing, this may be a symptom. Try reclicking on the video name to
% refresh the preview.
%
% Sliding the contrast and brightness bars is straightforward enough, and
% the changes are applied to the whole video frame. By specifying the frame
% width in mm, it allows the scale of the heatmap generated to be 
% automatically determined.
%
% Once you have picked settings you're happy with, drag a rectangle across
% the video preview to select a region of interest. The pixel dimensions of 
% the selection will appear in the box above it, and the edges should be
% clearly visible; green on top and red beneath the gut. 
%
% From there, click on the 'Generate Heatmap' button at the bottom to open
% a new window, asking you to select a save location. 

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @edgeDetectionControlPanel_OpeningFcn, ...
                   'gui_OutputFcn',  @edgeDetectionControlPanel_OutputFcn, ...
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


% --- Executes just before edgeDetectionControlPanel is made visible.
function edgeDetectionControlPanel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to edgeDetectionControlPanel (see VARARGIN)

% Choose default command line output for edgeDetectionControlPanel
handles.output = hObject;

homeInput = find(strcmp(varargin, 'Home'));
if ~isempty(homeInput)
    handles.homePanel = varargin{homeInput + 1};
else
    disp('Error: Edge detection control panel not opened. No home window found.');
    delete(handles.output);
    return
end

oldPosition = get(hObject, 'Position');
homePosition = get(handles.homePanel, 'Position');
xleft = round(homePosition(1) + homePosition(3)/2 - oldPosition(3)/2);
ybot  = round(homePosition(2) + homePosition(4) - oldPosition(4) - 20);
newPosition = [xleft ybot oldPosition(3) oldPosition(4)];
set(hObject, 'Position', newPosition);
% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%


% UIWAIT makes edgeDetectionControlPanel wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = edgeDetectionControlPanel_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function generateAnalyseButton_Callback(hObject, eventdata, handles)

set(handles.homePanel, 'Visible', 'on');
heatmapAnalysisControlPanel('Home', handles.homePanel);

function homeButton_Callback(hObject, eventdata, handles)
set(handles.homePanel, 'Visible', 'on');
close(handles.output);

function videoList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function brightnessSlider_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function timeSlider_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function contrastSlider_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function figure1_CloseRequestFcn(hObject, eventdata, handles)

if isvalid(handles.homePanel)
    if strcmp(get(handles.homePanel, 'Visible'), 'off');
        delete(handles.homePanel);
    end
end;
delete(hObject);

function brightnessSlider_Callback(hObject, eventdata, handles)
% Update image and preview
set(hObject, 'Value', round(get(hObject, 'Value')));
set(findobj(handles.output, 'Tag', 'brightnessNumber'), 'String', get(hObject, 'Value'));
video_callback('Preview edges', handles.output);

function videoList_Callback(hObject, eventdata, handles)
% Update image and video stats
if ~isempty(get(hObject, 'UserData'))
    graphing_callback('Update video stats', handles.output);
    video_callback('Update video of interest', handles.output,handles);
end

function timeSlider_Callback(hObject, eventdata, handles)
% Update image and preview
set(hObject, 'Value', round(get(hObject, 'Value')));
set(findobj(handles.output, 'Tag', 'timeNumber'), 'String', get(hObject, 'Value'));
video_callback('Preview edges', handles.output);

set(handles.edit_BoxWidth,'Enable','on');
set(handles.edit_BoxHeight,'Enable','on');
set(handles.edit_BoxLeft,'Enable','on');
set(handles.edit_BoxTop,'Enable','on');
set(handles.ClearBoxButton,'Enable','on');

% Obtain the handles to the structs containing video objects
vList = findobj(handles.output, 'Tag', 'videoList');
vNumber = get(vList, 'Value');
vData = get(vList, 'UserData');

% Obtain parameters of video
frameRate  = vData{vNumber}.video.FrameRate;

currSecs = round(get(hObject,'Value') / frameRate,1);

set(handles.timeSeconds,'String',[num2str(currSecs),' Secs']);




function generateButton_Callback(hObject, eventdata, handles)
% If a queue has not been recently executed, open a generation dialog
if ~isempty(get(findobj(handles.output, 'Tag', 'videoList'), 'UserData'))
    
    queueHandle = findall(0, 'Name', 'summaryQueue');
    if isempty(queueHandle)
        summaryFileGenerationDialog('Parent', handles)
    elseif strcmp(get(findobj(queueHandle, 'tag', 'beginButton'), 'Enable'), 'on')
        summaryFileGenerationDialog('Parent', handles)
    else
        figure(queueHandle);
    end
end

function contrastSlider_Callback(hObject, eventdata, handles)
% Update image and preview
set(hObject, 'Value', round(get(hObject, 'Value')));
set(findobj(handles.output, 'Tag', 'contrastNumber'), 'String', get(hObject, 'Value'));
video_callback('Preview edges', handles.output);

function aboutButton_Callback(hObject, eventdata, handles)
msgbox({'GutMap: Edge Detection'; '';...
        'Authors: Matthew Zygorodimos and Leigh Johnston'; ...
        'Last modified: 11 September 2020'; ...
        'Contact details: l.johnston@unimelb.edu.au'},'About');

function howToButton_Callback(hObject, eventdata, handles)
help edgeDetectionControlPanel


function addVideo_Callback(hObject, eventdata, handles)
io_callback('Add video', handles.output)

function addVideoDir_Callback(hObject, eventdata, handles)
io_callback('Add video directory', handles.output)



function frameWidth_Callback(hObject, eventdata, handles)
% hObject    handle to frameWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frameWidth as text
%        str2double(get(hObject,'String')) returns contents of frameWidth as a double
if isempty(get(handles.frameWidth,'String'))
    
    uiwait(msgbox('Resolution cannot be empty, therefore will reeset to default value. Press Calibrate button to perform calibration.',...
                'Empty Resolution','modal'));
    set(handles.frameWidth,'String','0.1');
end;

% --- Executes during object creation, after setting all properties.
function frameWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frameWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_EdgeSmooth_Callback(hObject, eventdata, handles)
% hObject    handle to edit_EdgeSmooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
esmooth = str2double(get(hObject, 'String'));
if (esmooth <= 0) 
    hh = warndlg('Edge Smooth must be positive','Edge Smooth');
    set(hObject,'String','60');
end;
video_callback('Preview edges', handles.output);


% --- Executes on button press in CalibrateButton.
function CalibrateButton_Callback(hObject, eventdata, handles)
% hObject    handle to CalibrateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currf = figure;
ff = get(handles.previewAxes,'Children');
ffi = findobj(ff,'Tag','previewImage');
CurrentImage = ffi.CData;
imagesc(CurrentImage);
axis image;
colormap gray;

h = uicontrol('Position',[10 400 430 15],'BackgroundColor',[1 0.7 0],'String',...
    'Zoom in on calibration region, then press this button and enter two points 1cm apart.',...
            'Callback','uiresume(gcbf)');
uiwait(gcf);

if ~isempty(findobj(currf))

    try
        [xx,yy] = ginput(2);
        NumPixels = sqrt((xx(2) - xx(1))^2 + (yy(2) - yy(1))^2);
        mmPerPixel = 10 / NumPixels;
        set(handles.frameWidth,'String',num2str(mmPerPixel));

        close(currf);
    end;
end;


function edit_BoxWidth_Callback(hObject, eventdata, handles)
% hObject    handle to edit_BoxWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_BoxWidth as text
%        str2double(get(hObject,'String')) returns contents of edit_BoxWidth as a double
try
    UpdateBox(handles);
end;


function edit_BoxHeight_Callback(hObject, eventdata, handles)
% hObject    handle to edit_BoxHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_BoxHeight as text
%        str2double(get(hObject,'String')) returns contents of edit_BoxHeight as a double
try
    UpdateBox(handles);
end;


function edit_BoxLeft_Callback(hObject, eventdata, handles)
% hObject    handle to edit_BoxLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_BoxLeft as text
%        str2double(get(hObject,'String')) returns contents of edit_BoxLeft as a double
try
    UpdateBox(handles);
end;


function edit_BoxTop_Callback(hObject, eventdata, handles)
% hObject    handle to edit_BoxTop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_BoxTop as text
%        str2double(get(hObject,'String')) returns contents of edit_BoxTop as a double
try
    UpdateBox(handles);
end;

% --- Executes on button press in ClearBoxButton.
function ClearBoxButton_Callback(hObject, eventdata, handles)
% hObject    handle to ClearBoxButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.edit_BoxWidth,'String','');
set(handles.edit_BoxHeight,'String','');
set(handles.edit_BoxLeft,'String','');
set(handles.edit_BoxTop,'String','');
delete(findall(handles.output, 'Tag', 'regionOfInterest'));
video_callback('Preview edges', handles.output);
