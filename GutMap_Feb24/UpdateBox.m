%#################################
% GutMap 2014-2024
%#################################

function[handles] = UpdateBox(handles)

axesHandle = get(findall(handles.output, 'Tag', 'previewImage'), 'Parent');


pVec(3) = str2num(get(handles.edit_BoxWidth,'String'));
pVec(4) = str2num(get(handles.edit_BoxHeight,'String'));
pVec(1) = str2num(get(handles.edit_BoxLeft,'String'));
pVec(2) = str2num(get(handles.edit_BoxTop,'String'));

	
% Obtains current position, and bounds within the axes
xlims   = get(axesHandle, 'XLim');
ylims   = get(axesHandle, 'YLim');

if pVec(1) < xlims(1)
    pVec(1) = xlims(1);
elseif pVec(1) > xlims(2)-2
    pVec(1) = xlims(2)-2;
end

if pVec(2) < ylims(1)
    pVec(2) = ylims(1);
elseif pVec(2) > ylims(2)-2
    pVec(2) = ylims(2)-2;
end

pRight = pVec(1) + pVec(3);
pBottom = pVec(2) + pVec(4);
if pRight < xlims(1)
    pRight = xlims(1)+1;
elseif pRight > xlims(2)-1
    pRight = xlims(2)-1;
end

if pBottom < ylims(1)
    pBottom = ylims(1)+1;
elseif pBottom > ylims(2)-1
    pBottom = ylims(2)-1;
end

pVec(3) = pRight - pVec(1);
pVec(4) = pBottom - pVec(2);

pVec = round(pVec);

% Updates rectangle position and marker position
set(findobj(handles.output, 'Tag', 'edit_BoxWidth'), 'String',num2str(pVec(3)));
set(findobj(handles.output, 'Tag', 'edit_BoxHeight'), 'String',num2str(pVec(4)));
set(findobj(handles.output, 'Tag', 'edit_BoxLeft'), 'String',num2str(pVec(1)));
set(findobj(handles.output, 'Tag', 'edit_BoxTop'), 'String',num2str(pVec(2)));

delete(findall(handles.output, 'Tag', 'regionOfInterest'));

rectHandle = rectangle('Position', pVec, 'LineStyle', '-', 'LineWidth', 1.5,...
                       'EdgeColor','y', 'Tag', 'regionOfInterest');

video_callback('Preview edges', handles.output);
