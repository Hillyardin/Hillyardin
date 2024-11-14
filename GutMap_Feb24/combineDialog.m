%#################################
% GutMap 2014-2024
%#################################% 

function varargout = combineDialog(varargin)
%%
% COMBINEDIALOG MATLAB code for combineDialog.fig
%	   This window contains the dialog box used to take two heatmaps with the same parameters
%      and combine them in the temporal sequence.
%	   
%      COMBINEDIALOG, by itself, creates a new COMBINEDIALOG or raises the existing
%      singleton*.
%
%      H = COMBINEDIALOG returns the handle to a new COMBINEDIALOG or the handle to
%      the existing singleton*.
%
%      COMBINEDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COMBINEDIALOG.M with the given input arguments.
%
%      COMBINEDIALOG('Property','Value',...) creates a new COMBINEDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before combineDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to combineDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help combineDialog

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @combineDialog_OpeningFcn, ...
                   'gui_OutputFcn',  @combineDialog_OutputFcn, ...
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

function combineDialog_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

parentInput = find(strcmp(varargin, 'Parent'));
if ~isempty(parentInput)
    handles.parent = varargin{parentInput + 1};
else
    disp('Error: Heatmap combining dialog not opened. No parent window found.');
    delete(handles.output);
    return
end

% Update handles structure
guidata(hObject, handles);

function varargout = combineDialog_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function findSecond_Callback(hObject, eventdata, handles)
% Opens a dialog box for the user to choose the second file to combine.
[fileName, pathName] = uigetfile({'*.su?', 'Summary files (*.su?)'}, 'Choose summary file');
if exist('fileName', 'var')
    if fileName ~= 0
        set(findobj(handles.output, 'tag', 'secondLocation'), 'String', [pathName fileName]);
    end
end
checkUI(handles.output);

function secondLocation_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function firstLocation_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function findFirst_Callback(hObject, eventdata, handles)
% Opens a dialog box for the user to choose the first file to combine.
[fileName, pathName] = uigetfile({'*.su?', 'Summary files (*.su?)'}, 'Choose summary file');
if exist('fileName', 'var')
    if fileName ~= 0
        set(findobj(handles.output, 'tag', 'firstLocation'), 'String', [pathName fileName]);
    end
end
checkUI(handles.output);

function savePath_CreateFcn(hObject, eventdata, handles)
set(hObject, 'String', pwd)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function saveName_CreateFcn(hObject, eventdata, handles)
% Allows the user to enter a name for the new file
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function findSave_Callback(hObject, eventdata, handles)
%	Allows the user to select a folder to save the new file in.
pathnameText = findobj(handles.output, 'Tag', 'savePath');
newDirectory = uigetdir(get(pathnameText, 'String'), 'Choose a save location');
if exist('newDirectory', 'var')
    set(pathnameText, 'String', newDirectory);
end

function acceptButton_Callback(hObject, eventdata, handles)
% Begins the combination process, after checking for the presence of a file with
% the name chosen and confirming overwrite, if necessary.
pathname = [get(findobj(handles.output, 'Tag', 'savePath'), 'String')];
filename =  get(findobj(handles.output, 'Tag', 'saveName'), 'String');
if get(findobj(handles.output, 'Tag', 'su3Button'), 'Value')
    extension = '.su3';
else get(findobj(handles.output, 'Tag', 'su2Button'), 'Value')
    extension = '.su2';
end
savename = [pathname filesep filename extension];


if exist(savename, 'file')
    confirmation = overwriteDialog('Location', savename);
else
    confirmation = 'Yes';
end

if strcmp(confirmation, 'Yes')
    firstFileName  = get(findobj(handles.output, 'Tag', 'firstLocation') , 'String');
    secondFileName = get(findobj(handles.output, 'Tag', 'secondLocation'), 'String');
    combine(firstFileName, secondFileName, savename);

    delete(handles.output)
end

    
function cancelButton_Callback(hObject, eventdata, handles)
delete(handles.output)

function firstLocation_Callback(hObject, eventdata, handles)
checkUI(handles.output);

function secondLocation_Callback(hObject, eventdata, handles)
checkUI(handles.output);

function saveName_Callback(hObject, eventdata, handles)
checkUI(handles.output)

function checkUI(guiHandle)
% This function checks which user interface buttons should be available based on the completion
% of the input boxes, as well as the parameters associated with these inputs.

% Obtains component file names
firstFileName  = get(findobj(guiHandle, 'Tag', 'firstLocation') , 'String');
secondFileName = get(findobj(guiHandle, 'Tag', 'secondLocation'), 'String');

% Obtains full new file name
savePath = get(findobj(guiHandle, 'tag', 'savePath'), 'string');
saveName = get(findobj(guiHandle, 'tag', 'saveName'), 'string');

saveExt = '.gmp';
saveFileName = [savePath filesep saveName saveExt];

% Determines the least precision of the two files, and whether they are valid for combination
firstExt = firstFileName(max(1,length(firstFileName)-3):end);
secondExt = secondFileName(max(1,length(secondFileName)-3):end);

firstPrecise = strcmp(firstExt, '.su3');
secondPrecise  = strcmp(secondExt, '.su3');
firstValid = strcmp(firstExt, '.su2') || firstPrecise;
secondValid = strcmp(secondExt, '.su2') || secondPrecise;

su3 = findobj(guiHandle, 'Tag', 'su3Button');
su2 = findobj(guiHandle, 'Tag', 'su2Button');
OK  = findobj(guiHandle, 'Tag', 'acceptButton');
firstQ  = findobj(guiHandle, 'Tag', 'firstPrecision');
secondQ = findobj(guiHandle, 'Tag', 'secondPrecision');

if firstValid
    set(firstQ, 'String', firstExt);
    try
        fid = fopen(firstFileName);
        Units1A      = fscanf(fid, '%d', 2);
        Units1B      = fscanf(fid, '%f', 3);
        fclose(fid);
        set(findobj(guiHandle, 'Tag', 'firstStats'), 'String', {1e6/Units1B(2);Units1B(1);Units1B(3);Units1A(2)});
    catch
        set(findobj(guiHandle, 'Tag', 'firstLocation'), 'String', 'Error: File not read.')
    end
end

if secondValid
    set(secondQ, 'String', secondExt);
    try
        fid = fopen(secondFileName);
        Units2A      = fscanf(fid, '%d', 2);
        Units2B      = fscanf(fid, '%f', 3);
        fclose(fid);
        set(findobj(guiHandle, 'Tag', 'secondStats'), 'String', {1e6/Units2B(2);Units2B(1);Units2B(3);Units2A(2)});
    catch
        set(findobj(guiHandle, 'Tag', 'secondLocation'), 'String', 'Error: File not read.')
    end
end

if secondValid
    set(secondQ, 'String', secondExt);
end

firstStats  = get(findobj(guiHandle, 'Tag',  'firstStats'), 'String');
secondStats = get(findobj(guiHandle, 'Tag', 'secondStats'), 'String');

if firstPrecise && secondPrecise
    set(su3, 'Enable', 'on')
    set(su2, 'Enable', 'on')
    if isequal([firstStats], [secondStats]) && ~isempty(saveName)
        if ~(strcmp(saveFileName, firstFileName) || strcmp(saveFileName, secondFileName))
            set(OK, 'Enable', 'on');
        else
            set(OK, 'Enable', 'off')
        end
    else
        set(OK, 'Enable', 'off');
    end
else
    set(su3, 'Enable', 'off', 'Value', 0)
    set(su2, 'Value', 1)
    
    if firstValid && secondValid
        set(su2, 'Enable', 'on')
        
        if isequal([firstStats], [secondStats]) && ~isempty(saveName)
            if ~(strcmp(saveFileName, firstFileName) || strcmp(saveFileName, secondFileName))
                set(OK, 'Enable', 'on');
            else
                set(OK, 'Enable', 'off')
            end
        else
            set(OK, 'Enable', 'off');
        end
    else
        set(su2, 'Enable', 'off')
        set(OK , 'Enable', 'off')
    end
end

function combine(file1, file2, destination)
% Combines the files with the same parameters temporally, updating the metadata in the new file.
pixelsize = 'double';

f1 = fopen(file1);
f2 = fopen(file2);
fout = fopen(destination, 'w');

% Obtains the parameters of the component files
Units1A = fscanf(f1, '%d', 2);
Units1B = fscanf(f1, '%f', 3);
Units2A = fscanf(f2, '%d', 2);
Units2B = fscanf(f2, '%f', 3);
fseek(f1, 1, 'cof');
fseek(f2, 1, 'cof');

% Writes the new parameters for the new file
fprintf(fout, '%d\n', (Units1A(1) + Units2A(1)));
fprintf(fout, '%d\n', Units1A(2));
fprintf(fout, '%f\n', Units1B(1));
fprintf(fout, '%f\n', Units1B(2));
fprintf(fout, '%f\n', Units1B(3));

% Reads each line of the first file and transcribes to the new file
firstSummary = fread(f1, [Units1A(2), Units1A(1)], ['double=>' pixelsize]);
fclose(f1);
    
fwrite(fout, firstSummary, pixelsize);

% Reads each line of the second file and transcribes to the new file
secondSummary = fread(f2, [Units2A(2), Units2A(1)], ['double=>' pixelsize]);
fclose(f2);

fwrite(fout, secondSummary, pixelsize);
fclose(fout);
    
