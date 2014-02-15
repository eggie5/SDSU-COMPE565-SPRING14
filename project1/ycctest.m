

function [] = ycctest(imageName)
    rgb = imread(imageName);
    ycbcr = rgb2ycbcr(rgb);   %convert to yuv space
    %display the y component as a color image
    %ycbcry = ycbcr;
    %ycbcry(:,:,2) = 0;
    %ycbcry(:,:,3) = 0;
    %rgb1 = ycbcr2rgb(ycbcry);
    %figure, imshow(rgb1);
    % display the cb component as a color image
   % ycbcru = ycbcr;
    %ycbcru(:,:,1) = 0;
    %ycbcru(:,:,3) = 0;
    %rgb2 = ycbcr2rgb(ycbcru);
    %figure, imshow(rgb2);
    % display the cr component as a color image
    %ycbcrv = ycbcr;
    %ycbcrv(:,:,1) = 0;
    %ycbcrv(:,:,2) = 0;
    %rgb3 = ycbcr2rgb(ycbcrv);
    %figure, imshow(rgb3);
    %display the y, cb, cr component as gray scale image
    figure,imshow(ycbcr(:,:,1));
    %figure,imshow(ycbcr(:,:,2));
    %figure,imshow(ycbcr(:,:,3));
end