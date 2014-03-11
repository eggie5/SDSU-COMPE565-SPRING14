RGB=imread('SunView.jpg');
YCBCR=rgb2ycbcr(RGB);
Y=YCBCR(:,:,1);
CB=YCBCR(:,:,2);
CR=YCBCR(:,:,3);


%subsample cb & cr to 4:2:0

%Because the DCT is designed to work on pixel values ranging from -128 to 127, the original
%block is ?leveled off?
%by subtracting 128 from each entry. 
%Y=double(Y) - 128;

% split Y into 8x8 blocks
proc=@(block_struct) dct2(block_struct.data);

trans=blockproc(Y, [8 8], proc);

%normalize values to 0-255 range
mmin=abs(min(trans(:)))
mmax=abs(max(trans(:)))
%trans=trans+mmin;
%trans=trans/mmin;



%  first 2 blocks in the 4th row 

block1=trans(33:40, 1:8)  %first block in row 4
block2=trans(33:40, 9:16) %second block in row 4



figure()
block1 = imresize(block1, 50, 'box');
iptsetpref('ImshowAxesVisible','on');
imshow(block1, 'XData', [1 8], 'YData', [1 8]);
title('block 1')
xlabel('x axis') % x-axis label
ylabel('y axis') % y-axis label

figure()
block2 = imresize(block2, 50, 'box');
iptsetpref('ImshowAxesVisible','on');
imshow(block2, 'XData', [1 8], 'YData', [1 8]);
title('block 2')
xlabel('x axis') % x-axis label
ylabel('y axis') % y-axis label


limits = [mmin mmax];

figure()
imshow(trans)


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

quantizepower=@(block_struct) round( block_struct.data./Q50); %devide by quantization matrix%round off the quantized matrix
q=blockproc(trans, [8 8], quantizepower);

figure()
imshow(q)

zz=@(block_struct) zigzag(block_struct.data);



qblock1=q(33:40, 1:8);  %first block in row 4
qblock2=q(33:40, 9:16); %second block in row 4
qb1zig=zigzag(qblock1);
qb2zig=zigzag(qblock2);

fprintf('block 1 DC DCT Coeff: %f\n', qblock1(1));
fprintf('block 2 DC DCT Coeff: %f\n', qblock1(1));



