%#################################
% GutMap 2014-2024
%#################################

function varargout = sidebySidePanel(varargin)
% SIDEBYSIDEPANEL MATLAB code for sidebySidePanel.fig
%		Generates a window which contains two axes for visual comparison of two separate
%		heatmaps, which also each have their own color controls.
%
%      SIDEBYSIDEPANEL, by itself, creates a new SIDEBYSIDEPANEL or raises the existing
%      singleton*.
%
%      H = SIDEBYSIDEPANEL returns the handle to a new SIDEBYSIDEPANEL or the handle to
%      the existing singleton*.
%
%      SIDEBYSIDEPANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SIDEBYSIDEPANEL.M with the given input arguments.
%
%      SIDEBYSIDEPANEL('Property','Value',...) creates a new SIDEBYSIDEPANEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sidebySidePanel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sidebySidePanel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sidebySidePanel

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sidebySidePanel_OpeningFcn, ...
                   'gui_OutputFcn',  @sidebySidePanel_OutputFcn, ...
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

% --- Executes just before sidebySidePanel is made visible.
function sidebySidePanel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sidebySidePanel (see VARARGIN)

% Choose default command line output for sidebySidePanel
handles.output = hObject;

% Obtain parent window
parentInput = find(strcmp(varargin, 'Parent'));
if ~isempty(parentInput)
    handles.parent = varargin{parentInput + 1};
else
    disp('Error: Comparison panel not opened. No parent window found.');
    delete(handles.output);
    return
end

% Obtain list of summary files and populate the two separate lists
sList = findobj(handles.parent, 'Tag', 'summaryList');
string = get(sList, 'String');
userData = get(sList, 'UserData');

s1List = findobj(handles.output, 'Tag', 'heatmap1Files');
s2List = findobj(handles.output, 'Tag', 'heatmap2Files');

set(s1List, 'String', string);
set(s1List, 'UserData', userData);
set(s2List, 'String', string);
set(s2List, 'UserData', userData);

linkaxes([findobj(handles.output, 'Tag', 'heatmap1Axes'), findobj(handles.output, 'Tag', 'heatmap2Axes')])
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes sidebySidePanel wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = sidebySidePanel_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function colorMin2_Callback(hObject, eventdata, handles)
comparison_callback('Update color 2', handles.output)

function colorMin2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function colorMax2_Callback(hObject, eventdata, handles)
comparison_callback('Update color 2', handles.output)

function colorMax2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function heatmap2Files_Callback(hObject, eventdata, handles)
comparison_callback('Load heatmap 2', handles.output)

function heatmap2Files_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function colorMin1_Callback(hObject, eventdata, handles)
comparison_callback('Update color 1', handles.output)

function colorMin1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function colorMax1_Callback(hObject, eventdata, handles)
comparison_callback('Update color 1', handles.output)

function colorMax1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function heatmap1Files_Callback(hObject, eventdata, handles)
comparison_callback('Load heatmap 1', handles.output)

function heatmap1Files_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
