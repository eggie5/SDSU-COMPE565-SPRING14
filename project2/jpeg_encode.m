RGB=imread('SunView.jpg');
YCBCR=rgb2ycbcr(RGB);
Y=YCBCR(:,:,1);
CB=YCBCR(:,:,2);
CR=YCBCR(:,:,3);


%subsample cb & cr to 4:2:0
% CB(:,2:2:end) = [];
% CB(2:2:end,:) = [];
% CR(:,2:2:end) = [];
% CR(2:2:end,:) = [];

%Because the DCT is designed to work on pixel values ranging from -128 to 127, the original
%block is ?leveled off?
%by subtracting 128 from each entry. 
%Y=double(Y) - 128;

% split Y into 8x8 blocks
dct_proc=@(block_struct) dct2(block_struct.data);

ydct=blockproc(Y, [8 8], dct_proc);
cbdct=blockproc(CB, [8 8], dct_proc);
crdct=blockproc(CR, [8 8], dct_proc);


%normalize values to 0-255 range
mmin=abs(min(ydct(:)))
mmax=abs(max(ydct(:)))
%trans=trans+mmin;
%trans=trans/mmin;



%  first 2 blocks in the 4th row 

block1=ydct(33:40, 1:8)  %first block in row 4
block2=ydct(33:40, 9:16) %second block in row 4



% figure()
% block1 = imresize(block1, 50, 'box');
% iptsetpref('ImshowAxesVisible','on');
% imshow(block1, 'XData', [1 8], 'YData', [1 8]);
% title('block 1')
% xlabel('x axis') % x-axis label
% ylabel('y axis') % y-axis label
% 
% figure()
% block2 = imresize(block2, 50, 'box');
% iptsetpref('ImshowAxesVisible','on');
% imshow(block2, 'XData', [1 8], 'YData', [1 8]);
% title('block 2')
% xlabel('x axis') % x-axis label
% ylabel('y axis') % y-axis label


limits = [mmin mmax];

%figure()
%imshow(ydct)


% Subjective experiments involving the human visual system have resulted in
% the JPEGstandard quantization matrix. With a quality level of 50, this 
% matrix renders both highcompression and excellent decompressed image quality

Q50=[...
16 11 10 16 24 40 51 61
12 12 14 19 26 58 60 55
14 13 16 24 40 57 69 56
14 17 22 29 51 87 80 62
18 22 37 56 68 109 103 77
24 35 55 64 81 104 113 92
49 64 78 87 103 121 120 101
72 92 95 98 112 100 103 99];

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

yquant_proc=@(block_struct) round( block_struct.data./Q50);
cbcrquant_proc=@(block_struct) round( block_struct.data./cr_quant_matrix);

qy=blockproc(ydct, [8 8], yquant_proc);
qcb=blockproc(cbdct, [8 8], cbcrquant_proc);
qcr=blockproc(crdct, [8 8], cbcrquant_proc);


%figure()
%imshow(q)



qblock1=qy(33:40, 1:8);  %first block in row 4
qblock2=qy(33:40, 9:16); %second block in row 4
qb1zig=zigzag(qblock1);
qb2zig=zigzag(qblock2);

fprintf('block 1 DC DCT Coeff: %f\n', qblock1(1));
fprintf('block 1 AC DCT coeff:\n')
display(qb1zig);
fprintf('block 2 DC DCT Coeff: %f\n', qblock1(1));
fprintf('block 2 AC DCT coeff:\n');
display(qb2zig);

%
%decoder

%invese quant
ydq_proc=@(block_struct)  round(block_struct.data.*Q50);
cbcrdq_proc=@(block_struct)  round(block_struct.data.*cr_quant_matrix);
%idct
idctproc=@(block_struct) idct2(block_struct.data);


ydq=blockproc(qy, [8 8], ydq_proc);
cbdq=blockproc(qcb, [8 8], cbcrdq_proc);
crdq=blockproc(qcr, [8 8], cbcrdq_proc);

ychannel=blockproc(ydq, [8 8], idctproc);
cbchannel=blockproc(cbdq, [8 8], idctproc);
crchannel=blockproc(crdq, [8 8], idctproc);



% Concatenate the three components
YCbCr_linear = cat(3, ychannel, cbchannel, uint8(crchannel));

% Convert to RGB space
RGB_reconstructed = ycbcr2rgb(YCbCr_linear);
figure(4);
imshow(RGB_reconstructed);

