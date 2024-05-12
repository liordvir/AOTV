
rowSize = 640;
colSize = 512;


for i=1:5
    
    imageFolderPath = '/Users/liordvir/Technion/Courses/Variational Methods/Git/Project/AOTV/Matlab/Images';
    imPath = fullfile(imageFolderPath, 'Banana-'+string(i)+'.jpg');
    imPathEdited = fullfile(imageFolderPath, 'Banana_edit_'+string(i)+'.jpg');
    maskPath = fullfile(imageFolderPath, 'Banana_mask-'+string(i)+'.jpg');
    maskPathEdited = fullfile(imageFolderPath, 'Banana_mask_edit_'+string(i)+'.jpg');
    
    im = imread(imPath);
    im = rgb2gray(im);
    im = imresize(im, [colSize, rowSize]);
    imwrite(im, imPathEdited)
    
    mask = imread(maskPath);
    mask = rgb2gray(mask);
    mask = imresize(mask, [colSize, rowSize]);
    mask(mask < 30) = 0;
    mask(mask >= 30) = 1;
    imwrite(logical(mask), maskPathEdited)
   
    
end
