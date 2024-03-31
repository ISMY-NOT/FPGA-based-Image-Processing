% cleaning up stored variables
close all;
clear;
clc;

% read RGB888 images
rgb888_image = imread('../other_temp/p1_512_888.bmp');

% extract RGB components
R = double(rgb888_image(:,:,1));
G = double(rgb888_image(:,:,2));
B = double(rgb888_image(:,:,3));

% the RGB components are shifted and truncated to obtain pixels in RGB565 format
R_5 = floor(R * 31 / 255); % Take the high 5 bits of R
G_6 = floor(G * 63 / 255); % Take the high 6 bits of G
B_5 = floor(B * 31 / 255); % Take the high 5 bits of B

% merge RGB components to get RGB565 image
rgb565_image = uint16(bitshift(R_5, 11) + bitshift(G_6, 5) + B_5);

rgb565_image1 = reshape(rgb565_image',262144,1);

% write the data of matrix B to a .coe file, ROM storage format
fid = fopen('../other_temp/p1_512_565.coe','w+');
fprintf(fid,'MEMORY_INITIALIZATION_RADIX=16;\nMEMORY_INITIALIZATION_VECTOR=\n');
for i = 1:(length(rgb565_image1)-1)
	fprintf(fid,'%x,\n',rgb565_image1(i));
end
fprintf(fid,'%x;',rgb565_image1(length(rgb565_image1)));
fclose(fid);
