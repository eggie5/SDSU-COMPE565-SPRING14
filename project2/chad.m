% CompE 565 Project 2
% 10/24/2013
% Name: Thomas Gerstenberg
% Id: 812950041
% Email: t_gerst6@yahoo.com
% Name: Chad Higgins
% Id: 814680068
% Email: Chiggins91@cox.net


function y = chad
% params\ filepath: The string path of the file to use for this function
%                   i.e. 'C:\Users\Thomas\Pictures\pic.jpg'

clear 
clc

try
%     imfinfo(filepath);
    RGBImage = imread('SunView.jpg');
catch err
    msg = sprintf('%s', 'Invalid filepath! Enter as ''C:\Users\...'' ');
    error(msg);
end

figure(1);
imshow(RGBImage);
% Get size of image
sizeofimg = size(RGBImage);
MAXROWS = sizeofimg(1);
MAXCOLS = sizeofimg(2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Encoder: Convert to YCbCr 4:2:0
YCbCrImage = rgb2ycbcr(RGBImage);
Y__420 = YCbCrImage(:,:,1);
Cb_420 = YCbCrImage(:,:,2);
Cr_420 = YCbCrImage(:,:,3);
Cb_420(:,2:2:end) = [];
Cb_420(2:2:end,:) = [];
Cr_420(:,2:2:end) = [];
Cr_420(2:2:end,:) = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Encoder (Part A): Compute the 8x8 block DCT transform coefficients for the 
% three bands
pDCT = @dct2;
Y_DCT = blkproc(Y__420, [8 8], pDCT);
Y_DCT = fix(Y_DCT);
Cb_DCT = blkproc(Cb_420, [8 8], pDCT);
Cb_DCT = fix(Cb_DCT);
Cr_DCT = blkproc(Cr_420, [8 8], pDCT);
Cr_DCT = fix(Cr_DCT);
figure(2);
imshow(Y_DCT);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Encoder (Part A-1): Display the DCT Coefficient matrix as well as the 
% image of the first two blocks in the fourth row from the top for the 
% luminance component
figure(3);
subplot(1,2,1), subimage(Y_DCT(25:32, 1:8)), title('Row 4 Block 1')
subplot(1,2,2), subimage(Y_DCT(25:32, 9:16)), title('Row 4 Block 2')
r4_blk1 = Y_DCT(25:32, 1:8)
r4_blk2 = Y_DCT(25:32, 9:16)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Encoder (Part B): Quantize the DCT image by using the JPEG luminance and
% crominance quantizer matrix from the lecture notes

y_quant_matrix = [
    16  11  10  16  24  40  51  61;
    12  12  14  19  26  58  60  55;
    14  13  16  24  40  57  69  56;
    14  17  22  29  51  87  89  62;
    18  22  37  56  68 109 103  77;
    24  35  55  64  81 104 113  92;
    49  64  78  87 108 121 120 101;
    72  92  95  98 112 100 103  99
    ];
cr_quant_matrix = [
    17 18 24 47 99 99 99 99;
    18 21 26 66 99 99 99 99;
    24 26 56 99 99 99 99 99;
    47 66 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    ];

quantize_y = @(block_struct) ...
    round(block_struct.data ./ y_quant_matrix);
quantize_cbcr = @(block_struct) ...
    round(block_struct.data ./ cr_quant_matrix);

dequantize_y  = @(block_struct) ...
    round(block_struct.data .* y_quant_matrix);
dequantize_cbcr = @(block_struct) ...
    round(block_struct.data .* cr_quant_matrix);


y_quant = blockproc(Y_DCT, [8 8], quantize_y);
cb_quant = blockproc(Cb_DCT, [8 8], quantize_cbcr);
cr_quant = blockproc(Cr_DCT, [8 8], quantize_cbcr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Encoder (Part B-1): Report the following output for only the first two 
% blocks in the 4th row frim the top of the luminance component:
    % (a): DC DCT Coefficient
    r4_blk1_DC_coefficient = y_quant(25, 1)
    r4_blk2_DC_coefficient = y_quant(25, 9)
    % (b): Zigzag scanned AC DCT coefficients
    r4_blk1_zigzag = zigzag(y_quant(25:32, 1:8))
    r4_blk2_zigzag = zigzag(y_quant(25:32, 9:16))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Decoder (Part C): Compute the inverse quantized images from step b
y_dequant = blockproc(y_quant, [8 8], dequantize_y);
cb_dequant = blockproc(cb_quant, [8 8], dequantize_cbcr);
cr_dequant = blockproc(cr_quant, [8 8], dequantize_cbcr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Decoder (Part D): Reconstruct the image by computing the inverse DCT
% coefficients
pIDCT = @idct2;
y_idct = blkproc(y_dequant, [8 8], pIDCT);
y_idct = fix(y_idct);
cb_idct = blkproc(cb_dequant, [8 8], pIDCT);
cb_idct = fix(cb_idct);
cr_idct = blkproc(cr_dequant, [8 8], pIDCT);
cr_idct = fix(cr_idct);


% Reconstruct from 4:2:0 subsampling using linear interpolation
Y__linear = uint8(y_idct);
Cb_linear = uint8(zeros(MAXROWS, MAXCOLS));
Cr_linear = uint8(zeros(MAXROWS, MAXCOLS));
Cb_linear(1:2:end, 1:2:end) = cb_idct(1:end,1:end);
Cr_linear(1:2:end, 1:2:end) = cr_idct(1:end,1:end);
for row = 2:2:MAXROWS % Fill in gaps so we have full vertical lines of YCbCr
    for col = 1:2:MAXCOLS
        % Obtain the midpoint between the pixel above and below
        if(row ~= MAXROWS)
            Cb_linear(row, col) = Cb_linear(row-1, col)/2 + Cb_linear(row+1, col)/2;
            Cr_linear(row, col) = Cr_linear(row-1, col)/2 + Cr_linear(row+1, col)/2;
        else %special case if at the last pixel in the row
            Cb_linear(row, col) = Cb_linear(row-1, col);
            Cr_linear(row, col) = Cr_linear(row-1, col);
        end
    end
end
% Now do the alternating lines and obtain the midpoint between the left and
% right pixel
for row = 1:MAXROWS
    for col = 2:2:MAXCOLS
        if(col ~= MAXCOLS)
            Cb_linear(row, col) = Cb_linear(row, col-1)/2 + Cb_linear(row, col+1)/2;
            Cr_linear(row, col) = Cr_linear(row, col-1)/2 + Cr_linear(row, col+1)/2;
        else %special case if at the last pixel in the column
            Cb_linear(row, col) = Cb_linear(row, col-1);
            Cr_linear(row, col) = Cr_linear(row, col-1);
        end
    end
end
% Concatenate the three components
YCbCr_linear = cat(3, Y__linear, Cb_linear, Cr_linear);

% Convert to RGB space
RGB_reconstructed = ycbcr2rgb(YCbCr_linear);
figure(4);
imshow(RGB_reconstructed);

% Show the error image for the Y-component
errorImage = abs(Y__420(:,:) - Y__linear(:,:));
figure(5);
imshow(errorImage);

% Compute the PSNR
MSE_Y = mean(errorImage(:).^2);
PSNR_Y = 10 * log10(255^2/MSE_Y)
end




