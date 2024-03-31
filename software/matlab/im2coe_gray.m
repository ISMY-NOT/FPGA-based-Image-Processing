% cleaning up stored variables
close all;
clear;
clc;

% read the image and store it in matrix B
B = imread('../other_temp/p1_512_gray.bmp'); 
B1 = reshape(B',262144,1);

% write the data of matrix B to a .coe file, ROM storage format
fid = fopen('../other_temp/p1_512_gray.coe','w+');
fprintf(fid,'MEMORY_INITIALIZATION_RADIX=16;\nMEMORY_INITIALIZATION_VECTOR=\n');
for i = 1:(length(B1)-1)
	fprintf(fid,'%x,\n',B1(i));
end
fprintf(fid,'%x;',B1(length(B1)));
fclose(fid);