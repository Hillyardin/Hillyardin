%#################################
% GutMap 2014-2024
%#################################
function zoom_callback(hObject, ~,in, guiHandle)
% ------------------------------------------------------------------------
%   ROLE
%
% Manages the display of the heatmap in the heatmap analysis GUI window.
% 
% ------------------------------------------------------------------------
%   DESCRIPTION
%
% ZOOM_CALLBACK(0,0, ARGIN, HGUI) manages the zoom in the time axis of the
% heatmap of the current file, contained in the GUI with handle HGUI. ARGIN
% can take one of several values, shown below:
%
%   - 'Left slider' activates the functionality of the left slider bar upon
%   mouse movement and button release.
%
%   - 'Right slider' activates the functionality of the right slider bar upon
%   mouse movement and button release.
%
%   - 'Set left slider' moves the left slider bar according to entry of values
%   into the left editbox for zoom controls.
%
%   - 'Set right slider' moves the right slider bar according to entry of values
%   into the right editbox for zoom controls.
%
%   - 'Update from figure' updates the editboxes and the zoom line positions
%	  according to the changing limits on the time axis due to zooming with 
%	  the figure palette.
%
% ------------------------------------------------------------------------

% Obtain summary file data
sList = findobj(guiHandle, 'Tag', 'summaryList');
sNumber = get(sList, 'Value');
sData = get(sList, 'UserData');
if isempty(sData)
    return
end

units = sData{sNumber}.parameters;
if isempty(units)
    return
else
    Xmax = units(1) * units(4);
    Ymax = units(2) * units(3);
end

switch in
    
    case 'Left slider'
		% Establish callbacks for zoom slider
        set(guiHandle, 'WindowButtonUpFcn', {@endZoom, guiHandle});
        set(gcf, 'Pointer', 'Crosshair');
        set(guiHandle, 'WindowButtonMotionFcn', {@continueLeftZoom, guiHandle, Xmax});
        
    case 'Right slider'
		% Establish callbacks for zoom slider
        set(guiHandle, 'WindowButtonUpFcn', {@endZoom, guiHandle});
        set(gcf, 'Pointer', 'Crosshair');
        set(guiHandle, 'WindowButtonMotionFcn', {@continueRightZoom, guiHandle, Xmax});
        
    case 'Set left slider'
		% Extract time value from editbox
        zoomMin = findobj(guiHandle, 'Tag', 'zoomMin');
        string = get(zoomMin, 'String');
        value = str2num(string);
        if isempty(value)
            if length(string) > 1
                value = str2num(string(1:end-1));
                if isempty(value)
                    return
                end
            else
                return
            end
        end
		
		% Move slider to appropriate position, within bounds
        value = value / Xmax;
        rightPosition = get(findobj(guiHandle, 'Tag', 'rightSlider'), 'XData');
        value = max(min(value, rightPosition(1) - 0.005), 0);
        
        leftSlider = findobj(guiHandle, 'Tag', 'leftSlider');
        mainAxes = get(findobj(guiHandle, 'Tag', 'heatmapImage'), 'Parent');
        
        set(leftSlider, 'XData' ,[value value]);
        set(mainAxes, 'XLim', Xmax * [value rightPosition(1)]);
        set(zoomMin, 'String', sprintf('%.2f s', Xmax * value));
        
    case 'Set right slider'
		% Extract time value from editbox
        zoomMax = findobj(guiHandle, 'Tag', 'zoomMax');
        string = get(zoomMax, 'String');
        value = str2num(string);
        if isempty(value)
            if length(string) > 1
                value = str2num(string(1:end-1));
                if isempty(value)
                    return
                end
            else
                return
            end
        end
		
		% Move slider to appropriate position, within bounds
        value = value / Xmax;
        leftPosition = get(findobj(guiHandle, 'Tag', 'leftSlider'), 'XData');
        value = min(max(value, leftPosition(1) + 0.005), 1);
        
        rightSlider = findobj(guiHandle, 'Tag', 'rightSlider');
        mainAxes = get(findobj(guiHandle, 'Tag', 'heatmapImage'), 'Parent');
        
        set(rightSlider, 'XData' ,[value value]);
        set(mainAxes, 'XLim', Xmax * [leftPosition(1) value]);
        set(zoomMax, 'String', sprintf('%.2f s', Xmax * value));
        
    case 'Update from figure'
		% upon zoom, obtain new limits
        mainAxes = get(findobj(guiHandle, 'Tag', 'heatmapImage'), 'Parent');
        newXLim = get(mainAxes, 'XLim');
        newYLim = get(mainAxes, 'YLim');
        
        newXLim(1) = max(0, newXLim(1));
        newYLim(1) = max(0, newYLim(1));
        newXLim(2) = min(Xmax, newXLim(2));
        newYLim(2) = min(Ymax, newYLim(2));
        
        set(mainAxes, 'XLim', newXLim);
        set(mainAxes, 'YLim', newYLim);
        
		% Set new position of zoom lines
        set(findobj(guiHandle, 'Tag', 'leftSlider' ), 'XData', [newXLim(1) newXLim(1)]/Xmax);
        set(findobj(guiHandle, 'Tag', 'rightSlider'), 'XData', [newXLim(2) newXLim(2)]/Xmax);
        set(findobj(guiHandle, 'Tag', 'zoomMin'), 'String', sprintf('%.2f s', newXLim(1)));
        set(findobj(guiHandle, 'Tag', 'zoomMax'), 'String', sprintf('%.2f s', newXLim(2)));
        
end

function continueLeftZoom(hObject, ~, guiHandle, Xmax)
% Obtain handles
zoomAxes = findobj(guiHandle, 'Tag', 'zoomAxes');
mainAxes = get(findobj(guiHandle, 'Tag', 'heatmapImage'), 'Parent');
leftSlider = findobj(guiHandle, 'Tag', 'leftSlider');
rightSlider = findobj(guiHandle, 'Tag', 'rightSlider');
zoomMin = findobj(guiHandle, 'Tag', 'zoomMin');

% Get current point, and keep within bounds
current_pt = get(zoomAxes, 'CurrentPoint');
current_x = current_pt(1);
rightPosition = get(rightSlider, 'XData');

if current_x < 0
    current_x = 0;
elseif current_x > rightPosition(1)-0.005
    current_x = rightPosition(1)-0.005;
end

set(leftSlider, 'XData' ,[current_x, current_x]);
set(mainAxes, 'XLim', Xmax * [current_x rightPosition(1)]);
set(zoomMin, 'String', sprintf('%.2f s', Xmax * current_x));

function continueRightZoom(hObject, ~, guiHandle, Xmax)
% Obtain handles
zoomAxes = findobj(guiHandle, 'Tag', 'zoomAxes');
mainAxes = get(findobj(guiHandle, 'Tag', 'heatmapImage'), 'Parent');
leftSlider = findobj(guiHandle, 'Tag', 'leftSlider');
rightSlider = findobj(guiHandle, 'Tag', 'rightSlider');
zoomMax = findobj(guiHandle, 'Tag', 'zoomMax');

% Get current point, and keep within bounds
current_pt = get(zoomAxes, 'CurrentPoint');
current_x = current_pt(1);
leftPosition = get(leftSlider, 'XData');

if current_x > 1
    current_x = 1;
elseif current_x < leftPosition(1)+0.005
    current_x = leftPosition(1)+0.005;
end

set(rightSlider, 'XData' ,[current_x, current_x]);
set(mainAxes, 'XLim', Xmax * [leftPosition(1) current_x]);
set(zoomMax, 'String', sprintf('%.2f s', Xmax * current_x));


function endZoom(hObject, ~, guiHandle)
% Revert callbacks
set(gcf, 'Pointer', 'Arrow');
set(guiHandle, 'WindowButtonUpFcn', '');
set(guiHandle, 'WindowButtonMotionFcn', '');

