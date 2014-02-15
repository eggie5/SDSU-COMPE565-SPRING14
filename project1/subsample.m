
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

cr_20_lin=cr;
cr_20_lin(2:2:end-1, 2:2:end-1) = (cr_20_lin(1:2:end-3, 1:2:end-3) + cr_20_lin(3:2:end-1, 3:2:end-1))/2;
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



% 10. Measure MSE between the original and reconstructed images 
% (obtained using linear interpolation only). Comment on the results. (10 points)
% mse= 1/(n*m) sum(sum( f(j,k) - f2(j,k) ))

y1= ycbcr(:,:,1);
cb1=ycbcr(:,:,2);
cr1=ycbcr(:,:,3);

y2=upscaled_lin(:,:,1);
cb2=upscaled_lin(:,:,2);
cr2=upscaled_lin(:,:,3);

dy=y1-y2;
dcb=cb1-cb2;
dcr=cr1-cr2;

msey =  mean(dy(:).^2)
msecb = mean(dcb(:).^2)
msecr = mean(dcr(:).^2)

%convert uint8s to doubles for maths
MSE = mean(mean((double(ycbcr) - double(upscaled_lin)).^2,2),1);
reshape(MSE, [1,3])


% 11. Comment on the compression ratio achieved by subsampling Cb and Cr
% components for 4:2:0 approach. Please note that you do not send the pixels
% which are made zero in the row and columns during subsampling. (5 points)












