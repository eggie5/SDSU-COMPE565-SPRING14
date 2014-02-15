
rgb=imread('SunView.jpg');
[height,width,depth]=size(rgb)

ycbcr=rgb2ycbcr(rgb);

y=ycbcr(:,:,1); %luminance part of the ycbcr image
cb=ycbcr(:,:,2);
cr=ycbcr(:,:,3);

%5. Subsample Cb and Cr bands using 4:2:0 and display both bands. (10 points)

%4:2:2 subsample cb w/o replacement, reduces x pixels by half
cb_22 = cb(:, 1:2:end);
cr_22 = cr(:, 1:2:end);

%4:2:0 subsample cb w/o replacement, reduces x pixes by half
cb_20=cb(1:2:end, 1:2:end);
cr_20=cr(1:2:end, 1:2:end);

figure(1);
subplot(1,2,1);
imshow(cb_20);
title('4:2:0 cb band');

subplot(1,2,2);
imshow(cr_20);
title('4:2:0 cr band');



%6. Upsample and display the Cb and Cr bands using: (15 points)
%6.1. Linear interpolation
figure(2);
subplot(2,2,1);
imshow(rgb);
title('orig');


cb_20_lin = cb;
%pixel n = (n-1 + n+1)/2
cb_20_lin(2:2:end-1, 2:2:end-1) = (cb_20_lin(1:2:end-3, 1:2:end-3) + cb_20_lin(3:2:end-1, 3:2:end-1))/2;
size(cb_20_lin)

cr_20_lin=cr;
cr_20_lin(2:2:end-1, 2:2:end-1) = (cr_20_lin(1:2:end-3, 1:2:end-3) + cr_20_lin(3:2:end-1, 3:2:end-1))/2;
size(cr_20_lin)
upscaled_lin=cat(3, y, cb_20_lin, cr_20_lin);


subplot(2,2,2);
imshow(rgb);
title('linear interp');
subplot(2,2,3);
imshow(ycbcr2rgb(upscaled_lin));
title('pixel replcement');



%6.2. Simple row or column replication.
%subsample w/ row/column replacement
%1D Zero-order (Replication)
cb_20_rep = cb;
cb_20_rep(2:2:end, 2:2:end) = cb_20_rep(1:2:end, 1:2:end);

cr_20_rep=cr;
cr_20_rep(2:2:end, 2:2:end) = cr_20_rep(1:2:end, 1:2:end);

upscaled=cat(3, y, cb_20_rep, cr_20_rep);




subplot(2,2,3);
imshow(ycbcr2rgb(upscaled));
title('pixel replcement');







