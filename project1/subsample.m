
rgb=imread('SunView.jpg');
[height,width,depth]=size(rgb);

ycbcr=rgb2ycbcr(rgb);

y= ycbcr(:,:,1); %luminance part of the ycbcr image
cb=ycbcr(:,:,2);
cr=ycbcr(:,:,3);

%5. Subsample Cb and Cr bands using 4:2:0 and display both bands. (10 points)

%4:2:2 subsample cb w/o replacement, reduces x pixels by half
cb_22 = cb(:, 1:2:end);
cr_22 = cr(:, 1:2:end);

%4:2:0 subsample cb w/o replacement, reduces x & y pixels by half
cb_20=cb(1:2:end, 1:2:end);
cr_20=cr(1:2:end, 1:2:end);

figure(3);
subplot(1,2,1);
imshow(cb_20);
title('4:2:0 cb band');

subplot(1,2,2);
imshow(cr_20);
title('4:2:0 cr band');



%6. Upsample and display the Cb and Cr bands using: (15 points)
%6.1. Linear interpolation
figure(4);
subplot(2,2,1);
imshow(rgb);
title('orig');


%pixel n = (n-1 + n+1)/2
cb20lin = cb;
cbdiff=cb20lin(1:2:end, 1:2:end) + [cb20lin(1:2:end, 3:2:end) cb20lin(1:2:end,end)]; %padds extra column
cb20lin(1:2:end, 2:2:end) = (cbdiff)/2;
cb20lin(2:2:end,:) = (cb20lin(1:2:end,:) + [cb20lin(3:2:end,:); cb20lin(end, :)])/2; %pads extra row


cr_20_lin=cr;
cbdiff=cr_20_lin(1:2:end, 1:2:end) + [cr_20_lin(1:2:end, 3:2:end) cr_20_lin(1:2:end,end)]; %padds extra column
cr_20_lin(1:2:end, 2:2:end) = (cbdiff)/2;
cr_20_lin(2:2:end,:) = (cr_20_lin(1:2:end,:) + [cr_20_lin(3:2:end,:); cr_20_lin(end, :)])/2; %pads extra row

upscaled_lin=cat(3, y, cb20lin, cr_20_lin);


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

y1= y;
cb1=cb;
cr1=cr;

y2=upscaled_lin(:,:,1);
cb2=cb20lin;%upscaled_lin(:,:,2);
cr2=cr_20_lin;%upscaled_lin(:,:,3);

dy=double(y1-y2);
dcb=double(cb1-cb2);
dcr=double(cr1-cr2);

msey =  mean(dy(:).^2);
msecb = mean(dcb(:).^2);
msecr = mean(dcr(:) );

MSE=[msey msecb msecr];
MSE=reshape(MSE, [1,3]);


fprintf('y-band MSE: %f\n', MSE(1));
fprintf('cb-band MSE: %f\n', MSE(2));
fprintf('cr-band MSE: %f\n', MSE(3));


% 11. Comment on the compression ratio achieved by subsampling Cb and Cr
% components for 4:2:0 approach. Please note that you do not send the pixels
% which are made zero in the row and columns during subsampling. (5 points)

before = size(y,1)*size(y,2)*3;

cb420= cb(2:2:end, 2:2:end);
cr420= cr(2:2:end, 2:2:end);
after = size(y,1)*size(y,2) +  size(cb420,1)*size(cb420,2) + size(cr420,1)*size(cr420,2);

CR=before/after;

fprintf('The compression ratio is: %f\n', CR);









