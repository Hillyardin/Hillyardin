%#################################
% GutMap 2014-2024
%#################################
function varargout = summaryQueue(varargin)
% SUMMARYQUEUE MATLAB code for summaryQueue.fig
%		Generates a window in which a queue of files to be subjected to edge
%		detection are stored. Upon execution, the results of the detection
%		process are fed into the window.
%
%      SUMMARYQUEUE, by itself, creates a new SUMMARYQUEUE or raises the existing
%      singleton*.
%
%      H = SUMMARYQUEUE returns the handle to a new SUMMARYQUEUE or the handle to
%      the existing singleton*.
%
%      SUMMARYQUEUE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SUMMARYQUEUE.M with the given input arguments.
%
%      SUMMARYQUEUE('Property','Value',...) creates a new SUMMARYQUEUE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before summaryQueue_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to summaryQueue_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help summaryQueue

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @summaryQueue_OpeningFcn, ...
                   'gui_OutputFcn',  @summaryQueue_OutputFcn, ...
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


% --- Executes just before summaryQueue is made visible.
function summaryQueue_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to summaryQueue (see VARARGIN)

% Choose default command line output for summaryQueue
handles.output = hObject;

parentInput = find(strcmp(varargin, 'Parent'));
if ~isempty(parentInput)
    handles.parent = varargin{parentInput + 1};
else
    disp('Error: Queue not opened. No parent window found.');
    delete(handles.output);
    return
end

% Obtains the new location for the summary file to be saved to
saveInput = find(strcmp(varargin, 'OutputName'));
if ~isempty(saveInput)
    saveName = varargin{saveInput + 1};
    
	% Obtains region of interest and marker position
    ROI = get(findobj(handles.parent, 'Tag', 'regionOfInterest'), 'Position');
    region = [ROI(1), ROI(1) + ROI(3), ROI(2), ROI(2) + ROI(4)];

	% Obtains video parameters for the edge detection process
    vList = findobj(handles.parent, 'Tag', 'videoList');
    vNumber = get(vList, 'Value');
    vData = get(vList, 'UserData');
    video = vData{vNumber}.video;
    
    k = exp(get(findobj(handles.parent, 'Tag', 'contrastSlider'), 'Value')/10);
    b = uint8(2.56 * get(findobj(handles.parent, 'Tag', 'brightnessSlider'), 'Value'));
    d = str2double(get(findobj(handles.parent, 'Tag', 'frameWidth'), 'String'));
    es = str2double(get(findobj(handles.parent, 'Tag', 'edit_EdgeSmooth'),'String'));
    
	% Stores the video and all of its parameters
    qList = findobj(handles.output, 'Tag', 'queueFiles');
    set(qList, 'String', {[saveName{1} saveName{2} saveName{3}]});
    set(qList, 'UserData', struct('video', video, ...
                                  'region', region, ...
                                  'contrast', k, ...
                                  'brightness', b, ...
                                  'dist', d, 'esmooth',es));

else
    disp('Error: Queue not opened. No output file name found.');
    delete(handles.output);
    return
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes summaryQueue wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = summaryQueue_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in exitButton.
function exitButton_Callback(hObject, eventdata, handles)
% hObject    handle to exitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.output)

% --- Executes on button press in beginButton.
function beginButton_Callback(hObject, eventdata, handles)
% hObject    handle to beginButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Reset completion in dialog box
set(findobj(findall(0, 'Name', 'waitDialog'), 'Tag', 'queueCompletion'), 'String', '0%');
drawnow();

% Disable reclicking button and obtain data
set(findobj(handles.output, 'Tag', 'beginButton'), 'Enable', 'off');
qList = findobj(handles.output, 'Tag', 'queueFiles');
qFiles = get(qList, 'String');
qData = get(qList, 'UserData');

N = length(qFiles);

% Initialise results text
rList = findobj(handles.output, 'Tag', 'resultsList');
set(rList, 'String', {'Queue begun!'});
drawnow();

% Perform analysis on each file in queue
waitDialog;
for i = 1 : length(qFiles)
    saveNameCell = qFiles(i);
    scribble3(qData(i), saveNameCell{1}, rList,qList.UserData(i).esmooth)
    set(findobj(findall(0, 'Name', 'waitDialog'), 'Tag', 'queueCompletion'), 'String', [sprintf('%d', round(100*i/N)) '%']);
    drawnow();
end

% Terminate results text and close wait dialog box
rString = get(rList, 'String');
set(rList, 'String', [rString(:); {'Queue Completed!'}]);
drawnow();

waitHandle = findall(0, 'Name', 'waitDialog');
if ~isempty(waitHandle)
    close(waitHandle)
end

% --- Executes on selection change in resultsList.
function resultsList_Callback(hObject, eventdata, handles)
% hObject    handle to resultsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns resultsList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from resultsList


% --- Executes during object creation, after setting all properties.
function resultsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resultsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in queueFiles.
function queueFiles_Callback(hObject, eventdata, handles)
% hObject    handle to queueFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns queueFiles contents as cell array
%        contents{get(hObject,'Value')} returns selected item from queueFiles


% --- Executes during object creation, after setting all properties.
function queueFiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to queueFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
