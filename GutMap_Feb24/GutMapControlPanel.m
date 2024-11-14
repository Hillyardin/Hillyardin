%#################################
% GutMap 2014-2024
%#################################

function varargout = GutMapControlPanel(varargin)
%	   This control panel is the first window opened by the GutMap command. It is used to
%      provide the user with an option to enter either the Edge Detection or Heatmap Analysis
%	   control panels, or to exit the program.
%
%      GutMapCONTROLPANEL, by itself, creates a new GutMapCONTROLPANEL or raises the existing
%      singleton*.
%
%      H = GutMapCONTROLPANEL returns the handle to a new GutMapCONTROLPANEL or the handle to
%      the existing singleton*.
%
%      GutMapCONTROLPANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GutMapCONTROLPANEL.M with the given input arguments.
%
%      GutMapCONTROLPANEL('Property','Value',...) creates a new GutMapCONTROLPANEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GutMapControlPanel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GutMapControlPanel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%

% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GutMapControlPanel

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GutMapControlPanel_OpeningFcn, ...
                   'gui_OutputFcn',  @GutMapControlPanel_OutputFcn, ...
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


% --- Executes just before GutMapControlPanel is made visible.
function GutMapControlPanel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GutMapControlPanel (see VARARGIN)

% Choose default command line output for GutMapControlPanel
handles.output = hObject;

% Update GutMap version name on the control panel
GMVersionString = ['Version: February 2024'];
handles.panelTitle.String{2} = GMVersionString;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GutMapControlPanel wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GutMapControlPanel_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in analyseHeatmapButton.
function analyseHeatmapButton_Callback(hObject, eventdata, handles)
% Upon click, this button hides the home window, and opens the Heatmap Analysis window.

% hObject    handle to analyseHeatmapButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.output, 'Visible', 'off');
heatmapAnalysisControlPanel('Home', handles.output);


% --- Executes on button press in generateHeatmapButton.
function generateHeatmapButton_Callback(hObject, eventdata, handles)
% Upon click, this button hides the home window, and opens the Edge Detection window.

% hObject    handle to generateHeatmapButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.output, 'Visible', 'off');
edgeDetectionControlPanel('Home', handles.output);


% --- Executes on button press in exitButton.
function exitButton_Callback(hObject, eventdata, handles)
% Upon click, this button terminates the program by closing the window.
% hObject    handle to exitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.output)
