rgb=imread('SunView.jpg');



r=rgb(:,:,1);
g=rgb(:,:,2);
b=rgb(:,:,3);
z = zeros(size(rgb, 1), size(rgb, 2));

red_comp = cat(3, r, z, z);
green_comp = cat(3, z, g, z);
blue_comp = cat(3, z, z, b);
    

subplot(2,2,1)
imshow(rgb)
subplot(2,2,2)
imshow(red_comp)
subplot(2,2,3)
imshow(green_comp)
subplot(2,2,4)
imshow(blue_comp)
