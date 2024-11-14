%#################################
% GutMap 2014-2024
%#################################
function varargout = WaitDialog(varargin)
% WAITDIALOG MATLAB code for WaitDialog.fig
%		Generates a window with a wait dialog during extended computations. In the
%		event of its usage for a edge detection queue, the progress of the process
%		is displayed to the user.
%
%      WAITDIALOG, by itself, creates a new WAITDIALOG or raises the existing
%      singleton*.
%
%      H = WAITDIALOG returns the handle to a new WAITDIALOG or the handle to
%      the existing singleton*.
%
%      WAITDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WAITDIALOG.M with the given input arguments.
%
%      WAITDIALOG('Property','Value',...) creates a new WAITDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before WaitDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to WaitDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help WaitDialog

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @WaitDialog_OpeningFcn, ...
                   'gui_OutputFcn',  @WaitDialog_OutputFcn, ...
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


% --- Executes just before WaitDialog is made visible.
function WaitDialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to WaitDialog (see VARARGIN)

% Choose default command line output for WaitDialog
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes WaitDialog wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = WaitDialog_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
