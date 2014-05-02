

function I_YCbCr_US_LI = jpeg_decode(Q_Y, Q_Cb, Q_Cr)

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
  

% Compute inverse quantization 


%Y component 
yInvQuant = @(Q_Y) round(Q_Y.*(l_q));
y_invQuant = blkproc(Q_Y, [8 8], yInvQuant);

% Cb component 
cbInvQuant = @(Q_Cb) round(Q_Cb.*(c_q));
cb_invQuant = blkproc(Q_Cb, [8 8], cbInvQuant);

% Cr component
crInvQuant = @(Q_Cr) round(Q_Cr.*(c_q));
cr_invQuant=blkproc(Q_Cr, [8 8], crInvQuant);


% Reconstruct the image


y_invdct1=blkproc(y_invQuant, [8 8], @idct2);   
y_invdct=uint8(fix(y_invdct1));

cb_invdct1=blkproc(cb_invQuant, [8 8], @idct2); 
cb_invdct=uint8(fix(cb_invdct1));

cr_invdct1=blkproc(cr_invQuant, [8 8], @idct2); 
cr_invdct=uint8(fix(cr_invdct1));

% Upsample the chroma 
I_Cb_US = upsample(cb_invdct);
I_Cr_US = upsample(cr_invdct);

%Convert to RGB
I_YCbCr_US_LI = uint8(zeros(144, 176, 3));
I_YCbCr_US_LI(:,:,1) =  y_invdct;
I_YCbCr_US_LI(:,:,2) =  uint8(I_Cb_US);
I_YCbCr_US_LI(:,:,3) =  uint8(I_Cr_US);

