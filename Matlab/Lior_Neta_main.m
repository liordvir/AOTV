%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lior and Neta's Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all
clear
addpath ./code
addpath ./data
addpath ./admm
addpath ./Images

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
iouCells = cell(numImages,1);

maskRefCells{1} = double(imread('simple_mask_1.tiff'));
maskRefCells{1} = padarray(maskRefCells{1},  [padNum,padNum], 0);
maskCurCells{1} = maskRefCells{1};
iouCells{1} = calcIOU(maskRefCells{1}, maskCurCells{1}); % Should be 1

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
    iouCells{i} = calcIOU(maskRefCells{i}, maskCurCells{i});

    imRef = imCur;
end

figure
for i=1:numImages
    subplot(1,5,i)
    imshowpair(maskRefCells{i}, maskCurCells{i})
    title('IOU = ' + string(iouCells{i}));
end


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Banana Images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%source: moving image
%target: fixed image

levels     = [4,2,1];
maxIter    = 2000;
tolerance  = 1e-2;
difference = 2;
talyor     = 5;
lambda     = 3;
mode       = 'sotv';
padNum     = 8;

numImages = 2;
imRef = double(imread('Banana_edit_3.jpg'));
imRef = rescale_intensity(imRef(:,:,1), [1, 99]);
imRef = padarray(imRef,  [padNum,padNum], 0);

maskRefCells = cell(numImages,1);
maskCurCells = cell(numImages,1);
iouCells = cell(numImages,1);

maskRefCells{1} = double(imread('Banana_mask_edit_3.jpg'));
maskRefCells{1} = padarray(maskRefCells{1},  [padNum,padNum], 0);
maskCurCells{1} = maskRefCells{1};
iouCells{1} = calcIOU(maskRefCells{1}, maskCurCells{1}); % Should be 1

for i=2:numImages
    % Load current image
    imCur = double(imread('Banana_edit_'+string(i+2)+'.jpg'));
    imCur = rescale_intensity(imCur(:,:,1), [1, 99]);
    imCur = padarray(imCur,  [padNum,padNum], 0);

    % Load current image mask
    maskCur = double(imread('Banana_mask_edit_'+string(i+2)+'.jpg'));
    maskCur = padarray(maskCur,  [padNum,padNum], 0);

    % Calculate displacement field
    [u0, v0] = pyramid_flow(imRef, imCur, levels, talyor, maxIter, lambda, tolerance, difference, mode);

    % warp mask using displacement field and calculate IOU between masks
    maskRefTemp = imwarp(maskRefCells{i-1}, cat(3, u0, v0),'Interp', 'linear'); 
    maskRefTemp(maskRefTemp <= 0) = 0;
    maskRefCells{i} = maskRefTemp;
    maskCurCells{i} = maskCur;
    iouCells{i} = calcIOU(maskRefCells{i}, maskCurCells{i});

    imRef = imCur;
end

figure
for i=1:numImages
    subplot(1,5,i)
    imshowpair(maskRefCells{i}, maskCurCells{i})
    title('IOU = ' + string(iouCells{i}));
end

%%
function iou = calcIOU(mask_1, mask_2)
    intersection = mask_1 & mask_2;
    union = mask_1 | mask_2;
    iou = sum(intersection, "all") / sum(union, "all");
end