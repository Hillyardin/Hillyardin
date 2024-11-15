%#################################
% GutMap 2014-2024
%#################################

function varargout = crossSectionPanel(varargin)
% CROSSSECTIONPANEL MATLAB code for crossSectionPanel.fig
%		This window provides the user with an interface to take vertical and horiztonal
%		cross sections of the selected region of the heatmap. Frequency content is also
%		calculated and graphed.
%
%      CROSSSECTIONPANEL, by itself, creates a new CROSSSECTIONPANEL or raises the existing
%      singleton*.
%
%      H = CROSSSECTIONPANEL returns the handle to a new CROSSSECTIONPANEL or the handle to
%      the existing singleton*.
%
%      CROSSSECTIONPANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CROSSSECTIONPANEL.M with the given input arguments.
%
%      CROSSSECTIONPANEL('Property','Value',...) creates a new CROSSSECTIONPANEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before crossSectionPanel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to crossSectionPanel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help crossSectionPanel

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @crossSectionPanel_OpeningFcn, ...
                   'gui_OutputFcn',  @crossSectionPanel_OutputFcn, ...
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


% --- Executes just before crossSectionPanel is made visible.
function crossSectionPanel_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to crossSectionPanel (see VARARGIN)

% Choose default command line output for crossSectionPanel
handles.output = hObject;

% Import the limits of the x and y axes (in pixels!)
limitInput = find(strcmp(varargin, 'Limits'));
if ~isempty(limitInput)
    handles.limits = varargin{limitInput + 1};
else
    disp('Error: Cross section panel not opened. No parent limits found.');
    delete(handles.output);
    return
end

% Import a handle to the parent window which generated this one.
parentInput = find(strcmp(varargin, 'Parent'));
if ~isempty(parentInput)
    handles.parent = varargin{parentInput + 1};
else
    disp('Error: Cross section panel not opened. No parent window found.');
    delete(handles.output);
    return
end

% Import a handle to the generating heatmap's name:
heatmapInput = find(strcmp(varargin, 'HeatmapName'));
if ~isempty(heatmapInput)
    handles.heatmapName = varargin{heatmapInput + 1};
else
    disp('Error: Cross section panel not opened. No parent heatmap name found.');
    delete(handles.output);
    return
end


% Obtain color boundaries.
CMin = str2num(get(findobj(handles.parent, 'Tag', 'colorMin'), 'String'));
CMax = str2num(get(findobj(handles.parent, 'Tag', 'colorMax'), 'String'));

% Obtain axes limits.
XLim = get(get(findobj(handles.parent, 'Tag', 'heatmapImage'), 'Parent'), 'XLim');
YLim = get(get(findobj(handles.parent, 'Tag', 'heatmapImage'), 'Parent'), 'YLim');

heatmapAxes = findobj(handles.output, 'Tag', 'heatmapAxes');
set(findobj(handles.output, 'Tag', 'timeAxes'), 'XLim', XLim);
set(findobj(handles.output, 'Tag', 'spaceAxes'), 'XLim', YLim);

% Import the heatmap
CData = get(findobj(handles.parent, 'Tag', 'heatmapImage'), 'CData');
Xlimits = handles.limits(1,:);
Ylimits = handles.limits(2,:);

% Set axes and plot the restricted portion of the heatmap.
set(heatmapAxes, 'XLim', XLim, 'YLim', YLim);
imageHandle = imagesc(XLim, YLim, CData(Ylimits(1):Ylimits(2), Xlimits(1):Xlimits(2)), 'Parent', heatmapAxes, [CMin CMax]);
set(imageHandle, 'Tag', 'heatmapImage');

colormap('jet');
cmap = flipdim(colormap,1);     % Set hot colors to contracted and cool colors to dilated
colormap(cmap);
colorbar;

set(handles.updateButton,'Visible','off');
set(handles.updateButton,'Enable','off');

% Tooltips:
set(handles.ExportLines,'Tooltip','Export Lines writes the horizontal and vertical line cross-sections in separate text files in a new directory.');
set(handles.PopoutPlots,'Tooltip','Pop-Out Plots creates a new figure for each of the embedded axes in the Heatmap Annotation panel.  Editting figures is much easier in these popped-out plots.');
set(handles.addTemporal,'Tooltip','Add a temporal cross-section.  Once you click this button, use the mouse to click on the desired heatmap position for the horizontal cross-section.');
set(handles.addSpatial,'Tooltip','Add a spatial cross-section.  Once you click this button, use the mouse to click on the desired heatmap position for the vertical cross-section.');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes crossSectionPanel wait for user response (see UIRESUME)
% uiwait(handles.figure1);


function varargout = crossSectionPanel_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;


% These two buttons execute callbacks related to adding new slices.
function addSpatial_Callback(hObject, eventdata, handles)
slice_callback('Add space slice', handles.output);

function addTemporal_Callback(hObject, eventdata, handles)
slice_callback('Add time slice', handles.output);

% These buttons and user interfaces execute callbacks related to updating slice
% properties and removing slices from the list.
function removeSpatial_Callback(hObject, eventdata, handles)
sliceprop_callback('Remove space slice', handles.output);

function removeTemporal_Callback(hObject, eventdata, handles)
sliceprop_callback('Remove time slice', handles.output);
x=1;

function temporalNames_Callback(hObject, eventdata, handles)
sliceprop_callback('Populate time slice properties', handles.output);

function temporalNames_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function temporalColors_Callback(hObject, eventdata, handles)
sliceprop_callback('Update time slice properties', handles.output);

function temporalColors_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function temporalRename_Callback(hObject, eventdata, handles)
sliceprop_callback('Update time slice properties', handles.output);

function temporalRename_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function spatialRename_Callback(hObject, eventdata, handles)
sliceprop_callback('Update space slice properties', handles.output);

function spatialRename_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function spatialColors_Callback(hObject, eventdata, handles)
sliceprop_callback('Update space slice properties', handles.output);

function spatialColors_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function spatialNames_Callback(hObject, eventdata, handles)
sliceprop_callback('Populate space slice properties', handles.output);

function spatialNames_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function updateButton_Callback(hObject, eventdata, handles)
sliceprop_callback('Update names', handles.output);


function PopoutPlots_Callback(hObject, eventdata, handles)

% Pop-out heatmap axes:
newf = figure;
aheat = copyobj(handles.heatmapAxes,newf);
colormap('jet');
cmap = flipdim(colormap,1);     % Set hot colors to contracted and cool colors to dilated
colormap(cmap);
colorbar;
set(aheat,'Position',[0.1300 0.1100 0.7750 0.8150]);
xlabel('Time (seconds)','Visible','on');
ylabel('Gut Width (mm)','Visible','on');

if ~isempty(get(handles.timeAxes,'Children'))

    % Pop-out temporal plots:
    newt = figure;
    atime = copyobj(handles.timeAxes,newt);
    set(atime,'Position',[0.1300 0.1100 0.7750 0.8150]);
    xlabel('Time (seconds)','Visible','on');
    ylabel('Gut Width (mm)','Visible','on');
    title('Temporal Cross-Sections: Time domain','Visible','on');
    legend(handles.temporalNames.String);

    newf = figure;
    afreq = copyobj(handles.freqAxes,newf);
    set(afreq,'Position',[0.1300 0.1100 0.7750 0.8150]);
    xlabel('Frequency','Visible','on');
    ylabel('Power spectrum','Visible','on');
    title('Temporal Cross-Sections: Frequency domain','Visible','on');
    legend(handles.temporalNames.String);

    newh = figure;
    athist = copyobj(handles.timeHistogram,newh);
    set(athist,'Position',[0.1300 0.1100 0.7750 0.8150]);
    xlabel('Gut Width (mm)','Visible','on');
    ylabel('Count','Visible','on');
    title('Temporal Cross-Sections: Histogram','Visible','on');
    legend(handles.temporalNames.String);
end;

if ~isempty(get(handles.spaceAxes,'Children'))

    news = figure;
    aspace = copyobj(handles.spaceAxes,news);
    set(aspace,'Position',[0.1300 0.1100 0.7750 0.8150]);
    xlabel('Time (seconds)','Visible','on');
    ylabel('Gut Width (mm)','Visible','on');
    title('Spatial Cross-Sections: Time domain','Visible','on');
    legend(handles.spatialNames.String);

    newis = figure;
    ainvs = copyobj(handles.invSpaceAxes,newis);
    set(ainvs,'Position',[0.1300 0.1100 0.7750 0.8150]);
    xlabel('Frequency','Visible','on');
    ylabel('Power spectrum','Visible','on');
    title('Spatial Cross-Sections: Spatial Frequency domain','Visible','on');
    legend(handles.spatialNames.String);

    newsh = figure;
    ashist = copyobj(handles.spaceHistogram,newsh);
    set(ashist,'Position',[0.1300 0.1100 0.7750 0.8150]);
    xlabel('Gut Width (mm)','Visible','on');
    ylabel('Count','Visible','on');
    title('Spatial Cross-Sections: Histogram','Visible','on');
    legend(handles.spatialNames.String);
end;




% --- Executes on button press in ExportLines.
function ExportLines_Callback(hObject, eventdata, handles)

% Export slices:
userd = findobj(handles.output,'Tag','heatmapImage');
lineinfo = get(userd,'UserData');
numlines = length(lineinfo);

if ~isempty(numlines)
    
    dname = [handles.heatmapName,'_Lines_',datestr(now,30)];
    mkdir(dname);
    cd(dname);
    
    uiwait(msgbox(['Saving lines in new directory: ',dname]));
    
    for nn = 1:1:numlines

        linefile = [lineinfo(nn).name,'_',lineinfo(nn).type,'.txt'];

        kk = length(lineinfo(nn).t_domain);
        linemat = [reshape(lineinfo(nn).t_domain,kk,1) ...
                   reshape(lineinfo(nn).t_cross,kk,1)];
               
        dlmwrite(linefile,linemat);

    end;
    
    cd ../;  % Return to code directory

end;
