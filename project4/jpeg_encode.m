

function [Q_Y Q_Cb Q_Cr] = jpeg_encode(I)

I_YCbCr = I;

%Subsample Cb and Cr bands using 4:2:0 and displaythem

I_Y = I_YCbCr(:,:,1);
I_Cb = I_YCbCr(:,:,2);
I_Cr = I_YCbCr(:,:,3);
I_Cb_SS = I_Cb(1:2:size(I_Cb, 1), 1:2:size(I_Cb, 2));
I_Cr_SS = I_Cr(1:2:size(I_Cr, 1), 1:2:size(I_Cr, 2));


%Compute the 8x8 block DCT transform 
pDCT = @dct2;
Y_DCT = blkproc (I_Y, [8 8], pDCT);
Y_DCT = fix(Y_DCT);

Cb_DCT = blkproc (I_Cb_SS, [8 8], pDCT);
Cb_DCT = fix(Cb_DCT);

Cr_DCT = blkproc (I_Cr_SS, [8 8], pDCT);
Cr_DCT = fix(Cr_DCT);



%Quantize the DCT image 


%------- JPEG Luminance quantizer matrix --------%

l_q = [16 11 10 16 24 40 51 61;
	  12 12 14 19 26 58 60 55;
	  14 13 16 24 40 57 69 56;
	  14 17 22 29 51 87 89 62;
	  18 22 37 56 68 109 103 77;
	  24 35 55 64 81 104 113 92;
	  49 64 78 87 108 121 120 101;
	  72 92 95 98 112 100 103 99];

%--------JPEG Chrominance quantizer matrix--------%

c_q = [17 18 24 47 99 99 99 99;
	  18 21 26 66 99 99 99 99;
	  24 26 56 99 99 99 99 99;
	  47 66 99 99 99 99 99 99;
	  99 99 99 99 99 99 99 99;           
	  99 99 99 99 99 99 99 99;           
	  99 99 99 99 99 99 99 99;           
	  99 99 99 99 99 99 99 99];

%quantizing Y component 
yQuant = @(Y_DCT) round(Y_DCT./(l_q));
Q_Y = blkproc(Y_DCT, [8 8], yQuant);

%quantizing  Chrominance components 
cbQ = @(Cb_DCT) round(Cb_DCT./(c_q));
Q_Cb = blkproc(Cb_DCT, [8 8], cbQ); 
crQ = @(Cr_DCT) round(Cr_DCT./(c_q));
Q_Cr = blkproc(Cr_DCT, [8 8], crQ); 


