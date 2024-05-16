%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lior and Neta's Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all
clear
addpath ./code
addpath ./data
addpath ./admm
addpath ./Images
addpath ../tennis_ball_frames/
addpath ../tennis_ball_frames/Edited
addpath ../tennis_ball_frames/Edited/Masks

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simple Images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%source: moving image
%target: fixed image

levels     = [4,2,1];
maxIter    = 2000;
tolerance  = 1e-2;
difference = 2;
talyor     = 5;
lambda     = 0.1;
mode       = 'sotv';
padNum     = 8;

numImages = 5;
imRef = double(imread('simple_image_1.tiff'));
imRef = rescale_intensity(imRef(:,:,1), [1, 99]);
imRef = padarray(imRef,  [padNum,padNum], 0);

maskRefCells = cell(numImages,1);
maskCurCells = cell(numImages,1);
iouRefCells = cell(numImages,1);

maskRefCells{1} = double(imread('simple_mask_1.tiff'));
maskRefCells{1} = padarray(maskRefCells{1},  [padNum,padNum], 0);
maskCurCells{1} = maskRefCells{1};
iouRefCells{1} = calcIOU(maskRefCells{1}, maskCurCells{1}); % Should be 1

for i=2:numImages
    % Load current image
    imCur = double(imread('simple_image_'+string(i)+'.tiff'));
    imCur = rescale_intensity(imCur(:,:,1), [1, 99]);
    imCur = padarray(imCur,  [padNum,padNum], 0);

    % Load current image mask
    maskCur = double(imread('simple_mask_'+string(i)+'.tiff'));
    maskCur = padarray(maskCur,  [padNum,padNum], 0);

    % Calculate displacement field
    [u0, v0] = pyramid_flow(imRef, imCur, levels, talyor, maxIter, lambda, tolerance, difference, mode);

    % warp mask using displacement field and calculate IOU between masks
    maskRefTemp = imwarp(maskRefCells{i-1}, cat(3, u0, v0),'Interp', 'linear'); 
    maskRefTemp(maskRefTemp <= 0) = 0;
    maskRefCells{i} = maskRefTemp;
    maskCurCells{i} = maskCur;
    iouRefCells{i} = calcIOU(maskRefCells{i}, maskCurCells{i});

    imRef = imCur;
end

figure
for i=1:numImages
    subplot(1,5,i)
    imshowpair(maskRefCells{i}, maskCurCells{i})
    title('IOU = ' + string(iouRefCells{i}));
end


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Banana Images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%source: moving image
%target: fixed image

levels     = [16,8,4,2,1];
maxIter    = 2000;
tolerance  = 1e-2;
difference = 2;
talyor     = 10;
lambda     = 1000;
mode       = 'sotv';
padNum     = 8;

numImages = 5;

% Init cell array to store data for display and comparisons
maskRefCells = cell(numImages,1);
maskCurCells = cell(numImages,1);
maskCurWarpCells = cell(numImages,1);
iouRefCells = cell(numImages,1);
iouCells = cell(numImages,1);

imRef = double(imread('Banana_edit_1.jpg'));
imRef = padarray(imRef,  [padNum,padNum], 0);

% Load reference's mask
maskTemp = double(imread('Banana_mask_edit_1.jpg'));
maskTemp(maskTemp > 0) = 1;
maskTemp = padarray(maskTemp,  [padNum,padNum], 0);

% Assign first values to cell arrays
maskRefCells{1} = maskTemp; 
maskCurCells{1} = maskRefCells{1};
maskCurWarpCells{1} = maskRefCells{1};
iouRefCells{1} = calcIOU(maskRefCells{1}, maskCurCells{1}); % Should be 1
iouCells{1} = calcIOU(maskRefCells{1}, maskCurCells{1}); % Should be 1

% Init structure element for morphological open operation
se = strel('disk',30);

for i=2:numImages

    % Load current image
    imCur = double(imread('Banana_edit_'+string(i)+'.jpg'));
    imCur = padarray(imCur,  [padNum,padNum], 0);

    % Load current image mask
    maskCur = double(imread('Banana_mask_edit_'+string(i)+'.jpg'));
    maskCur(maskCur > 0) = 1;
    maskCur = padarray(maskCur,  [padNum,padNum], 0);

    % Calculate displacement field
    [u0, v0] = pyramid_flow(imRef, imCur, levels, talyor, maxIter, lambda, tolerance, difference, mode);

    % warp mask using displacement field and calculate IOU between masks
    % maskRef is the first mask that gets transformed each step
    maskRefTemp = imwarp(maskRefCells{i-1}, cat(3, u0, v0),'Interp', 'linear'); 
    maskRefTemp(maskRefTemp <= 0) = 0;

    % Perform morphological open operation to remove small flow anomalies 
    maskRefTemp = imopen(maskRefTemp,se);

    % maskCur is the ground truth mask (We warp this as well for comparison purposes) 
    maskCurWarp = imwarp(maskCurCells{i-1}, cat(3, u0, v0),'Interp', 'linear'); 
    maskCurWarp(maskCurWarp <= 0) = 0;
    maskCurWarp = imopen(maskCurWarp,se);

    % Insert to cell arrays for display purpose
    maskRefCells{i} = maskRefTemp;
    maskCurCells{i} = maskCur;
    maskCurWarpCells{i} = maskCurWarp;

    % Calculate IOUs
    iouRefCells{i} = calcIOU(maskRefCells{i}, maskCurCells{i});
    iouCells{i} = calcIOU(maskCurWarp, maskCur);

    % Prepare for next time step
    imRef = imCur;
end

% Display IOU of the reference mask transformed through the entire image
% sequence (Transform of the first mask only)
figure
for i=1:numImages
    subplot(1,5,i)
    imshowpair(maskRefCells{i}, maskCurCells{i})
    title('IOU = ' + string(iouRefCells{i}), 'FontSize',20);
end

% Display IOU of the transformed mask between every two consecutive images
% (Transform of the ground truth mask each step)
figure
for i=1:numImages
    subplot(1,5,i)
    imshowpair(maskCurWarpCells{i}, maskCurCells{i})
    title('IOU = ' + string(iouCells{i}), 'FontSize',20);
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tennis Images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%source: moving image
%target: fixed image

levels     = [16,8,4,2,1];
maxIter    = 4000;
tolerance  = 1e-2;
difference = 2;
talyor     = 10;
lambda     = 10;
mode       = 'sotv';
padNum     = 8;

numImages = 10;

% Init cell array to store data for display and comparisons
maskRefCells = cell(numImages,1);
maskCurCells = cell(numImages,1);
maskCurWarpCells = cell(numImages,1);
iouRefCells = cell(numImages,1);
iouCells = cell(numImages,1);

% Load first image (the reference)
imRef = double(imread('Tennis_edit_1.png'));
imRef = padarray(imRef,  [padNum,padNum], 0);

% Load reference's mask
maskTemp = double(imread('Tennis_mask_1.png'));
maskTemp(maskTemp > 0) = 1;
maskTemp = padarray(maskTemp,  [padNum,padNum], 0);

% Assign fisrt values to cell arrays
maskRefCells{1} = maskTemp; 
maskCurCells{1} = maskRefCells{1};
maskCurWarpCells{1} = maskRefCells{1};
iouRefCells{1} = calcIOU(maskRefCells{1}, maskCurCells{1}); % Should be 1
iouCells{1} = calcIOU(maskRefCells{1}, maskCurCells{1}); % Should be 1

% Init structure element for morphological open operation
se = strel('disk',30);

for i=2:numImages

    % Load current image
    imCur = double(imread('Tennis_edit_'+string(i)+'.png'));
    imCur = padarray(imCur,  [padNum,padNum], 0);

    % Load current image mask
    maskCur = double(imread('Tennis_mask_'+string(i)+'.png'));
    maskCur(maskCur > 0) = 1;
    maskCur = padarray(maskCur,  [padNum,padNum], 0);

    % Calculate displacement field
    [u0, v0] = pyramid_flow(imRef, imCur, levels, talyor, maxIter, lambda, tolerance, difference, mode);

    % warp mask using displacement field and calculate IOU between masks
    % maskRef is the first mask that gets transformed each step
    maskRefTemp = imwarp(maskRefCells{i-1}, cat(3, u0, v0),'Interp', 'linear'); 
    maskRefTemp(maskRefTemp <= 0) = 0;

    % Perform morphological open operation to remove small flow anomalies 
    maskRefTemp = imopen(maskRefTemp,se);

    % maskCur is the ground truth mask (We warp this as well for comparison purposes) 
    maskCurWarp = imwarp(maskCurCells{i-1}, cat(3, u0, v0),'Interp', 'linear'); 
    maskCurWarp(maskCurWarp <= 0) = 0;
    maskCurWarp = imopen(maskCurWarp,se);

    % Insert to cell arrays for display purpose
    maskRefCells{i} = maskRefTemp;
    maskCurCells{i} = maskCur;
    maskCurWarpCells{i} = maskCurWarp;

    % Calculate IOUs
    iouRefCells{i} = calcIOU(maskRefCells{i}, maskCurCells{i});
    iouCells{i} = calcIOU(maskCurWarp, maskCur);

    % Prepare for next time step
    imRef = imCur;
end

% Display IOU of the reference mask transformed through the entire image
% sequence (Transform of the first mask only)
figure
for i=1:numImages
    subplot(2,5,i)
    imshowpair(maskRefCells{i}, maskCurCells{i})
    title('IOU = ' + string(iouRefCells{i}), 'FontSize',20);
end

% Display IOU of the transformed mask between every two consecutive images
% (Transform of the ground truth mask each step)
figure
for i=1:numImages
    subplot(2,5,i)
    imshowpair(maskCurWarpCells{i}, maskCurCells{i})
    title('IOU = ' + string(iouCells{i}), 'FontSize',20);
end
%%
% Create videos of GT and algorithm masks applied to original video 
imagePath = 'Edited';
vidNameGT = 'GT.mp4';
vidNameAlgo = 'Algo.mp4';
createVidFromMask(imagePath, maskCurCells, vidNameGT);
createVidFromMask(imagePath, maskRefCells, vidNameAlgo);

%%
% Calculated Intersection Over Union between two binary masks
function iou = calcIOU(mask_1, mask_2)
    intersection = mask_1 & mask_2;
    union = mask_1 | mask_2;
    iou = sum(intersection, "all") / sum(union, "all");
end

function createVidFromMask(imagePath, maskArray, vidName)
    % Define parameters
    frameRate = 5; % Frames per second
    
    % Create VideoWriter object
    v = VideoWriter(fullfile(imagePath, vidName), 'MPEG-4');
    v.FrameRate = frameRate;
    open(v);
    
    % Load images
    imageFiles = dir(fullfile(imagePath, '*.png')); 
    imageNames = {imageFiles.name};
    imageNumbers = cellfun(@(x) sscanf(x, 'Tennis_edit_%d.png'), imageNames);
    [~, sortedIndices] = sort(imageNumbers);
    numImages = length(imageFiles);
    
    % Loop through images and write to video
    for i = 1:numImages

        % Read image
        imageName = imageNames{sortedIndices(i)};
        image = imread(imageName);

        % Load mask and apply it to image to extract object only
        mask = uint8(maskArray{i});
        mask(mask > 0) = 1;
        mask = mask(9:end-8,9:end-8);
        image = image .* mask;
        
        % Write frame to video
        writeVideo(v, image);
    end
    
    % Close video
    close(v);

end

% Takes a cell array of binary masks and outputs a cell array of bounding boxes  
function bbArray = getBB(maskArray)
    numMasks = length(maskArray); 
    bbArray = cell(numMasks,1);
    for i=1:numMasks
        % Load mask
        mask = maskArray{i};
        % Sum over axi
        axisSumX = sum(mask,1);
        axisSumY = sum(mask,2);
        % Find first and last indices of none-zero values for each axis
        xStart = find(axisSumX ~= 0, 1);
        xEnd = find(axisSumX ~= 0, 1, 'last');
        yStart = find(axisSumY ~= 0, 1);
        yEnd = find(axisSumY ~= 0, 1, 'last');
        % Create Bounding Box of top-left BB point, BB width and BB height
        bbArray{i} = [xStart, yStart, xEnd-xStart+1, yEnd-yStart+1];
    end
end