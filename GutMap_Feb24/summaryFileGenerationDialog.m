%#################################
% GutMap 2014-2024
%#################################
function varargout = summaryFileGenerationDialog(varargin)
% SUMMARYFILEGENERATIONDIALOG MATLAB code for summaryFileGenerationDialog.fig
%		Generates a dialog box to determine the save location for a new summary file.
%
%      SUMMARYFILEGENERATIONDIALOG, by itself, creates a new SUMMARYFILEGENERATIONDIALOG or raises the existing
%      singleton*.
%
%      H = SUMMARYFILEGENERATIONDIALOG returns the handle to a new SUMMARYFILEGENERATIONDIALOG or the handle to
%      the existing singleton*.
%
%      SUMMARYFILEGENERATIONDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SUMMARYFILEGENERATIONDIALOG.M with the given input arguments.
%
%      SUMMARYFILEGENERATIONDIALOG('Property','Value',...) creates a new SUMMARYFILEGENERATIONDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before summaryFileGenerationDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to summaryFileGenerationDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help summaryFileGenerationDialog

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @summaryFileGenerationDialog_OpeningFcn, ...
                   'gui_OutputFcn',  @summaryFileGenerationDialog_OutputFcn, ...
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


% --- Executes just before summaryFileGenerationDialog is made visible.
function summaryFileGenerationDialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to summaryFileGenerationDialog (see VARARGIN)

% Choose default command line output for summaryFileGenerationDialog
handles.output = hObject;

% Obtains parent window
parentInput = find(strcmp(varargin, 'Parent'));
if ~isempty(parentInput)
    handles.parent = varargin{parentInput + 1};
else
    disp('Error: Heatmap generation dialog not opened. No parent window found.');
    delete(handles.output);
    return
end

vData = get(findobj(handles.parent.output, 'Tag', 'videoList'), 'UserData');
vNumber = get(findobj(handles.parent.output, 'Tag', 'videoList'), 'Value');

set(findobj(handles.output, 'Tag', 'filenameText'), 'String', vData{vNumber}.fileName);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes summaryFileGenerationDialog wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = summaryFileGenerationDialog_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;



function pathnameText_Callback(hObject, eventdata, handles)

function pathnameText_CreateFcn(hObject, eventdata, handles)
set(hObject, 'String', pwd)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function filenameText_Callback(hObject, eventdata, handles)

function filenameText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function directoryButton_Callback(hObject, eventdata, handles)
% Update the directory to save the new file in once user picks one

pathnameText = findobj(handles.output, 'Tag', 'pathnameText');
newDirectory = uigetdir(get(pathnameText, 'String'), 'Choose a save location');
if exist('newDirectory', 'var')
    set(pathnameText, 'String', newDirectory);
end

function startButton_Callback(hObject, eventdata, handles)
% Adds file to the queue for edge detection

% Constructs the full file name
pathname = [get(findobj(handles.output, 'Tag', 'pathnameText'), 'String') filesep];
filename =  get(findobj(handles.output, 'Tag', 'filenameText'), 'String');
extension = '.gmp';
savename = {pathname, filename, extension};

% If the file already exists, confirm overwriting it
if exist([pathname filename extension],'file')
    confirmation = overwriteDialog('Location', [pathname filename extension]);
else
    confirmation = 'Yes';
end

% Proceed if allowed to continue
if strcmp(confirmation, 'Yes')

	% If queue isn't open, open a window and begin a new queue
    queueHandle = findall(0, 'Name', 'summaryQueue');
    if isempty(queueHandle)
        summaryQueue('Parent', handles.parent.output, 'OutputName', savename)
    else
		% Otherwise, update the queue to include the new file.
        qList = findobj(queueHandle, 'Tag', 'queueFiles');
        existingNames = get(qList, 'String');
        set(qList, 'String', [existingNames(:); {[savename{1}, savename{2}, savename{3}]}]);
        
		% Obtain region of interest and marker position
        ROI = get(findobj(handles.parent.output, 'Tag', 'regionOfInterest'), 'Position');
        region = [ROI(1), ROI(1) + ROI(3), ROI(2), ROI(2) + ROI(4)];
        
		% Include video object and video parameters
        vList = findobj(handles.parent.output, 'Tag', 'videoList');
        vNumber = get(vList, 'Value');
        vData = get(vList, 'UserData');
        video = vData{vNumber}.video;
        
        k = exp(get(findobj(handles.parent.output, 'Tag', 'contrastSlider'), 'Value')/10);
        b = uint8(2.56 * get(findobj(handles.parent.output, 'Tag', 'brightnessSlider'), 'Value'));
        d = str2double(get(findobj(handles.parent.output, 'Tag', 'frameWidth'), 'String'));
        es = str2double(get(findobj(handles.parent.output, 'Tag', 'edit_EdgeSmooth'), 'String'));

		% Store new data
        existingData = get(qList, 'UserData');
        set(qList, 'UserData', [existingData(:); struct('video', video, ...
                                  'region', region, ...
                                  'contrast', k, ...
                                  'brightness', b, ...
                                  'dist', d, 'esmooth', es )]);
                                  
    end
    close(handles.output);
end

function cancelButton_Callback(hObject, eventdata, handles)
delete(handles.output)

