% read the original image
originalImage = imread('../other_temp/p1.jpg'); 
% resize to 512x512
resizedImage = imresize(originalImage, [512, 512]);

% save as BMP
imwrite(resizedImage, '../other_temp/p1_512_888.bmp');
