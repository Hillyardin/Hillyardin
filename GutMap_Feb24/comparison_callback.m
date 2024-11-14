%#################################
% GutMap 2014-2024
%#################################

function comparison_callback(in, guiHandle)
% This function controls the processes involved in the window that opens to compare two 
% separate heatmaps.

s1List   = findobj(guiHandle, 'Tag', 'heatmap1Files');
s1Number = get(s1List, 'Value');
s1Data   = get(s1List, 'UserData');

s2List   = findobj(guiHandle, 'Tag', 'heatmap2Files');
s2Number = get(s2List, 'Value');
s2Data   = get(s2List, 'UserData');

% Obtains the parent axes of the first image if one is already displayed. Otherwise 
% obtains the hidden axes. 
oldImage = findobj(guiHandle, 'Tag', 'heatmap1Image');
if isempty(oldImage)
    heatmap1Axes = findobj(guiHandle, 'Tag', 'heatmap1Axes');
else
    heatmap1Axes =get(oldImage, 'Parent');
end

% Obtains the parent axes of the second image if one is already displayed. Otherwise 
% obtains the hidden axes.
oldImage = findobj(guiHandle, 'Tag', 'heatmap2Image');
if isempty(oldImage)
    heatmap2Axes = findobj(guiHandle, 'Tag', 'heatmap2Axes');
else
    heatmap2Axes =get(oldImage, 'Parent');
end

color1Min  = findobj(guiHandle, 'Tag', 'colorMin1');
color1Max  = findobj(guiHandle, 'Tag', 'colorMax1');
color2Min  = findobj(guiHandle, 'Tag', 'colorMin2');
color2Max  = findobj(guiHandle, 'Tag', 'colorMax2');
        
switch in
    
    case 'Load heatmap 1'
        % This case obtains the heatmap for the first file selected and displays it in the first axes.
        if isempty(s1Data)
            return
        end
        
        fileName = s1Data{s1Number}.fullName;
        fHandle = fopen(fileName);

        if fHandle == -1
            errordlg(['Unable to open ' fileName], 'Load error');
            return
        end

		% Read metadata
        frames      = fscanf(fHandle, '%d', 1);
        pxl_width   = fscanf(fHandle, '%d', 1);
        unitWidth   = fscanf(fHandle, '%f', 1);
        unitTime    = fscanf(fHandle, '%f', 1);
        unitHeight  = fscanf(fHandle, '%f', 1);

        unitTime = unitTime *1e-6;          % Change units to seconds

		% Move forward one byte and read heatmap one timestep at a time.
        fseek(fHandle, 1, 'cof');
        switch fileName(end-3:end)

            case '.gmp'
                summary = fread(fHandle, [pxl_width, frames], 'double=>double');

            case '.su3'
                summary = fread(fHandle, [pxl_width, frames], 'double=>double');

            otherwise
                errordlg(['The file ' fileName ' cannot be opened. Please select a .gmp or a .su3 file.'], 'Format error');
                return

        end

        fclose(fHandle);
        summary = double(summary);
        summary = summary * unitHeight;
		
		% Store metadata
        s1Data{s1Number}.parameters = [frames pxl_width unitWidth ...
                                           unitTime unitHeight];
        set(s1List, 'UserData', s1Data);
        
		% Determine color range
        minVal = min(summary(:));
        maxVal = max(summary(:));
        if maxVal == minVal
            maxVal = maxVal + 0.1;
        end
        
        set(color1Min, 'String', minVal, 'Enable', 'on');
        set(color1Max, 'String', maxVal, 'Enable', 'on');
        axes(heatmap1Axes)
        
        t1 = unitTime;
        t2 = frames*unitTime;
        x1 = unitWidth;
        x2 = pxl_width*unitWidth;
        
		% Plot heatmap and label axes
        imageHandle = imagesc([t1 t2], [x1 x2], summary, 'Parent', heatmap1Axes, [minVal maxVal]);
        
        set(imageHandle, 'Tag', 'heatmap1Image')
        title('Spatiotemporal heatmap')
        xlabel('Time (s)')
        ylabel('Gut position (mm)')
        
        colormap('default')
        cmap = flipdim(colormap,1);     % Set hot colors to contracted and cool colors to dilated
        colormap(cmap);
        cbar = colorbar('peer', heatmap1Axes);
        set(get(cbar, 'Ylabel'), 'String', 'Gut Width (mm)');
        
    case 'Load heatmap 2'
        % This case obtains the heatmap for the second file selected and displays it in the second axes.
        
        if isempty(s2Data)
            return
        end
        
        fileName = s2Data{s2Number}.fullName;
        fHandle = fopen(fileName);

        if fHandle == -1
            errordlg(['Unable to open ' fileName], 'Load error');
            return
        end
		
		% Read metadata
        frames      = fscanf(fHandle, '%d', 1);
        pxl_width   = fscanf(fHandle, '%d', 1);
        unitWidth   = fscanf(fHandle, '%f', 1);
        unitTime    = fscanf(fHandle, '%f', 1);
        unitHeight  = fscanf(fHandle, '%f', 1);

        unitTime = unitTime *1e-6;          % Change units to seconds

		% Move forward one byte and read heatmap one timestep at a time.
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

        fclose(fHandle);
        summary = double(summary);
        summary = summary * unitHeight;
		
		% Store metadata
        s2Data{s2Number}.parameters = [frames pxl_width unitWidth ...
                                           unitTime unitHeight];
        set(s2List, 'UserData', s2Data);
        
		% Determine color range
        minVal = min(summary(:));
        maxVal = max(summary(:));
        if maxVal == minVal
            maxVal = maxVal + 0.1;
        end
        
        set(color2Min, 'String', minVal, 'Enable', 'on');
        set(color2Max, 'String', maxVal, 'Enable', 'on');
        axes(heatmap2Axes)
        
        t1 = unitTime;
        t2 = frames*unitTime;
        x1 = unitWidth;
        x2 = pxl_width*unitWidth;
        
		% Plot heatmap and label axes        
        imageHandle = imagesc([t1 t2], [x1 x2], summary, 'Parent', heatmap2Axes, [minVal maxVal]);
        
        set(imageHandle, 'Tag', 'heatmap2Image')
        title('Spatiotemporal heatmap')
        xlabel('Time (s)')
        ylabel('Gut position (mm)')
        
        colormap('default')
        cmap = flipdim(colormap,1);     % Set hot colors to contracted and cool colors to dilated
        colormap(cmap);
        cbar = colorbar('peer', heatmap2Axes);
        set(get(cbar, 'Ylabel'), 'String', 'Gut Width (mm)');
        
    case 'Update color 1'
        % Updates the color scheme of the first heatmap
        minVal = str2num(get(color1Min, 'String'));
        maxVal = str2num(get(color1Max, 'String'));
        if maxVal > minVal
        	caxis(heatmap1Axes, [minVal maxVal]);
        end
        
    case 'Update color 2'
        % Updates the color scheme of the second heatmap
        minVal = str2num(get(color2Min, 'String'));
        maxVal = str2num(get(color2Max, 'String'));
        if maxVal > minVal
        	caxis(heatmap2Axes, [minVal maxVal]);
        end
        
end