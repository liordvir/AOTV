
parabolic = @ (row, col, centerRow, centerCol, radius) radius^2 - ((row - centerRow).^2 + (col - centerCol).^2); 

rowSize = 640;
colSize = 512;
radius = 100;
[X, Y] = meshgrid(1:rowSize, 1:colSize);

centerList = [
    [300,300];
    [310,320];
    [320,340];
    [330,360];
    [340,380]];

for i=1:length(centerList)
    centerRow = centerList(i,1);
    centerCol = centerList(i,2);
    
    imageFolderPath = '/Users/liordvir/Technion/Courses/Variational Methods/Git/Project/AOTV/Matlab/Images';
    imPath = fullfile(imageFolderPath, 'simple_image_'+string(i)+'.tiff');
    maskPath = fullfile(imageFolderPath, 'simple_mask_'+string(i)+'.tiff');
    
    
    im = parabolic(X, Y, centerRow, centerCol, radius);
    im(im <= 0) = 0;
    im = uint8(rescale(im)*255);
    
    mask = zeros(colSize,rowSize);
    mask(im > 0) = 1;
    
    imwrite(im, imPath)
    imwrite(logical(mask), maskPath)
end
