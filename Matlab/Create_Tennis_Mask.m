
rowSize = 640;
colSize = 512;


for i=10:10
    
    imageFolderPath = '/Users/liordvir/Technion/Courses/Variational Methods/Git/Project/AOTV/tennis_ball_frames';
    imPath = fullfile(imageFolderPath, 'current_'+string(i)+'.png');
    imPathEdited = fullfile(imageFolderPath, 'Tennis_edit_'+string(i)+'.png');
    maskPath = fullfile(imageFolderPath, 'Tennis_mask-'+string(i)+'.jpg');
    maskPathEdited = fullfile(imageFolderPath, 'Tennis_mask_edit_'+string(i)+'.png');
    
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
