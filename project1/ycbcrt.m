

rgb=imread('SunView.jpg');
[height,width,depth]=size(rgb);

ycbcr=rgb2ycbcr(rgb);

y=ycbcr(:,:,1); %luminance part of the ycbcr image
cb=ycbcr(:,:,2);
cr=ycbcr(:,:,3);

% z = zeros(size(ycbcr, 1), size(ycbcr, 2));
% yband=cat(3, y, z, z);
% crband=cat(3,z,cr,z);
% cbband=cat(3,y,z,cr);



figure(2);


subplot(2,2,1);
imshow(ycbcr);
title('ycbcr');
subplot(2,2,2);
imshow(y);
title('Luminance (Y)');
subplot(2,2,3);
imshow(cb);
title('Cb');
subplot(2,2,4);
imshow(cr);
title('Cr');

