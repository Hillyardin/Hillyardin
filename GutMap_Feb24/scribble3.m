%#################################
% GutMap 2014-2024
%#################################
function scribble3(saveData, savename, rList, edgesmooth)
% Performs edge detection on every frame of a video

% Reset completion dialog
set(findobj(findall(0, 'Name', 'waitDialog'), 'Tag', 'fileCompletion'), 'String', '0%');
drawnow();

% obtain video, region and marker
video = saveData.video;
crop  = saveData.region;

% Obtain parameters for video processing
k = saveData.contrast;
b = saveData.brightness;
d = saveData.dist;

% Obtain dimensions
N = crop(2)-crop(1) + 1;
M = crop(4)-crop(3) + 1;
nullN = zeros(1,N);

numFrames = video.numberOfFrames;

% Determine precision of stored values
[~, ~, ext] = fileparts(savename);
if strcmp(ext, '.su3')
    pixelsize = 'double';
elseif strcmp(ext, '.gmp')
    pixelsize = 'double';
else
    rString = get(rList, 'String');
    set(rList, 'String', [rString(:); {'An error occurred: The save location does not have an appropriate format'}]);
    drawnow();
    return
end

fHandle = fopen(savename, 'w');

% Write metadata
fprintf(fHandle, '%d\n', numFrames);
fprintf(fHandle, '%d\n', N);
fprintf(fHandle, '%f\n', d);
fprintf(fHandle, '%f\n', (1e6)/video.FrameRate);
fprintf(fHandle, '%f\n', d);  

% Fill buffer
buffer = read(video, [1, min(50, numFrames)]);

% Iterate for all  frames
for i = 1:1:numFrames
        
	% Update completion bar
    if mod(i, 100) == 0
        set(findobj(findall(0, 'Name', 'waitDialog'), 'Tag', 'fileCompletion'), 'String', [sprintf('%d', round(100*i/numFrames)) '%']);
        drawnow();
    end
    
    % Obtain current frame
    location = mod(i, 50);
    if location == 0
        location = 50;
    elseif location == 1
        buffer = read(video, [i, min(i + 49, numFrames)]);
    end
    
    nFrame = buffer(crop(3):crop(4), crop(1):crop(2),:, location);
    if ndims(nFrame) == 3
        nFrame = rgb2gray(nFrame);
    end
    
    if b > 128
        nFrame = nFrame + (b - 128);
    elseif b < 128
        nFrame = nFrame - (128 - b);
    end
    nFrame = 128 + k * (nFrame - 128) - k * (128 - nFrame);

    [edges,topx,topy,botx,boty] = edge_contours(nFrame,edgesmooth);
            
    for j = 1:1:N
        fwrite(fHandle, abs(topy(j) - boty(j)), pixelsize);            
    end;

end
fprintf(fHandle, '%d\n', crop(1));  
fprintf(fHandle, '%d\n', crop(3));  
fprintf(fHandle, '%d\n', N-1);  
fprintf(fHandle, '%d\n', M-1);  
fprintf(fHandle, '%s\n', video.Name);

fclose(fHandle);
rString = get(rList, 'String');
set(rList, 'String', [rString(:); {'Successfully analysed'}]);
drawnow();