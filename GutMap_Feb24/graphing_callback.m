%#################################
% GutMap 2014-2024
%#################################% 

function graphing_callback(in, guiHandle)
% ------------------------------------------------------------------------
%   ROLE
%
% Manages the plotting of spatiotemporal maps within the Heatmap Analysis
% window, as well as the display of the parameters of the video which were
% included in the original summary file. For use with the GutMap GUI.
% 
% ------------------------------------------------------------------------
%   DESCRIPTION
%
% GRAPHING_CALLBACK(ARGIN, HGUI) manages the spatiotemporal map in the GUI
% window with handle HGUI. ARGIN can take one of several values, shown
% below:
%
%   - 'Plot Heatmap' produces a heatmap from the selected source file, and
%     determines the color range to be used for the image, unless instructed
%	  not to.
%
%   - 'New color scheme' changes the color scheme used in the heatmap displayed.
%
%   - 'Update color map' applies new changes to the minimum and maximum values 
%	  in the range of colors displayed.
%
%	- 'Revert color' undoes the most recent change to the color range.
%
%	- 'Auto color' determines the maximum and minimum values in the heatmap
%	  and produces a color range using these values.
%
%   - 'Update summary stats' changes the values of the parameters displayed
%	  to those of the most recently selected summary file.
%
%	- 'Update video stats' changes the values of the parameters displayed
%	  to those of the most recently selected video.
% 
%	- 'Clear heatmap' removes the most recently displayed heatmap from the
%	  parent axes.
%
%	- 'Clear stats' removes the currently displayed summary file stats.
%
% ------------------------------------------------------------------------

% Obtain video list
vList   = findobj(guiHandle, 'Tag', 'videoList');
vNumber = get(vList, 'Value');
vData   = get(vList, 'UserData');

% Obtain summary file list
sList   = findobj(guiHandle, 'Tag', 'summaryList');
sNumber = get(sList, 'Value');
sData   = get(sList, 'UserData');

% Obtain parent axes of image if one is displayed, otherwise finds hidden axes
oldImage = findobj(guiHandle, 'Tag', 'heatmapImage');
if isempty(oldImage)
    mainAxes = findobj(guiHandle, 'Tag', 'heatmapAxes');
else
    mainAxes =get(oldImage, 'Parent');
end

% Color controls
undoColor = findobj(guiHandle, 'Tag', 'undoColor');
autoColor = findobj(guiHandle, 'Tag', 'autoColor');
colorMin  = findobj(guiHandle, 'Tag', 'colorMin');
colorMax  = findobj(guiHandle, 'Tag', 'colorMax');
colorLock = findobj(guiHandle, 'Tag', 'colorLock');
switch in
    
    case 'Plot heatmap'
        if isempty(sData)
            return
        end
        
		% Opens summary file
        fileName = sData{sNumber}.fullName;
        fHandle = fopen(fileName);
        if fHandle == -1
            errordlg(['Unable to open ' fileName], 'Load error');
            return
        end

		% Obtain metadata
        frames      = fscanf(fHandle, '%d', 1);
        pxl_width   = fscanf(fHandle, '%d', 1);
        unitWidth   = fscanf(fHandle, '%f', 1);
        unitTime    = fscanf(fHandle, '%f', 1);
        unitHeight  = fscanf(fHandle, '%f', 1);

        unitTime = unitTime *1e-6;          % Change units to seconds
		
		% Read in summary file
        fseek(fHandle, 1, 'cof');
        switch fileName(end-3:end)

            case '.gmp'
                summary = fread(fHandle, [pxl_width, frames], 'double=>double');

            case '.su3'
                summary = fread(fHandle, [pxl_width, frames], 'double=>double');

            otherwise
                errordlg(['The file' fileName 'cannot be opened. Please select a .gmp or a .su3 file.'], 'Format error');
                return
        end
        
        try
            
            LeftBox   = fscanf(fHandle, '%d', 1);
            TopBox   = fscanf(fHandle, '%d', 1);
            WidthBox   = fscanf(fHandle, '%d', 1);
            HeightBox   = fscanf(fHandle, '%d', 1);
            VidName = fscanf(fHandle, '%s');
            
            sData{sNumber}.exparams.Box{1} = num2str(WidthBox);
            sData{sNumber}.exparams.Box{2} = num2str(HeightBox);
            sData{sNumber}.exparams.Box{3} = num2str(LeftBox);
            sData{sNumber}.exparams.Box{4} = num2str(TopBox);
            sData{sNumber}.exparams.VidName =  VidName;

        end;

        fclose(fHandle);
		
        summary = double(summary);
        summary = summary * unitHeight;

        sData{sNumber}.parameters = [frames pxl_width unitWidth ...
                                           unitTime unitHeight];
        set(sList, 'UserData', sData);
        
		% Obtain color range automatically
        minVal = min(summary(:));
        maxVal = max(summary(:));
        if maxVal == minVal
            maxVal = maxVal + 0.1;
        end
        
		% If color range is locked, don't update
        if ~isempty(oldImage)
            locked = get(colorLock, 'Value');
            if locked
                if ~isempty(get(colorMin, 'String'))
                    minVal = str2num(get(colorMin, 'String'));
                end

                if ~isempty(get(colorMax, 'String'))
                    maxVal = str2num(get(colorMax, 'String'));
                end
            end
        end
        
		% Set color range
        set(colorMin, 'String', minVal, 'UserData', minVal, 'Enable', 'on');
        set(colorMax, 'String', maxVal, 'UserData', maxVal, 'Enable', 'on');
        set(undoColor, 'String', 'Undo');
        axes(mainAxes)
        
		% Plot summary file to scale with time and space
        t1 = unitTime;
        t2 = frames*unitTime;
        x1 = unitWidth;
        x2 = pxl_width*unitWidth;
        
        imageHandle = imagesc([t1 t2], [x1 x2], summary, 'Parent', mainAxes, [minVal maxVal]);
        
        set(imageHandle, 'Tag', 'heatmapImage')
        title('Spatiotemporal heatmap')
        xlabel('Time (s)')
        ylabel('Gut position (mm)')
        
		% Enable menus
        set(findobj(guiHandle, 'Tag', 'colorSchemes'), 'Enable', 'on');
        set(findobj(guiHandle, 'Tag', 'exportMenu'), 'Enable', 'on');
        set(findobj(guiHandle, 'Tag', 'advancedMenu'), 'Enable', 'on');
		
		% Obtain the relevant colormap
        checked = findall(findobj(guiHandle, 'Tag', 'colorSchemes'), 'Checked', 'on');
        switch get(checked(1), 'Tag')

            case 'jetHeatmap'
                colormap('jet')
            case 'hsvHeatmap'
                colormap('hsv')
            case 'hotHeatmap'
                colormap('hot')
            case 'coolHeatmap'
                colormap('cool')
            case 'boneHeatmap'
                colormap('bone')
            case 'grayHeatmap'
                colormap('gray')
        end
        
		
        cmap = flipdim(colormap,1);     % Set hot colors to contracted and cool colors to dilated
        colormap(cmap);
        cbar = colorbar('peer', mainAxes);
        set(get(cbar, 'Ylabel'), 'String', 'Gut Width (mm)');
        
		% Enable appropriate buttons for color updating and analysis
        set(undoColor, 'Enable', 'off');
        set(autoColor, 'Enable', 'on');
        set(colorLock, 'Enable', 'on');
        set(findobj(guiHandle, 'Tag', 'csButton'), 'Enable', 'on');
        set(findobj(guiHandle, 'Tag', 'cwButton'), 'Enable', 'on');
        set(findobj(guiHandle, 'Tag', 'zoomAxes'), 'Visible', 'on');
        
		% Generate time zoom sliders
        set(findobj(guiHandle, 'Tag', 'leftSlider'), 'XData', [0 0]);
        set(findobj(guiHandle, 'Tag', 'rightSlider'), 'XData', [1 1]);
        set(findobj(guiHandle, 'Tag', 'zoomMin'), 'String', '0.00 s', 'Enable', 'on');
        set(findobj(guiHandle, 'Tag', 'zoomMax'), 'String', sprintf('%.2f s', t2), 'Enable', 'on');
        
        setAllowAxesZoom(zoom,mainAxes,true);
        setAllowAxesPan(pan,mainAxes,true);
        graphing_callback('Update summary stats', guiHandle);
    
    case 'New color scheme'
	
		% Obtain the relevant colormap
        checked = findall(findobj(guiHandle, 'Tag', 'colorSchemes'), 'Checked', 'on');
        switch get(checked(1), 'Tag')

            case 'jetHeatmap'
                colormap('jet')
            case 'hsvHeatmap'
                colormap('hsv')
            case 'hotHeatmap'
                colormap('hot')
            case 'coolHeatmap'
                colormap('cool')
            case 'boneHeatmap'
                colormap('bone')
            case 'grayHeatmap'
                colormap('gray')
        end
        
        cmap = flipdim(colormap,1);     % Set hot colors to contracted and cool colors to dilated
        colormap(cmap);
        
    case 'Update colormap'
	
		% Get old color values, and store them behind new values
        oldMin = get(colorMin, 'UserData');
        oldMax = get(colorMax, 'UserData');
        minVal = str2num(get(colorMin, 'String'));
        maxVal = str2num(get(colorMax, 'String'));
        if maxVal > minVal
            set(colorMin, 'UserData', [minVal oldMin(1)]);
            set(colorMax, 'UserData', [maxVal oldMax(1)]);
			
			% If colors not inverted, update color scheme
            if strcmp(get(undoColor, 'Enable'), 'off')
                set(undoColor, 'Enable', 'on');
            end
            if strcmp(get(undoColor, 'String'), 'Redo')
                set(undoColor, 'String', 'Undo');
            end
        	caxis(mainAxes, [minVal maxVal]);
        end
        
    case 'Revert color'
	
		% Store current values, and get previous color values
        oldMin = get(colorMin, 'UserData');
        oldMax = get(colorMax, 'UserData');
        minVal = oldMin(end);
        maxVal = oldMax(end);
        set(colorMin, 'String', minVal);
        set(colorMax, 'String', maxVal);
        set(colorMin, 'UserData', oldMin(end:-1:1));
        set(colorMax, 'UserData', oldMax(end:-1:1));
        
		% Toggle between 'Undo' and 'Redo' text
        if strcmp(get(undoColor, 'String'), 'Undo')
            set(undoColor, 'String', 'Redo');
        elseif strcmp(get(undoColor, 'String'), 'Redo')
            set(undoColor, 'String', 'Undo');
        end
        
		% Update color range
        caxis(mainAxes, [minVal maxVal]);
        
    case 'Auto color'
        % Find greatest and smallest values in heatmap
        summary = get(oldImage, 'CData');
        minVal = min(summary(:));
        maxVal = max(summary(:));
        if maxVal == minVal
            maxVal = maxVal + 0.1;
        end
        
		% Update color range
        caxis(mainAxes, [minVal maxVal]);
        
		% Update values in min/max boxes
        oldMin = get(colorMin, 'UserData');
        oldMax = get(colorMax, 'UserData');
        set(colorMin, 'String', minVal, 'UserData', [minVal oldMin(1)]);
        set(colorMax, 'String', maxVal, 'UserData', [maxVal oldMax(1)]);
        
        set(undoColor, 'String', 'Undo');
        caxis(mainAxes, [minVal maxVal]);
        
    case 'Update summary stats'
        if ~isempty(sData)
		
			% Get parameters
            sFile = sData{sNumber};
            frames     = sFile.parameters(1);
            pxl_width  = sFile.parameters(2);
            unitWidth  = sFile.parameters(3);
            framerate  = 1/sFile.parameters(4);
			
			% Add text to parameter box
            parameterBox = findobj(guiHandle, 'Tag', 'heatmapStats');
            
            set(parameterBox, 'HorizontalAlignment', 'Left','String', ...
            {sprintf('%i', frames)     , sprintf('%i pixels', pxl_width)  , ...
             sprintf('%.1f fps', framerate), ...
             sprintf('%.4f mm/pixel', unitWidth)});
         
            try
                videoName = findobj(guiHandle,'Tag','videoName');
                boxInfo = findobj(guiHandle,'Tag','boxInfo');
                set(videoName, 'HorizontalAlignment', 'Left','String', ...
                        {sprintf('%s',sFile.exparams.VidName)});
                set(boxInfo, 'HorizontalAlignment', 'Left','String', ...
                       {sprintf(sFile.exparams.Box{1}),...
                        sprintf(sFile.exparams.Box{2}),...
                        sprintf(sFile.exparams.Box{3}),...
                        sprintf(sFile.exparams.Box{4})});
            end;
        end
   
    case 'Update video stats'
        
        if ~isempty(vData)
			% Get parameters
            vFile = vData{vNumber};
            frames     = vFile.video.NumberOfFrames;
            height     = vFile.video.Height;
            width      = vFile.video.Width;
            framerate  = vFile.video.FrameRate;
        
			% Add text to parameter box
            statBox1 = findobj(guiHandle, 'Tag', 'videoStats1');
            set(statBox1, 'HorizontalAlignment', 'Left','String', ...
                    {sprintf('%i'  , frames   ) ...
                     sprintf('%i pixels'  , height   ) ...
                     sprintf('%i pixels'  , width    ) ...
                     sprintf('%.2f fps', framerate)});
        end
        
    case 'Clear heatmap'
        
        delete(imageHandle)
        set(mainAxes, 'Visible', 'off');
        colorbar('delete');
        
    case 'Clear stats'
        
        parameterBox = findobj(guiHandle, 'Tag', 'properties');
        set(parameterBox,'String', '');
        
end