f=textread('../other_temp/p1_512_edge.txt','%s');
f1 = hex2dec(f);
f2 = reshape(f1,512,512);
f3 = f2';
imshow(uint8(f3)),title('gray');
imwrite(uint8(f3),'../other_temp/p1_512_edge.bmp');