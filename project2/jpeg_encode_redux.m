 clc;
I = imread('0.tif');
I = im2double(I);
T= dctmtx(8);
B = blkproc(I,[8 8],'P1*x*P2',T,T');
%fun=@dct2;
%B = blkproc(A,[8 8],fun);
q= [16 11 10 16 24 40 51 61;
    12 12 14 19 26 58 60 55;
    14 13 16 24 40 57 69 56;
    14 17 22 29 51 87 80 62;
    18 22 37 56 68 109 103 77;
    24 35 55 64 81 104 113 92;
    49 64 78 87 103 121 120 101;
    72 92 95 98 112 100 103 99]/255;
B2= blkproc(B,[8 8],'round(x./P1).*P1',q);
imshow(I), figure, imshow(B), figure, imshow(B2);

zz=@(block_struct) zigzag(block_struct.data);

B3=blockproc(B2, [8 8], zz);