%#################################
% GutMap 2014-2024
%#################################
function sliceprop_callback(in, guiHandle)
% ------------------------------------------------------------------------
%   ROLE
%
% Manages the display and modification of the properties of slices taken 
% within the cross section panel. 
% 
% ------------------------------------------------------------------------
%   DESCRIPTION
%
% SLICEPROP_CALLBACK(ARGIN, HGUI) manages the slice properties displayed in
% the two panels containing the 'timeSliceNames' and 'spaceSliceNames'
% popup menus in the GUI window with handle HGUI, as well as the edit boxes
% in the adjacent panel. ARGIN can take one of several values, shown below:
%
%   - 'Populate names' searches the user data of the file list for the
%   slices that have been stored for the current file. These slices are
%   sorted into vertical and horizontal lines, which are then labelled as
%   space and time slices respectively. The names are listed in order
%   of their construction, newest first, in the popup menus tagged as
%   'timeSliceNames' and 'spaceSliceNames' in the main GUI window. If
%   either list is empty, the other edit boxes and popup menus
%   corresponding to that list of names are disabled, otherwise they are
%   enabled.
%
%   - 'Populate time slice properties' identifies the slice that is
%   selected within the list of time slices, and displays the parameters of
%   that slice within the edit boxes.
%
%   - 'Populate space slice properties' identifies the slice that is
%   selected within the list of space slices, and displays the parameters
%   of that slice within the edit boxes.
%
%   - 'Remove time slice' sets the displayed values of the edit
%   boxes of the time slice properties to be empty, and the color to be 
%   blue.
%
%   - 'Remove space slice' sets the displayed values of the edit
%   boxes of the space slice properties to be empty, and the color to be 
%   blue.
%
%   - 'Update time slice properties' sets the selected time slice to match
%   the properties displayed in the time slice properties boxes. The
%   coordinates for space and time are snapped onto the grid of the current
%   image.
%
%   - 'Update space slice properties' sets the selected space slice to 
%   match the properties displayed in the space slice properties boxes. The
%   coordinates for space and time are snapped onto the grid of the current
%   image.
% ------------------------------------------------------------------------

% Handles to property interface
temporalNames = findobj(guiHandle, 'Tag', 'temporalNames');
spatialNames  = findobj(guiHandle, 'Tag', 'spatialNames');

temporalColors = findobj(guiHandle, 'Tag', 'temporalColors');
temporalRename = findobj(guiHandle, 'Tag', 'temporalRename');
removeTemporal = findobj(guiHandle, 'Tag', 'removeTemporal');

spatialColors = findobj(guiHandle, 'Tag', 'spatialColors');
spatialRename = findobj(guiHandle, 'Tag', 'spatialRename');
removeSpatial = findobj(guiHandle, 'Tag', 'removeSpatial');

% Axis handles
timeAxes     = findobj(guiHandle, 'Tag', 'timeAxes');
freqAxes     = findobj(guiHandle, 'Tag', 'freqAxes');
spaceAxes    = findobj(guiHandle, 'Tag', 'spaceAxes');
invSpaceAxes = findobj(guiHandle, 'Tag', 'invSpaceAxes');

timeHistogram = findobj(guiHandle, 'Tag', 'timeHistogram');
xlim(timeHistogram,'auto');
spaceHistogram = findobj(guiHandle, 'Tag', 'spaceHistogram');
xlim(spaceHistogram,'auto');

imageHandle  = findobj(guiHandle, 'Tag', 'heatmapImage');
slices = get(imageHandle, 'UserData');

switch in
    
    case 'Populate names'
        % Default values for other properties
        set(temporalNames, 'Value', 1);
        set(spatialNames, 'Value', 1);
        set(temporalNames, 'String', {' '})
        set(spatialNames, 'String', {' '})
        
        timeIDs  = zeros(size(slices));
        spaceIDs = zeros(size(slices));
        Tcount = 0;
        Xcount = 0;
        
		% Sort slices
        Tstring = {' '};
        Xstring = {' '};
        for i = 1 : length(slices)
            switch slices(i).type
                case 'hLine'
                    Tcount = Tcount + 1;
                    Tstring{Tcount} = slices(i).name;
                    timeIDs(Tcount) = slices(i).id;
                case 'vLine'
                    Xcount = Xcount + 1;
                    Xstring{Xcount} = slices(i).name;
                    spaceIDs(Xcount) = slices(i).id;
            end
        end
		
        % newest first
        timeIDs = timeIDs(Tcount:-1:1);
        spaceIDs = spaceIDs(Xcount:-1:1);
        
        set(temporalNames, 'UserData', timeIDs);
        set(spatialNames , 'UserData', spaceIDs);
        
        set(temporalNames, 'String'  , Tstring(max(Tcount,1):-1:1));
        set(spatialNames , 'String'  , Xstring(max(Xcount,1):-1:1));
		
        % Enable controls
        if ~isempty(timeIDs)
            set(temporalNames , 'Enable', 'on');
            set(temporalColors, 'Enable', 'on');
            set(temporalRename, 'Enable', 'on');
            set(removeTemporal, 'Enable', 'on');
        end        
        
        if ~isempty(spaceIDs)
            set(spatialNames , 'Enable', 'on');
            set(spatialColors, 'Enable', 'on');
            set(spatialRename, 'Enable', 'on');
            set(removeSpatial, 'Enable', 'on');
        end
        sliceprop_callback('Populate time slice properties', guiHandle);
        sliceprop_callback('Populate space slice properties', guiHandle);
   
    case 'Update names'  % Unused @ 01/2024
        % Default values for other properties
        set(temporalNames, 'Value', 1);
        set(spatialNames, 'Value', 1);
        set(temporalNames, 'String', {' '})
        set(spatialNames, 'String', {' '})
        
        timeIDs  = zeros(size(slices));
        spaceIDs = zeros(size(slices));
        Tcount = 0;
        Xcount = 0;
        
		% Sort slices
        Tstring = {' '};
        Xstring = {' '};
        for i = 1 : length(slices)
			% Recalculates the cross section and power spectrum
            endSlice(guiHandle, slices(i).id, slices(i).line);
            switch slices(i).type
                case 'hLine'
                    Tcount = Tcount + 1;
                    Tstring{Tcount} = slices(i).name;
                    timeIDs(Tcount) = slices(i).id;
                case 'vLine'
                    Xcount = Xcount + 1;
                    Xstring{Xcount} = slices(i).name;
                    spaceIDs(Xcount) = slices(i).id;
            end
        end
        
        % newest first
        timeIDs = timeIDs(Tcount:-1:1);
        spaceIDs = spaceIDs(Xcount:-1:1);
        
        set(temporalNames, 'UserData', timeIDs);
        set(spatialNames , 'UserData', spaceIDs);
        
        set(temporalNames, 'String'  , Tstring(max(Tcount,1):-1:1));
        set(spatialNames , 'String'  , Xstring(max(Xcount,1):-1:1));
        
        % Enable controls
        if ~isempty(timeIDs)
            set(temporalNames , 'Enable', 'on');
            set(temporalColors, 'Enable', 'on');
            set(temporalRename, 'Enable', 'on');
            set(removeTemporal, 'Enable', 'on');
        end        
        
        if ~isempty(spaceIDs)
            set(spatialNames , 'Enable', 'on');
            set(spatialColors, 'Enable', 'on');
            set(spatialRename, 'Enable', 'on');
            set(removeSpatial, 'Enable', 'on');
        end
        sliceprop_callback('Populate time slice properties', guiHandle);
        sliceprop_callback('Populate space slice properties', guiHandle);
        
    case 'Populate time slice properties' 
        
		% Control visibility
        timeIDs = get(temporalNames, 'UserData');
        if ~isempty(timeIDs)
            set(timeAxes, 'Visible', 'on');
            set(freqAxes, 'Visible', 'on');
            set(timeHistogram, 'Visible', 'on');
            timeSliceID = timeIDs(get(temporalNames, 'Value'));
        else
            set(timeAxes, 'Visible', 'off');
            set(freqAxes, 'Visible', 'off');
            set(timeHistogram, 'Visible', 'off');
            set(temporalColors, 'Enable', 'off', 'Value', 1);
            set(temporalRename, 'Enable', 'off', 'String', '');
            set(removeTemporal, 'Enable', 'off');
            timeSliceID = 0;
        end
        
		% Fill property boxes
        for i = 1 : length(slices)
            if slices(i).id == timeSliceID
                set(temporalColors, 'Value', slices(i).color);
                set(temporalRename, 'String', slices(i).name);

                temporalColorNames = get(temporalColors,'String');
                setColor(slices(i).line, temporalColorNames{slices(i).color});
                
            elseif strcmp(slices(i).type, 'hLine')
                temporalColorNames = get(temporalColors,'String');
                setColor(slices(i).line, temporalColorNames{slices(i).color});
            end
            
        end
        
        cla(timeAxes)
        cla(freqAxes)
        cla(timeHistogram)
        set(timeAxes,'XLabel',[]);
        set(freqAxes,'XLabel',[]);
        set(timeHistogram,'XLabel',[]);
        set(timeAxes,'YLabel',[]);
        set(freqAxes,'YLabel',[]);
        set(timeHistogram,'YLabel',[]);
        
		% Restrict frequency plot to contain >90% of the power
        fmax = 0;
        pmax = 0;
        for i = 1 : length(slices)
            if strcmp(slices(i).type, 'hLine')
			    % plot time and frequency plots
                
                temporalColorNames = get(temporalColors,'String');
                currcol = temporalColorNames{slices(i).color};
                
                plot(timeAxes, slices(i).t_domain, slices(i).t_cross, 'Color', currcol);
                plot(freqAxes, slices(i).f_domain, slices(i).f_power, 'Color', currcol);
                histogram(timeHistogram,slices(i).t_cross,'Visible','on','DisplayStyle',...
                            'stairs','EdgeColor',currcol);
                
                set(timeAxes,'Color',[0.8 0.8 0.8]);
                set(freqAxes,'Color',[0.8 0.8 0.8]);
                set(timeHistogram,'Color',[0.8 0.8 0.8]);
                
                xlabel(timeAxes,'Time (seconds)','Visible','on');
                xlabel(freqAxes,'Time (seconds)','Visible','on');
                xlabel(timeHistogram,'Gut Width (mm)','Visible','on');
                ylabel(timeAxes,'Gut Width (mm)','Visible','on');
                ylabel(freqAxes,'Power spectrum','Visible','on');
                ylabel(timeHistogram,'Count','Visible','on');
                
                
                cumulativePower = cumsum(slices(i).f_power);
                thresholdPower = cumulativePower(end) * 0.9;
                N = length(cumulativePower);
                for j = 1 : N
                    if cumulativePower(j) > thresholdPower
                        fbreak = slices(i).f_domain(j);
                        pbreak = max(slices(i).f_power(1:j));
                        break
                    end
                end
                
                fmax = max(fmax, fbreak);
                pmax = max(pmax, pbreak);
            end
        end
        
        if fmax == 0
            fmax = 1;
        end
        if pmax == 0
            pmax = 1;
        end
        
        set(freqAxes, 'XLim', [0 fmax]);
        set(freqAxes, 'YLim', [0 pmax*1.1]);
        
    case 'Populate space slice properties'
        
		% Control visibility
        spaceIDs = get(spatialNames, 'UserData');
        if ~isempty(spaceIDs)
            set(spaceAxes, 'Visible', 'on');
            set(invSpaceAxes, 'Visible', 'on');
            set(spaceHistogram, 'Visible', 'on');
            spaceSliceID = spaceIDs(get(spatialNames, 'Value'));
        else
            set(spaceAxes, 'Visible', 'off');
            set(invSpaceAxes, 'Visible', 'off');
            set(spaceHistogram, 'Visible', 'off');
            set(spatialColors, 'Enable', 'off', 'Value', 1);
            set(spatialRename, 'Enable', 'off', 'String', '');
            set(removeSpatial, 'Enable', 'off');
            spaceSliceID = 0;
        end
        
		% Fill property boxes
        for i = 1 : length(slices)
            if slices(i).id == spaceSliceID

                set(spatialColors, 'Value', slices(i).color);
                set(spatialRename, 'String', slices(i).name);

                spatialColorNames = get(spatialColors,'String');
                setColor(slices(i).line,spatialColorNames{slices(i).color});
                
            elseif strcmp(slices(i).type, 'vLine')
                spatialColorNames = get(spatialColors,'String');
                setColor(slices(i).line,spatialColorNames{slices(i).color});
            end
            
        end
      
        cla(spaceAxes)
        cla(invSpaceAxes)
        cla(spaceHistogram)
        set(spaceAxes,'XLabel',[]);
        set(invSpaceAxes,'XLabel',[]);
        set(spaceHistogram,'XLabel',[]);        
        set(spaceAxes,'YLabel',[]);
        set(invSpaceAxes,'YLabel',[]);
        set(spaceHistogram,'YLabel',[]);
        
		% Restrict frequency plot to contain >90% of the power
        fmax = 0;
        pmax = 0;
        for i = 1 : length(slices)
            if strcmp(slices(i).type, 'vLine')
			    % plot time and frequency plots
                spatialColorNames = get(spatialColors,'String');
                currcol = spatialColorNames{slices(i).color};
                plot(spaceAxes   , slices(i).t_domain, slices(i).t_cross, 'Color', currcol);
                plot(invSpaceAxes, slices(i).f_domain, slices(i).f_power, 'Color', currcol);
                histogram(spaceHistogram,slices(i).t_cross,'Visible','on','DisplayStyle',...
                            'stairs','EdgeColor',currcol);
                        
                set(spaceAxes,'Color',[0.8 0.8 0.8]);
                set(invSpaceAxes,'Color',[0.8 0.8 0.8]);
                set(spaceHistogram,'Color',[0.8 0.8 0.8]);
                
                xlabel(spaceAxes,'Time (seconds)','Visible','on');
                xlabel(invSpaceAxes,'Time (seconds)','Visible','on');
                xlabel(spaceHistogram,'Gut Width (mm)','Visible','on');
                ylabel(spaceAxes,'Gut Width (mm)','Visible','on');
                ylabel(invSpaceAxes,'Power spectrum','Visible','on');
                ylabel(spaceHistogram,'Count','Visible','on');
                
                cumulativePower = cumsum(slices(i).f_power);
                thresholdPower = cumulativePower(end) * 0.9;
                N = length(cumulativePower);
                for j = 1 : N
                    if cumulativePower(j) > thresholdPower
                        fbreak = slices(i).f_domain(j);
                        pbreak = max(slices(i).f_power(1:j));
                        break
                    end
                end
                
                fmax = max(fmax, fbreak);
                pmax = max(pmax, pbreak);
            end
        end
        
        if fmax == 0
            fmax = 1;
        end
        if pmax == 0
            pmax = 1;
        end
        
        set(invSpaceAxes, 'XLim', [0 fmax]);
        set(invSpaceAxes, 'YLim', [0 pmax*1.1]);
        
    case 'Update time slice properties'
        % Find selected ID
        IDs     = get(temporalNames, 'UserData');
        names   = get(temporalNames, 'String');
        sliceID = IDs(get(temporalNames, 'Value'));
        
		% Rename slice and update color
        for i = 1 : length(slices)  
            if slices(i).id == sliceID
                
                slices(i).name  = get(temporalRename, 'String');
                slices(i).color = get(temporalColors,'Value');
                names{get(temporalNames, 'Value')} = slices(i).name;

                temporalColorNames = get(temporalColors,'String');
                setColor(slices(i).line,temporalColorNames{slices(i).color});
                
                set(imageHandle, 'UserData', slices);
                set(temporalNames, 'String', names);
            end
        end
        
		% plot with new colors
        cla(timeAxes)
        cla(freqAxes)
        cla(timeHistogram)
        set(timeAxes,'XLabel',[]);
        set(freqAxes,'XLabel',[]);
        set(timeHistogram,'XLabel',[]);
        set(timeAxes,'YLabel',[]);
        set(freqAxes,'YLabel',[]);
        set(timeHistogram,'YLabel',[]);
                
        
        for i = 1 : length(slices)
            if strcmp(slices(i).type, 'hLine')
                temporalColorNames = get(temporalColors,'String');
                currcol = temporalColorNames{slices(i).color};
                plot(timeAxes, slices(i).t_domain, slices(i).t_cross, 'Color', currcol);
                plot(freqAxes, slices(i).f_domain, slices(i).f_power, 'Color', currcol);
                histogram(timeHistogram,slices(i).t_cross,'DisplayStyle',...
                            'stairs','EdgeColor',currcol,'Visible','on');
                set(timeAxes,'Color',[0.8 0.8 0.8]);
                set(freqAxes,'Color',[0.8 0.8 0.8]);
                set(timeHistogram,'Color',[0.8 0.8 0.8]);
                
                xlabel(timeAxes,'Time (seconds)','Visible','on');
                xlabel(freqAxes,'Time (seconds)','Visible','on');
                xlabel(timeHistogram,'Gut Width (mm)','Visible','on');        
                ylabel(timeAxes,'Gut Width (mm)','Visible','on');
                ylabel(freqAxes,'Power spectrum','Visible','on');
                ylabel(timeHistogram,'Count','Visible','on');
                
            end
        end
        
    case 'Update space slice properties'
        % Find selected ID
        IDs     = get(spatialNames, 'UserData');
        names   = get(spatialNames, 'String');
        sliceID = IDs(get(spatialNames, 'Value'));
        
		% Rename slice and update color
        for i = 1 : length(slices)  
            if slices(i).id == sliceID
                
                slices(i).name = get(spatialRename, 'String');
                slices(i).color = get(spatialColors,'Value');
                names{get(spatialNames, 'Value')} = slices(i).name;

                spatialColorNames = get(spatialColors,'String');
                setColor(slices(i).line, spatialColorNames{slices(i).color});
                
                set(imageHandle, 'UserData', slices);
                set(spatialNames, 'String', names);
            end
        end
        
		% plot with new colors
        cla(spaceAxes)
        cla(invSpaceAxes)
        cla(spaceHistogram)
        set(spaceAxes,'XLabel',[]);
        set(invSpaceAxes,'XLabel',[]);
        set(spaceHistogram,'XLabel',[]);        
        set(spaceAxes,'YLabel',[]);
        set(invSpaceAxes,'YLabel',[]);
        set(spaceHistogram,'YLabel',[]);       
        
        for i = 1 : length(slices)
            if strcmp(slices(i).type, 'vLine')
                spatialColorNames = get(spatialColors,'String');
                currcol = spatialColorNames{slices(i).color};
                plot(spaceAxes, slices(i).t_domain, slices(i).t_cross, 'Color', currcol);
                plot(invSpaceAxes, slices(i).f_domain, slices(i).f_power, 'Color', currcol);
                histogram(spaceHistogram,slices(i).t_cross,'DisplayStyle',...
                            'stairs','EdgeColor',currcol,'Visible','on');  
                set(spaceAxes,'Color',[0.8 0.8 0.8]);
                set(invSpaceAxes,'Color',[0.8 0.8 0.8]);
                set(spaceHistogram,'Color',[0.8 0.8 0.8]);
                
                xlabel(spaceAxes,'Time (seconds)','Visible','on');
                xlabel(invSpaceAxes,'Time (seconds)','Visible','on');
                xlabel(spaceHistogram,'Gut Width (mm)','Visible','on');
                ylabel(spaceAxes,'Gut Width (mm)','Visible','on');
                ylabel(invSpaceAxes,'Power spectrum','Visible','on');
                ylabel(spaceHistogram,'Count','Visible','on');

            end
        end
        
    case 'Remove time slice'
        % Find selected ID
        IDs     = get(temporalNames, 'UserData');
        sliceID = IDs(get(temporalNames, 'Value'));
        
		% Delete line and remove struct of data
        for i = 1 : length(slices)  
            if slices(i).id == sliceID
                delete(slices(i).line);
                slices = [slices(1:i-1) slices(i+1:end)];
                break
            end
        end
		% Repopulate display
        set(imageHandle, 'UserData', slices);
        sliceprop_callback('Populate names', guiHandle)
        
    case 'Remove space slice'
        % Find selected ID
        IDs     = get(spatialNames, 'UserData');
        sliceID = IDs(get(spatialNames, 'Value'));
        
		% Delete line and remove struct of data
        for i = 1 : length(slices)  
            if slices(i).id == sliceID
                delete(slices(i).line);
                slices = [slices(1:i-1) slices(i+1:end)];
                break
            end
        end
		% Repopulate display
        set(imageHandle, 'UserData', slices);
        sliceprop_callback('Populate names', guiHandle)
end

function endSlice(hObject, ID, newSlice)
% handles
imageHandle = findobj(hObject, 'Tag', 'heatmapImage');
heatmapAxes = get(imageHandle, 'Parent');
heatmap = get(imageHandle, 'CData');

% Snap to grid of pixels
XLim = get(heatmapAxes, 'XLim');
YLim = get(heatmapAxes, 'YLim');

XStep = (XLim(2) - XLim(1))/(size(heatmap,2)-1);
YStep = (YLim(2) - YLim(1))/(size(heatmap,1)-1);

rawPosition = getPosition(newSlice);
rawX = rawPosition(:,1);
rawY = rawPosition(:,2);

Xindex = round((rawX - XLim(1))/XStep) + 1;
Yindex = round((rawY - YLim(1))/YStep) + 1;

snapX = XLim(1) + XStep * (Xindex - 1);
snapY = YLim(1) + YStep * (Yindex - 1);

setPosition(newSlice, [snapX, snapY]);

% Take linear cross section
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

% calculate power spectrum
N = length(domain);
N = N - mod(N,2);
p = fft(detrend(cross),N);
if ~isempty(p)
    p(1) = [];
end
power = abs(p(1:N/2)).^2/N;
nyquist = sampling_rate/N;
freq = (0:N/2-1)*nyquist;

slices = get(imageHandle, 'UserData');

% update relevent slice information
for N = 1 : length(slices)
    if slices(N).id == ID
        break
    end
end
slices(N).t_domain = domain;
slices(N).t_cross  = cross ;
slices(N).f_domain = freq;
slices(N).f_power  = power;

set(imageHandle, 'UserData', slices);
