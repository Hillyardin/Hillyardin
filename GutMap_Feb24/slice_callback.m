%#################################
% GutMap 2014-2024
%#################################
function slice_callback(in, guiHandle)
% ------------------------------------------------------------------------
%   ROLE
%
% Manages the creation and removal of slices taken of the data contained 
% within the heatmap as a part of the cross section panel.
% 
% ------------------------------------------------------------------------
%   DESCRIPTION
%
% SLICE_CALLBACK(ARGIN, HGUI) manages the slices displayed on the axes 
% tagged as 'heatmapAxes' in the GUI window with handle HGUI. ARGIN can 
% take one of several values, shown below:
%
%   - 'Add time slice' prompts the user to click on the axes tagged as
%   'heatmapAxes', and creates the routines for detection of mouse
%   movement and button release to allow a horizontal line to be drawn.
%
%   - 'Add space slice' also prompts the user to click the tagged axes and
%   generates routines, but instead for a vertical line to be drawn.
%
%   - 'Remove time slice' searches for the horizontal line that is under
%   current inspection, and removes it and all the data associated with it.
%
%   - 'Remove space slice' searches for the vertical line that is under
%   current inspection, and removes it and all the data associated with it.
% 
% ------------------------------------------------------------------------
imageHandle = findobj(guiHandle, 'Tag', 'heatmapImage');

switch in
    % Initialising the slice
    
    case 'Add time slice'
        set(imageHandle, 'ButtonDownFcn', {@beginTSlice, guiHandle})
            
    case 'Add space slice'
        set(imageHandle, 'ButtonDownFcn', {@beginXSlice, guiHandle})
        
    case 'Remove time slice'
        
		% Obtain selected slice ID number
        timeSliceNames = findobj(guiHandle, 'Tag', 'timeSliceName');
        IDs = get(timeSliceNames, 'UserData');
        sliceID = IDs(get(timeSliceNames, 'Value'));
        
        % Search for slice with that ID, and remove it
        for i = 1 : length(slices)
            if sliceID == slices(i).id
                delete(slices(i).line)
                slices = [slices(1:i-1) slices(i+1:end)];
                cla(timeAxes)
                cla(freqAxes)
                cla(timeHistogram)
                break
            end
        end
        
		% Repopulate slice data
        data_handle{fNumber}.slices = slices;
        set(fList, 'UserData', data_handle);
        sliceprop_callback('Populate names', guiHandle)
        
    case 'Remove space slice'
        
		% Obtain selected slice ID number
        spaceSliceNames = findobj(guiHandle, 'Tag', 'spaceSliceName');
        IDs = get(spaceSliceNames, 'UserData');
        sliceID = IDs(get(spaceSliceNames, 'Value'));
        
        % Search for slice with that ID, and remove it
        for i = 1 : length(slices)
            if sliceID == slices(i).id
                delete(slices(i).line)
                slices = [slices(1:i-1) slices(i+1:end)];
                cla(spaceAxes)
                cla(invSpaceAxes)
                cla(spaceHistogram)
                break
            end
        end
        
		% Repopulate slice data
        data_handle{fNumber}.slices = slices;
        set(fList, 'UserData', data_handle);
        sliceprop_callback('Populate names', guiHandle)
        
end


function beginTSlice(hObject, ~, guiHandle)  
% Obtain handles  
heatmapAxes = get(findobj(guiHandle, 'Tag', 'heatmapImage'), 'Parent');
current_pt = get(heatmapAxes, 'CurrentPoint');
XLims = get(heatmapAxes, 'XLim');
YLims = get(heatmapAxes, 'YLim');

% Allow user to draw line onto heatmap
sliceHandle = imline(heatmapAxes, XLims, [current_pt(3) current_pt(3)]);
set(sliceHandle, 'Tag', 'hLine');
setPositionConstraintFcn(sliceHandle, makeConstrainToRectFcn('imline', XLims, [current_pt(3) current_pt(3)]));
% setPositionConstraintFcn(sliceHandle, makeConstrainToRectFcn('imline', XLims, YLims));
set(sliceHandle, 'ButtonDownFcn', {@updateSlice, guiHandle});

% Set callbacks
set(guiHandle, 'WindowButtonUpFcn', {@endSlice, sliceHandle});
set(guiHandle, 'WindowButtonMotionFcn', {@continueSlice, sliceHandle});

function updateSlice(hObject, ~, guiHandle)
set(guiHandle, 'WindowButtonUpFcn', {@endSlice, hObject});
set(guiHandle, 'WindowButtonMotionFcn', {@continueSlice, hObject});
    
function beginXSlice(hObject, ~, guiHandle)
% Obtain handles  
heatmapAxes = get(findobj(guiHandle, 'Tag', 'heatmapImage'), 'Parent');
current_pt = get(heatmapAxes, 'CurrentPoint');
XLims = get(heatmapAxes, 'XLim');
YLims = get(heatmapAxes, 'YLim');

% Allow user to draw line onto heatmap
sliceHandle = imline(heatmapAxes, [current_pt(1) current_pt(1)], YLims);
set(sliceHandle, 'Tag', 'vLine');
setPositionConstraintFcn(sliceHandle, makeConstrainToRectFcn('imline', [current_pt(1) current_pt(1)], YLims));
% setPositionConstraintFcn(sliceHandle, makeConstrainToRectFcn('imline', XLims, YLims));

% Set callbacks
set(guiHandle, 'WindowButtonUpFcn', {@endSlice, sliceHandle});
set(guiHandle, 'WindowButtonMotionFcn', {@continueSlice, sliceHandle});
    
function continueSlice(hObject, ~, newSlice)
	% Obtain handles
    heatmapAxes = get(findobj(hObject, 'Tag', 'heatmapImage'), 'Parent');
    current_pt = get(heatmapAxes, 'CurrentPoint');
    XLims = get(heatmapAxes, 'XLim');
    YLims = get(heatmapAxes, 'YLim');
    
	% Adjust height of time slice, and horizontal position of space slice
    current_pt(1) = max(min(current_pt(1), XLims(2)), XLims(1));
    current_pt(3) = max(min(current_pt(3), YLims(2)), YLims(1));
    
    switch get(newSlice, 'Tag')
        case 'hLine'
            setPosition(newSlice, [XLims(1) current_pt(3); XLims(2) current_pt(3)]);
        case 'vLine'
            setPosition(newSlice, [current_pt(1) YLims(1); current_pt(1) YLims(2)]);
    end

function endSlice(hObject, ~, newSlice)
% Snap position onto grid of pixels
imageHandle = findobj(hObject, 'Tag', 'heatmapImage');
heatmapAxes = get(imageHandle, 'Parent');

heatmap = get(imageHandle, 'CData');

XLim = get(heatmapAxes, 'XLim');
YLim = get(heatmapAxes, 'YLim');

XStep = (XLim(2) - XLim(1))/(size(heatmap,2)-1);
YStep = (YLim(2) - YLim(1))/(size(heatmap,1)-1);

set(hObject, 'WindowButtonUpFcn', '', 'WindowButtonMotionFcn', '');
set(imageHandle, 'ButtonDownFcn', '');

rawPosition = getPosition(newSlice);
rawX = rawPosition(:,1);
rawY = rawPosition(:,2);

Xindex = round((rawX - XLim(1))/XStep) + 1;
Yindex = round((rawY - YLim(1))/YStep) + 1;

snapX = XLim(1) + XStep * (Xindex - 1);
snapY = YLim(1) + YStep * (Yindex - 1);

setPosition(newSlice, [snapX, snapY]);

% Take cross sections
sliceType = get(newSlice, 'Tag');
switch sliceType

    case 'vLine'
        cross  = heatmap(:,Xindex(1));
        domain =  YLim(1) : YStep : YLim(2);
        sampling_rate = size(heatmap, 1)/(YLim(2) - YLim(1));

    case 'hLine'
        cross  = heatmap(Yindex(1), :);
        domain =  XLim(1) : XStep : XLim(2);
        sampling_rate = size(heatmap, 2)/(XLim(2) - XLim(1));
end

% Obtain power spectrum of cross sections
N = length(domain);
N = N - mod(N,2);
p = fft(detrend(cross),N);
if ~isempty(p)
    p(1) = [];
end
power = abs(p(1:N/2)).^2/N;
nyquist = sampling_rate/N;
freq = (0:N/2-1)*nyquist;

% Store new slice
slices = get(imageHandle, 'UserData');
n = 1;
if ~isempty(slices)
    ids = [slices.id];
    while ~isempty(find(ids == n,1))
        n = n + 1;
    end
end

if (sliceType == 'hLine')             

    newData = struct('id'      , n          , ...
                 'name'    , ['Line ' num2str(n),' (',num2str(snapY(1),'%.2f'),'mm)'], ...
                 'color'   , mod(n-1,7) + 1 , ...
                 'line'    , newSlice , ...
                 'type'    , sliceType, ...
                 't_domain', domain   , ...
                 't_cross' , cross    , ...
                 'f_domain', freq, ...
                 'f_power' , power        );

else
    newData = struct('id'      , n          , ...
                 'name'    , ['Line ' num2str(n),' (',num2str(snapX(1),'%.2f'),'s)'], ...
                 'color'   , mod(n-1,7) + 1 , ...
                 'line'    , newSlice , ...
                 'type'    , sliceType, ...
                 't_domain', domain   , ...
                 't_cross' , cross    , ...
                 'f_domain', freq, ...
                 'f_power' , power        );

end;
set(imageHandle, 'UserData', [slices newData]);
sliceprop_callback('Populate names', hObject);
