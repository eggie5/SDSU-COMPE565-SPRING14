YCbCr 4:2:0 is one of sampling formats for three components Y, 
Cb, Cr used in image/video coding standards.
Some other formats are YCbCr 4:4:4,YCbCr 4:2:2

4:4:4 for every four luminance samples there are
         four Cb and four Cr samples

Pixel 1 Pixel 2 Pixel 3 Pixel 4 
Y,Cb,Cr Y,Cb,Cr Y,Cb,Cr Y,Cb,Cr


4:2:2 for every four luminance samples in the horizontal
         direction there are two Cb and two Cr samples.

Pixel 1 Pixel 2 Pixel 3 Pixel 4 
Y,Cb,Cr Y Y,Cb,Cr Y

4:2:0 Cb and Cr each have half the horizontal
         and vertical resolution of Y


Block 4x4 pixels


Y Y Y Y
 Cb,Cr Cb,Cr 
Y Y Y Y

Y Y Y Y
 Cb,Cr Cb,Cr 
Y Y Y Y

It means that, in 4:2:0 format, 4 pixels in each group 2x2 
share the same chroma.

for further information, refer to this illustration 

http://en.wikipedia.org/wiki/File:Chroma_subsampling_ratios.png

and this link
http://en.wikipedia.org/wiki/Chroma_subsampling

http://www.roman10.net/ycbcr-color-spacean-intro-and-its-applications/

Finally, your question does not have any relation to MATLAB, 
so it is better if you post it in image and video community.



****
#Subsampling
If by downsampling you specifically mean Chroma subsampling from 4:4:4 to 4:2:2, then one way to do it (and keep the original size of the channel) is to manually overwrite every other pixel with the previous value:

Cb(:, 2:2:end) = Cb(:, 1:2:end-1);
Cr(:, 2:2:end) = Cr(:, 1:2:end-1);
If you simply want to remove half of the columns, use:

Cb(:, 2:2:end) = [];
Cr(:, 2:2:end) = [];
Also in Matlab you don't need to write your own function for YCbCr conversion. Instead you can use rgb2ycbcr().