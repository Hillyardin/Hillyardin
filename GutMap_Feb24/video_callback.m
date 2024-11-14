%#################################
% GutMap 2014-2024
%#################################
function video_callback(in, guiHandle, parHandles)
% ------------------------------------------------------------------------
%   ROLE
%
% Manages the display of video files in the Edge Detection GUI environment.
% These video files can then be converted into sumamry files through the 
% detection of the edges of the gut and determining the distance between
% them. These files can then be anlaysed in the Heatmap Analysis GUI. 
% 
% ------------------------------------------------------------------------
%   DESCRIPTION
%
% VIDEO_CALLBACK(ARGIN, HGUI) manages the data associated with the 
% current file, which is of the AVI video format, contained in the GUI with
% handle HGUI. ARGIN can take one of several values, shown below:
%
%   - 'Update video of interest' changes the source of the video being previewed
%	  and resets all of the controls used for video manipulation.
%
%   - 'Update image' adjusts the display of the video of interest by applying
%	  any new settings obtained from manipulating the controls available.
%	  If edge detection has been previewed, a new preview is also generated.
%
%   - 'Preview edges' performs edge detection in the region specified by 
%	  annotation, and marks the edges detected in red and green.
%
% ------------------------------------------------------------------------

% Obtain the handles to the structs containing video objects
vList = findobj(guiHandle, 'Tag', 'videoList');
vNumber = get(vList, 'Value');
vData = get(vList, 'UserData');

% Obtain parameters of video
fullName  = vData{vNumber}.fullName;
video     = vData{vNumber}.video;
numFrames = video.NumberOfFrames;
width     = video.Width;
height    = video.Height;
stepSize  = floor((numFrames-1)/25);

switch in
    
    case 'Update video of interest'
		% Sets preview to first frame of new video when it is chosen, and resets controls
		
		% Obtain parents axes from previous preview, or hidden axes.
        oldImage = findobj(guiHandle, 'Tag', 'previewImage');
        if isempty(oldImage)
            previewAxes = findobj(guiHandle, 'Tag', 'previewAxes');
        else
            previewAxes = get(oldImage, 'Parent');
            delete(oldImage);
        end
        
        set(findobj(guiHandle, 'Tag', 'frameWidth'), 'Enable', 'on');
        set(findobj(guiHandle, 'Tag', 'CalibrateButton'), 'Enable', 'on');
        
		% Preview first frame of video
        imageHandle = image(read(video, [1 1]), 'Parent', previewAxes);
        set(imageHandle, 'Tag', 'previewImage', 'ButtonDownFcn', {@selectRegion, guiHandle});
        
        if ~isempty(get(parHandles.edit_BoxWidth,'String'))
            pVec(3) = str2num(get(parHandles.edit_BoxWidth,'String'));
            pVec(4) = str2num(get(parHandles.edit_BoxHeight,'String'));
            pVec(1) = str2num(get(parHandles.edit_BoxLeft,'String'));
            pVec(2) = str2num(get(parHandles.edit_BoxTop,'String'));
            
            rectHandle = rectangle('Position', pVec, 'LineStyle', '-', 'LineWidth', 1.5,...
                       'EdgeColor','y', 'Tag', 'regionOfInterest');

            video_callback('Preview edges', guiHandle);
            
        end;
        
		% Reset the range of each slider
        set(findobj(guiHandle, 'Tag', 'timeSlider'), 'Value', 1, 'Min',1,'Max',numFrames,'SliderStep', [1 1]/numFrames);
        set(findobj(guiHandle, 'Tag', 'contrastSlider'), 'Value', 0, 'SliderStep', [0.0333 0.1]);
        set(findobj(guiHandle, 'Tag', 'brightnessSlider'), 'Value', 50, 'SliderStep', [0.01 0.1]);
        
		% Reset values in slider and edit boxes
        set(findobj(guiHandle, 'Tag', 'contrastNumber'), 'String', 0);
        set(findobj(guiHandle, 'Tag', 'timeNumber'), 'String', 1);
        set(findobj(guiHandle, 'Tag', 'timeSeconds'), 'String', '0 Secs');
        set(findobj(guiHandle, 'Tag', 'brightnessNumber'), 'String', 50);
        set(findobj(guiHandle, 'Tag', 'frameWidth'), 'String', 0.1);
        set(findobj(guiHandle, 'Tag', 'edit_EdgeSmooth'), 'String', 60);
        set(findobj(guiHandle, 'Tag', 'generateButton'), 'Enable', 'off');
        
    case 'Update image'
		% Sets preview to new frame of video, with new parameters when controls are used
        
        imageHandle = findobj(guiHandle, 'Tag', 'previewImage');
        
		% Obtains parameter values
        time       = get(findobj(guiHandle, 'Tag', 'timeSlider'), 'Value');
        contrast   = get(findobj(guiHandle, 'Tag', 'contrastSlider'), 'Value');
        brightness = get(findobj(guiHandle, 'Tag', 'brightnessSlider'), 'Value');
        
		% Converts brightness and contrast numbers to the values used in calculations
        b = uint8(2.56 * brightness);
        k = exp(contrast/10);
        
		% Obtains new frame and applies brightness then contrast
        newFrame = time;
        newCData = read(video, [newFrame newFrame]);
        if b > 128
            newCData = newCData + (b - 128);
        elseif b < 128
            newCData = newCData - (128 - b);
        end
        newCData = 128 + k * (newCData - 128) - k * (128 - newCData);
        set(imageHandle, 'CData', newCData);
        

        
        
    case 'Preview edges'
		% Generates a preview of the edge detection in the region selected
        video_callback('Update image', guiHandle);
		
		% If no region is selected, nothing happens
        if ~isempty(findall(gcbf, 'Tag', 'regionOfInterest'))
            imageHandle = findobj(guiHandle, 'Tag', 'previewImage');
			
			% Obtains parameters for the video
            time       = get(findobj(guiHandle, 'Tag', 'timeSlider'), 'Value');
            contrast   = get(findobj(guiHandle, 'Tag', 'contrastSlider'), 'Value');
            brightness = get(findobj(guiHandle, 'Tag', 'brightnessSlider'), 'Value');
            edgesmooth = str2double(get(findobj(guiHandle, 'Tag', 'edit_EdgeSmooth'),...
                            'String'));
            
            b = uint8(2.56 * brightness);
            k = exp(contrast/10);
            frameNum = time;
            
			% Obtains the region of interest and the marker position
            ROI = get(findobj(guiHandle, 'Tag', 'regionOfInterest'), 'Position');
            crop = [ROI(1), ROI(1) + ROI(3), ROI(2), ROI(2) + ROI(4)];
            
            frame = read(video, [frameNum, frameNum + 1]);
			
			% Current frame with brightness/contrast applied
            pFrame = frame(crop(3):crop(4), crop(1):crop(2),:,1);
            if ndims(pFrame) == 3
                pFrame = rgb2gray(pFrame);
            end
            if b > 128
                pFrame = pFrame + (b - 128);
            elseif b < 128
                pFrame = pFrame - (128 - b);
            end
            pFrame = 128 + k * (pFrame - 128) - k * (128 - pFrame);
            
			% Edge detection
            [edges,topx,topy,botx,boty] = edge_contours(pFrame,edgesmooth);
			
			% Adjusts the image to display the top edge as green and the bottom as red
            CData = get(imageHandle, 'CData');
            pFrameData = CData(crop(3):crop(4), crop(1):crop(2),:);
            temp = pFrameData(:,:,1);
            temp(edges == 1) = 255;
            temp(edges == 2) = 0;
            pFrameData(:,:,1) = temp;
            temp = pFrameData(:,:,2);
            temp(edges == 2) = 255;
            temp(edges == 1) = 0;
            pFrameData(:,:,2) = temp;
            temp = pFrameData(:,:,3);
            temp(edges > 0) = 0;
            pFrameData(:,:,3) = temp;
            
            CData(crop(3):crop(4), crop(1):crop(2), :) = pFrameData;
            set(imageHandle, 'CData', CData);
            
        end
end



function selectRegion(hObject, ~, guiHandle)
	% Begins the process of adding a region of interest

	% Prevents entering other processes
	set(hObject, 'ButtonDownFcn', '');
	set(findobj(guiHandle, 'Tag', 'generateButton'), 'Enable', 'off');
	
	% Obtain the axis limits
	axesHandle = get(findobj(guiHandle, 'Tag', 'previewImage'), 'Parent');
	xlims   = get(axesHandle, 'XLim');
	ylims   = get(axesHandle, 'YLim');

	start = get(axesHandle, 'CurrentPoint');
	start_x = round(start(1));
	start_y = round(start(3));
	
	% Bound to within limits
	if start_x < xlims(1)
		start_x = xlims(1);
	elseif start_x > xlims(2)-1
		start_x = xlims(2)-1;
	end

	if start_y < ylims(1)
		start_y = ylims(1);
	elseif start_y > ylims(2)-1
		start_y = ylims(2)-1;
    end
	
	% Delete previous regions of interest
	delete(findall(guiHandle, 'Tag', 'regionOfInterest'));
	
	% Create rectangle 
	rectHandle = rectangle('Position', [start_x, start_y, min(20, xlims(2) - start_x), min(20, ylims(2) - start_y)], ...
                           'lineStyle', '-', 'LineWidth', 1.5, 'EdgeColor','y', 'Tag', 'regionOfInterest');
					   
	set(guiHandle, 'WindowButtonMotionFcn', {@updateRegion, [start_x, start_y]}, ...
				   'WindowButtonUpFcn', @completeRegion);

				   
function updateRegion(hObject, ~, initial)
	% Continues the process of adding a region of interest
	
	% Handles to axes and rectangle and marker
	axesHandle = get(findobj(hObject, 'Tag', 'previewImage'), 'Parent');
	rectHandle = findobj(hObject, 'Tag', 'regionOfInterest');
	
	% Obtains current position, and bounds within the axes
	current = get(axesHandle, 'CurrentPoint');
	xlims   = get(axesHandle, 'XLim');
	ylims   = get(axesHandle, 'YLim');

	if current(1) < xlims(1)
		current(1) = xlims(1);
	elseif current(1) > xlims(2)-1
		current(1) = xlims(2)-1;
	end

	if current(3) < ylims(1)
		current(3) = ylims(1);
	elseif current(3) > ylims(2)-1
		current(3) = ylims(2)-1;
	end
	
	% Snaps rectangle position to grid
	left_x = min(initial(1), current(1));
	top_y  = min(initial(2), current(3));
	width  = round(max(abs(initial(1) - current(1)), 10));
	height = round(max(abs(initial(2) - current(3)), 20));

	% Updates rectangle position and marker position
	set(rectHandle, 'Position', round([left_x+1, top_y+1, width-1, height-1]));
    set(findobj(hObject, 'Tag', 'edit_BoxWidth'), 'String',num2str(round(width-1)));
    set(findobj(hObject, 'Tag', 'edit_BoxHeight'), 'String',num2str(round(height-1)));
    set(findobj(hObject, 'Tag', 'edit_BoxLeft'), 'String',num2str(round(left_x+1)));
    set(findobj(hObject, 'Tag', 'edit_BoxTop'), 'String',num2str(round(top_y+1)));
    
     
function completeRegion(hObject, ~)
	% Terminates the region selection process by preview edges in the region and enabling controls
	set(hObject, 'WindowButtonMotionFcn', '');
	set(hObject, 'WindowButtonUpFcn', '');
	video_callback('Preview edges', hObject);
	set(findobj(hObject, 'Tag', 'previewImage'), 'ButtonDownFcn', {@selectRegion, hObject});
	set(findobj(hObject, 'Tag', 'generateButton'), 'Enable', 'on');


