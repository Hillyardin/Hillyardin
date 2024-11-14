%#################################
% GutMap 2014-2024
%#################################
function io_callback(in,guiHandle)
% 
% ------------------------------------------------------------------------
%   ROLE
%
% Manages the importing and exporting of files from the edge detection
% and heatmap analysis windows. 
% 
% ------------------------------------------------------------------------
%   DESCRIPTION
%
% IO_CALLBACK(ARGIN, HGUI) manages the file list displayed as a listbox in 
% the GUI window with handle HGUI. ARGIN can take one of several values, 
% shown below:
%
%   - 'Add video file' asks the user to select one or more videos from a 
%   dialog window, and attempts to access these files. Upon
%   accessing the files, the list box is then checked for any identical
%   entries before adding all unique files.
%
%   - 'Add summary file' asks the user to select one or more files from a 
%   dialog window with the extension .su2 or .su3, and attempts to access
%   these files. Upon accessing the files, the list box is then checked 
%   for any identical entries before adding all unique files.
%
%   - 'Add video directory' adds all unique videos from a directory
%	  selected by the user.
%
%   - 'Add summary directory' adds all unique summary files from a directory
%	  selected by the user.
%
%   - 'Export to Excel' invokes an Excel window and loads the panels from the
%	  current session into the sheets, as well as relevant graphs and data.
% 
% ------------------------------------------------------------------------

% Get video list
vList = findobj(guiHandle, 'Tag', 'videoList');

% Get summary file list and data
sList = findobj(guiHandle, 'Tag', 'summaryList');
sData = get(sList, 'UserData');
sNumber = get(sList,'Value');

switch in
    case 'Add video'
        
        % Get file names and the total number of files
        home = get(guiHandle, 'UserData');
        if isempty(home)
            home  = pwd;
        end
        %[fileNames, pathName, accessed] = uigetfile({'*.avi;*.m4v', 'AVI video files (.*.avi)'}, 'Choose video to import', home, 'MultiSelect','on');
        [fileNames, pathName, accessed] = uigetfile({'*.avi;*.m4v;*.mp4', 'AVI or MPEG video files (*.avi,*.mp4,*.m4v)'}, 'Choose video to import', home, 'MultiSelect','on');
        if isequal(pathName,0)
            return
        end
        set(guiHandle, 'UserData', pathName);
        
        if (iscell(fileNames))
            filenumber = size(fileNames, 2);
        else
            filenumber = 1;
        end
        
        % Update the listbox of files
        for count = 1 : filenumber
            
            if (iscell(fileNames))
                fileName = fileNames{count};
            else
                fileName = fileNames;
            end
            
            % Returns if the file wasn't accessible, and does nothing if
            % the user cancels
            if (isequal(fileName,0) || isequal(pathName,0)) && accessed 
                errordlg(['An error occurred. ', fileName, ' was not opened.'], 'Open error');
                return
            elseif accessed
                [pathName, fileName, extension] = fileparts([pathName '/' fileName]);
                add_video(vList, {pathName fileName extension})
            end
            
        end
            
        if ~isempty(get(vList, 'UserData'))
            % First file means controls should be enabled
            set(findobj(guiHandle, 'Tag', 'timeSlider'), 'Enable', 'on');
            set(findobj(guiHandle, 'Tag', 'contrastSlider'), 'Enable', 'on');
            set(findobj(guiHandle, 'Tag', 'brightnessSlider'), 'Enable', 'on');
            set(findobj(guiHandle, 'Tag', 'frameWidth'), 'Enable', 'off');
            set(findobj(guiHandle, 'Tag', 'CalibrateButton'), 'Enable', 'off');
            set(findobj(guiHandle, 'Tag', 'edit_EdgeSmooth'), 'Enable', 'on');
        end

    case 'Add summary'
        
        % Get file names and the total number of files
        home = get(guiHandle, 'UserData');
        if isempty(home)
            home  = pwd;
        end
        [fileNames, pathName, accessed] = ...
            uigetfile({'*.gmp;*.su3', 'Summary files (*.gmp,*.su3)'},...
                    'Choose summary file', home, 'MultiSelect','on');
        if isequal(pathName,0)
            return
        end
        set(guiHandle, 'UserData', pathName);
        
        if (iscell(fileNames))
            filenumber = size(fileNames, 2);
        else
            filenumber = 1;
        end
        
        % Update the listbox of files
        for count = 1 : filenumber
            
            if (iscell(fileNames))
                fileName = fileNames{count};
            else
                fileName = fileNames;
            end
            
            % Returns if the file wasn't accessible, and does nothing if
            % the user cancels
            if (isequal(fileName,0) || isequal(pathName,0)) && accessed 
                errordlg(['An error occurred. ', fileName, ' was not opened.'], 'Open error');
                return
            elseif accessed
                [pathName, fileName, extension] = fileparts([pathName '/' fileName]);
                add_summary(sList, {pathName fileName extension})
            end
        end
        
    case 'Add video directory'
        % Obtain the path name of the directory to be added
        home = get(guiHandle, 'UserData');
        if isempty(home)
            home  = pwd;
        end
        pathName = uigetdir(home, 'Choose a folder to add');
        if isequal(pathName,0)
            return
        end
        pathData = dir(pathName);
        set(guiHandle, 'UserData', pathName);
        
        % Iterate over every file, searching for file names which contain
        % the summary figure extension
        for index = 1 : length(pathData)
            [pathName, fileName, extension] = fileparts([pathName '\' pathData(index).name]);
                if strcmp(extension, '.avi')
                    if ~strcmp(pathName(end), '\')
                        pathName = [pathName '\'];
                    end
                    add_video(vList, {pathName fileName extension})
                end
        end
            
        if ~isempty(get(vList, 'UserData'))
            % First file means controls should be enabled
            set(findobj(guiHandle, 'Tag', 'timeSlider'), 'Enable', 'on');
            set(findobj(guiHandle, 'Tag', 'contrastSlider'), 'Enable', 'on');
            set(findobj(guiHandle, 'Tag', 'brightnessSlider'), 'Enable', 'on');
            set(findobj(guiHandle, 'Tag', 'frameWidth'), 'Enable', 'off');
            set(findobj(guiHandle, 'Tag', 'CalibrateButton'), 'Enable', 'off');
        end
        
    case 'Add summary directory'
        % Obtain the path name of the directory to be added
        home = get(guiHandle, 'UserData');
        if isempty(home)
            home  = pwd;
        end
        pathName = uigetdir(home, 'Choose a folder to add');
        if isequal(pathName,0)
            return
        end
        pathData = dir(pathName);
        set(guiHandle, 'UserData', pathName);
        
        % Iterate over every file, searching for file names which contain
        % the summary figure extension
        for index = 1 : length(pathData)
            [pathName, fileName, extension] = fileparts([pathName '\' pathData(index).name]);
                if strcmp(extension, '.gmp') || strcmp(extension, '.su3')
                    if ~strcmp(pathName(end), '\')
                        pathName = [pathName '\'];
                    end
                    add_summary(sList, {pathName fileName extension})
                end
        end
        
    case 'Export to Excel'
        
		% Find open windows
        CSPanel = findall(0, 'Name', 'crossSectionPanel');
        CWPanel = findall(0, 'Name', 'heatmapAnnotationPanel');
        
		% Invoke Excel window
        Excel = actxserver('Excel.Application');
        Excel.Workbooks.Add;
        Sheets = Excel.ActiveWorkBook.Sheets;
        
		% First sheet contains front panel
        Sheet1 = get(Sheets, 'Item', 1);
        set(Sheet1, 'Name', 'Front Panel');
        Sheet1.Activate;
        
        Sheet1.Columns.ColumnWidth = 22.1;
        Sheet1.Rows.Item(1).RowHeight = 15;
        Sheet1.Rows.Item(2).RowHeight = 36;
        
		% Copy panel into sheet
        Sheet1.Range('B2:E2').Select;
        Excel.Selection.MergeCells = 1;
        Excel.Selection.Value = 'Heatmap Analysis Home Panel';
        set(Excel.Selection, 'HorizontalAlignment', 3);
        set(Excel.Selection, 'VerticalAlignment', -4108);
        set(Excel.Selection.Font, 'Size', 16);
        set(Excel.Selection.Font, 'Bold', 1);
        set(Excel.Selection.Font, 'Name', 'Georgia');
        
        Sheet1.Rows.Item(41).RowHeight = 36;
        
		% Highlight region that is selected on full heatmap
        Sheet1.Range('B41:E41').Select;
        Excel.Selection.MergeCells = 1;
        Excel.Selection.Value = 'Full Heatmap with Region of Interest';
        set(Excel.Selection, 'HorizontalAlignment', 3);
        set(Excel.Selection, 'VerticalAlignment', -4108);
        set(Excel.Selection.Font, 'Size', 16);
        set(Excel.Selection.Font, 'Bold', 1);
        set(Excel.Selection.Font, 'Name', 'Georgia');
        
		% Copy in analysis panel image and clear image
        Shapes = Sheet1.Shapes;
        print(guiHandle, '-dmeta', 'tempPanel.emf');
        Shapes.AddPicture([pwd '\tempPanel.emf'] ,0,1,121,52,480,540);
        delete('tempPanel.emf');
        
		% Build image of full heatmap with highlight
        fullHeatmapfig = figure;
        set(fullHeatmapfig, 'Position', [50 50 640 420], 'Visible', 'off');
        summary = get(findobj(guiHandle, 'Tag', 'heatmapImage'), 'CData');
        heatmapAxes = get(findobj(guiHandle, 'Tag', 'heatmapImage'), 'Parent');
        
        sList   = findobj(guiHandle, 'Tag', 'summaryList');
        sNumber = get(sList, 'Value');
        sData   = get(sList, 'UserData');
        sUnits  = sData{sNumber}.parameters;
        
        t1 = sUnits(4);
        t2 = sUnits(1) * t1;
        x1 = sUnits(3);
        x2 = sUnits(2) * x1;
        
        imageHandle = imagesc([t1 t2], [x1 x2], summary, caxis(heatmapAxes));
        
        title('Spatiotemporal heatmap')
        xlabel('Time (s)')
        ylabel('Gut position (mm)')
        
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
        cbar = colorbar('peer', get(imageHandle, 'Parent'));
        set(get(cbar, 'Ylabel'), 'String', 'Gut Width (mm)');
        
        XLims = get(heatmapAxes, 'XLim');
        YLims = get(heatmapAxes, 'YLim');
        
        imrect(get(imageHandle, 'Parent'), [XLims(1), YLims(1), XLims(2)-XLims(1), YLims(2)-YLims(1)]);
        
		% Copy image into sheet and clear image
        print(fullHeatmapfig, '-dmeta', 'tempROI.emf');
        close(fullHeatmapfig);
        Shapes.AddPicture([pwd '\tempROI.emf'] ,0,1,121,658,480,315);
        delete('tempROI.emf');
        
        if ~isempty(CSPanel)
			% Begin cross section panel
            Sheet2 = Sheets.Add([], Sheets.Item(Sheets.Count));
            set(Sheet2, 'Name', 'Cross Section Data');
            Sheet2.Activate;
            
            Sheet2.Columns.ColumnWidth = 22.1;
            Sheet2.Rows.Item(1).RowHeight = 15;
            Sheet2.Rows.Item(2).RowHeight = 36;
			
			% Title
            Sheet2.Range('B2:E2').Select;
            Excel.Selection.MergeCells = 1;
            Excel.Selection.Value = 'Heatmap Cross Section Home Panel';
            set(Excel.Selection, 'HorizontalAlignment', 3);
            set(Excel.Selection, 'VerticalAlignment', -4108);
            set(Excel.Selection.Font, 'Size', 16);
            set(Excel.Selection.Font, 'Bold', 1);
            set(Excel.Selection.Font, 'Name', 'Georgia');
			
			%  Copy image of panel
            Shapes = Sheet2.Shapes;
            print(CSPanel, '-dmeta', 'tempCSPanel.emf');
            Shapes.AddPicture([pwd '\tempCSPanel.emf'] ,0,1,121,52,480,540);
            delete('tempCSPanel.emf');
            
			% Determine whether time or space cross sections are needed
            tAxis = findobj(CSPanel, 'Tag', 'timeAxes');
            tOn = strcmp(get(tAxis, 'Visible'), 'on');
            
            sAxis = findobj(CSPanel, 'Tag', 'spaceAxes');
            sOn = strcmp(get(sAxis, 'Visible'), 'on');
            
            if tOn || sOn
			    % Determine number of plots to include
                Sheet2.Rows.Item(41).RowHeight = 36;
                Sheet2.Rows.Item(43).RowHeight = 24;
                Sheet2.Rows.Item(67).RowHeight = 24;
                if tOn && sOn
                    Sheet2.Rows.Item(91).RowHeight = 24;
                    Sheet2.Rows.Item(115).RowHeight = 24;
                end
                Sheet2.Range('B41:E41').Select;
                Excel.Selection.MergeCells = 1;
                Excel.Selection.Value = 'Cross Section Plots';
                set(Excel.Selection, 'HorizontalAlignment', 3);
                set(Excel.Selection, 'VerticalAlignment', -4108);
                set(Excel.Selection.Font, 'Size', 16);
                set(Excel.Selection.Font, 'Bold', 1);
                set(Excel.Selection.Font, 'Name', 'Georgia');
				
				% First subheadings
                Sheet2.Range('B43:C43').Select;
                Excel.Selection.MergeCells = 1;
                if tOn
                    Excel.Selection.Value = 'Time Cross Section:';
                else
                    Excel.Selection.Value = 'Space Cross Section:';
                end
                set(Excel.Selection, 'HorizontalAlignment', 1);
                set(Excel.Selection, 'VerticalAlignment', -4108);
                set(Excel.Selection.Font, 'Size', 13);
                set(Excel.Selection.Font, 'Bold', 1);
                set(Excel.Selection.Font, 'Name', 'Georgia');
				
				% Generate subfigure of plot in time axis
                tCSfig = figure;
                set(tCSfig, 'Position', [50 50 800 420], 'Visible', 'off');
                if tOn
                    tAxes = copyobj(tAxis, tCSfig);
                else
                    tAxes = copyobj(sAxis, tCSfig);
                end
                set(tAxes, 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8])
                
				% Captions
                if tOn 
                    title('Cross section taken over a time span');
                    xlabel('Time Elapsed (s)');
                    ylabel('Gut Width (mm)');
                    tNames = get(findobj(CSPanel, 'tag', 'temporalNames'), 'String');
                    legend(tNames(end:-1:1), 'Location', 'NorthEastOutside');
                else
                    title('Cross section taken over a section of gut');
                    xlabel('Gut Position (mm)');
                    ylabel('Gut Width (mm)');
                    tNames = get(findobj(CSPanel, 'tag', 'spatialNames'), 'String');
                    legend(tNames(end:-1:1), 'Location', 'NorthEastOutside');
                end
				
				% Copy image
                print(tCSfig, '-dmeta', 'tempTCS.emf');
                close(tCSfig);
                Shapes.AddPicture([pwd '\tempTCS.emf'] ,0,1,121,697,600,315);
                delete('tempTCS.emf');
				
				% Second subheading
                Sheet2.Range('B67:C67').Select;
                Excel.Selection.MergeCells = 1;
                if tOn
                    Excel.Selection.Value = 'Time Power Spectrum:';
                else
                    Excel.Selection.Value = 'Space Power Spectrum:';
                end
                set(Excel.Selection, 'HorizontalAlignment', 1);
                set(Excel.Selection, 'VerticalAlignment', -4108);
                set(Excel.Selection.Font, 'Size', 13);
                set(Excel.Selection.Font, 'Bold', 1);
                set(Excel.Selection.Font, 'Name', 'Georgia');

				% Generate subfigure of plot in frequency axis
                fCSfig = figure;
                set(fCSfig, 'Position', [50 50 800 420], 'Visible', 'off');
                if tOn
                    fAxes = copyobj(findobj(CSPanel, 'Tag', 'freqAxes'), fCSfig);
                else
                    fAxes = copyobj(findobj(CSPanel, 'Tag', 'invSpaceAxes'), fCSfig);
                end
                set(fAxes, 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8])
                
				% Captions
                if tOn 
                    title('Power Spectrum of temporal cross section');
                    xlabel('Frequency (Hz)');
                    ylabel('Power');
                    tNames = get(findobj(CSPanel, 'Tag', 'temporalNames'), 'String');
                    legend(tNames(end:-1:1), 'Location', 'NorthEastOutside');
                else
                    title('Power Spectrum of spatial cross section');
                    xlabel('Frequency (Hz)');
                    ylabel('Power');
                    tNames = get(findobj(CSPanel, 'Tag', 'spatialNames'), 'String');
                    legend(tNames(end:-1:1), 'Location', 'NorthEastOutside');
                end
                
				% Copy image
                print(fCSfig, '-dmeta', 'tempFCS.emf');
                close(fCSfig);
                Shapes.AddPicture([pwd '\tempFCS.emf'] ,0,1,121,1066,600,315);
                delete('tempFCS.emf');
                
				% If third and fourth plots are needed
                if tOn && sOn
					
					% Third subheading
                    Sheet2.Range('B91:C91').Select;
                    Excel.Selection.MergeCells = 1;
                    Excel.Selection.Value = 'Space Cross Section:';
                    set(Excel.Selection, 'HorizontalAlignment', 1);
                    set(Excel.Selection, 'VerticalAlignment', -4108);
                    set(Excel.Selection.Font, 'Size', 13);
                    set(Excel.Selection.Font, 'Bold', 1);
                    set(Excel.Selection.Font, 'Name', 'Georgia');
					
					% Generate subfigure of plot in time axis
                    tCSfig = figure;
                    set(tCSfig, 'Position', [50 50 800 420], 'Visible', 'off');
                    tAxes = copyobj(sAxis, tCSfig);
                    set(tAxes, 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8])
					
					% Caption
                    title('Cross section taken over a section of gut');
                    xlabel('Gut Position (mm)');
                    ylabel('Gut Width (mm)');
                    tNames = get(findobj(CSPanel, 'tag', 'spatialNames'), 'String');
                    legend(tNames(end:-1:1), 'Location', 'NorthEastOutside');
					
					% Copy image
                    print(tCSfig, '-dmeta', 'tempTCS.emf');
                    close(tCSfig);
                    Shapes.AddPicture([pwd '\tempTCS.emf'] ,0,1,121,1435,600,315);
                    delete('tempTCS.emf');
					
					% Fourth heading
                    Sheet2.Range('B115:C115').Select;
                    Excel.Selection.MergeCells = 1;
                    Excel.Selection.Value = 'Space Power Spectrum:';
                    set(Excel.Selection, 'HorizontalAlignment', 1);
                    set(Excel.Selection, 'VerticalAlignment', -4108);
                    set(Excel.Selection.Font, 'Size', 13);
                    set(Excel.Selection.Font, 'Bold', 1);
                    set(Excel.Selection.Font, 'Name', 'Georgia');

					% Generate subfigure of plot in frequency axis
                    fCSfig = figure;
                    set(fCSfig, 'Position', [50 50 800 420], 'Visible', 'off');
                    fAxes = copyobj(findobj(CSPanel, 'Tag', 'invSpaceAxes'), fCSfig);
                    set(fAxes, 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8])

					% Caption
                    title('Power Spectrum of spatial cross section');
                    xlabel('Frequency (Hz)');
                    ylabel('Power');
                    tNames = get(findobj(CSPanel, 'Tag', 'spatialNames'), 'String');
                    legend(tNames(end:-1:1), 'Location', 'NorthEastOutside');

					% Copy image
                    print(fCSfig, '-dmeta', 'tempFCS.emf');
                    close(fCSfig);
                    Shapes.AddPicture([pwd '\tempFCS.emf'] ,0,1,121,1804,600,315);
                    delete('tempFCS.emf');
                end
            end
            
        end
        
		% Find contraction annotation panel
        if ~isempty(CWPanel)
			% Title
            Sheet3 = Sheets.Add([], Sheets.Item(Sheets.Count));
            set(Sheet3, 'Name', 'Contraction Annotations');
            Sheet3.Activate;
            
            Sheet3.Columns.ColumnWidth = 22.1;
            Sheet3.Rows.Item(1).RowHeight = 15;
            Sheet3.Rows.Item(2).RowHeight = 36;
            
			% Format tabular data region
            Sheet3.Columns.Item(8).ColumnWidth = 11;
            Sheet3.Columns.Item(9).ColumnWidth = 11;
            Sheet3.Columns.Item(10).ColumnWidth = 11;
            Sheet3.Columns.Item(11).ColumnWidth = 13;
            Sheet3.Columns.Item(12).ColumnWidth = 13;
            Sheet3.Columns.Item(13).ColumnWidth = 13;
            Sheet3.Columns.Item(14).ColumnWidth = 16;
            Sheet3.Columns.Item(15).ColumnWidth = 14;

			% Title
            Sheet3.Range('B2:E2').Select;
            Excel.Selection.MergeCells = 1;
            Excel.Selection.Value = 'Heatmap Annotation Home Panel';
            
			% Formatting
            set(Excel.Selection, 'HorizontalAlignment', 3);
            set(Excel.Selection, 'VerticalAlignment', -4108);
            set(Excel.Selection.Font, 'Size', 16);
            set(Excel.Selection.Font, 'Bold', 1);
            set(Excel.Selection.Font, 'Name', 'Georgia');
            
			% Copy panel image
            Shapes = Sheet3.Shapes;
            print(CWPanel, '-dmeta', 'tempCWPanel.emf');
            Shapes.AddPicture([pwd '\tempCWPanel.emf'] ,0,1,121,52,480,540);
            delete('tempCWPanel.emf')
            
            heatmapImage  = findobj(CWPanel, 'Tag', 'heatmapImage');
            labels = get(heatmapImage, 'UserData');
            L = length(labels);
            
			% If table nonempty, generate headings
            % Added units to headings - Tanya            
            if L > 0
                Sheet3.Range('G2:I2').Select;
                Excel.Selection.MergeCells = 1;
                Excel.Selection.Value = 'Annotation Data';
                set(Excel.Selection, 'HorizontalAlignment', 3);
                set(Excel.Selection, 'VerticalAlignment', -4108);
                set(Excel.Selection.Font, 'Size', 16);
                set(Excel.Selection.Font, 'Bold', 1);
                set(Excel.Selection.Font, 'Name', 'Georgia');
                
                set(get(Sheet3, 'Cells', 3, 7), 'Value', 'Name');
                set(get(Sheet3, 'Cells', 3, 8), 'Value', 'Start Time s');
                set(get(Sheet3, 'Cells', 3, 9), 'Value', 'End Time s');
                set(get(Sheet3, 'Cells', 3, 10), 'Value', 'Duration s');
                set(get(Sheet3, 'Cells', 3, 11), 'Value', ['Leftmost Gut' char(10) 'Position mm']);
                set(get(Sheet3, 'Cells', 3, 12), 'Value', ['Rightmost Gut' char(10) 'Position mm']);
                set(get(Sheet3, 'Cells', 3, 13), 'Value', 'Gut Span mm');
                set(get(Sheet3, 'Cells', 3, 14), 'Value', 'Velocity mm/sec');
                set(get(Sheet3, 'Cells', 3, 15), 'Value', ['Detection' char(10) 'Method']);
            end
            
            headings = get(Sheet3, 'Range', 'G3:O3');
            set(headings.borders, 'LineStyle', 1);
            
			% Fill in each row of the table into Excel
            for i = 1 : L
                line = labels(i).line;
                position = getPosition(line);
                xData = position(:,1);
                yData = position(:,2);
                
				% Formatting borders
                row = get(Sheet3, 'Range', get(Sheet3, 'Cells', 3 + i, 7), get(Sheet3, 'Cells', 3 + i, 15));
                set(get(row.borders, 'Item', 1), 'LineStyle', 1);
                set(get(row.borders, 'Item', 2), 'LineStyle', 1);
                if i == L
                    set(get(row.borders, 'Item', 4), 'LineStyle', 1);
                end
                
                if mod(i, 2) == 0
                    set(row.interior, 'Color', hex2dec('D9D9D9'));
                end
                % Removed the units - Tanya                
                set(get(Sheet3, 'Cells', 3 + i, 7), 'Value', labels(i).name);
                set(get(Sheet3, 'Cells', 3 + i, 8), 'Value', [num2str(min(xData(:)))]);
                set(get(Sheet3, 'Cells', 3 + i, 9), 'Value', [num2str(max(xData(:)))]);
                set(get(Sheet3, 'Cells', 3 + i, 10), 'Value', [num2str(abs(xData(1) - xData(2)))]);
                set(get(Sheet3, 'Cells', 3 + i, 11), 'Value', [num2str(min(yData(:)))]);
                set(get(Sheet3, 'Cells', 3 + i, 12), 'Value', [num2str(max(yData(:)))]);
                set(get(Sheet3, 'Cells', 3 + i, 13), 'Value', [num2str(abs(yData(1) - yData(2)))]);
                set(get(Sheet3, 'Cells', 3 + i, 14), 'Value', [num2str((yData(2)-yData(1))/(xData(2) -xData(1)))]);
                set(get(Sheet3, 'Cells', 3 + i, 15), 'Value', labels(i).method);
            end
        end
        Sheet1.Activate
        set(Excel,'Visible',1);
end

function add_video(vList, filePathName)

    %Obtain the data and file lists
    data_handle = get(vList, 'UserData');
    nameList = get(vList, 'String');

    % Obtain the full file name of the file to be opened and check
    % that it hasn't been unopened
    pathName = filePathName{1};
    fileName = filePathName{2};
    extension = filePathName{3};
    fullName = strcat(pathName, fileName, extension);
    
    opened = 0;
    for entry = 1:length(data_handle)
       if strcmp(data_handle{entry}.fullName, fullName)
           opened = 1;
           break
       end
    end

    % Skip this file if it is opened, otherwise update user data
    if ~opened
        if isempty(data_handle)
            nameList = {fileName};
            data_handle = {};
        else
            nameList = [{fileName}; nameList];
        end
        data_handle = {struct('fullName', fullName, ...
                            'fileName'  , fileName, ...
                            'video'     , VideoReader(fullName), ...
                            'parameters', []      ) ...
                            ,data_handle{:}};
        
        set(vList, 'UserData', data_handle, 'String', nameList)
    end

function add_summary(fList, filePathName)

    %Obtain the data and file lists
    data_handle = get(fList, 'UserData');
    nameList = get(fList, 'String');

    % Obtain the full file name of the file to be opened and check
    % that it hasn't been unopened
    pathName = filePathName{1};
    fileName = filePathName{2};
    extension = filePathName{3};
    fullName = strcat(pathName, fileName, extension);
    
    opened = 0;
    for entry = 1:length(data_handle)
       if strcmp(data_handle{entry}.fullName, fullName)
           opened = 1;
           break
       end
    end

    % Skip this file if it is opened, otherwise update user data
    if ~opened
        if isempty(data_handle)
            nameList = {fileName};
            data_handle = {};
        else
            nameList = [{fileName}; nameList];
        end
        
        data_handle = {struct('fullName', fullName, ...
                            'fileName'  , fileName, ...
                            'parameters', []      ) ...
                            ,data_handle{:}};
        
        set(fList, 'UserData', data_handle, 'String', nameList)
    end
