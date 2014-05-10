% compE565 Homework 1
% Feb. 20, 2014
% Name: Alex Egg
% ID:809-236-396
% email: eggie5@gmail.com

% 1. Read and display the image using Matlab (10 points).
% 2. Display each band (Red, Green and Blue) of the image file (15 points)
rgbt

% 3. Convert the image into YCbCr color space: (5 points)
% 4. Display each band separately (Y, Cb and Cr bands). (10 points)
ycbcrt


% 5. Subsample Cb and Cr bands using 4:2:0 and display both bands. 
% 6. Upsample and display the Cb and Cr bands using: (15 points)
% 6.1. Linear interpolation
% 6.2. Simple row or column replication.
% 7. Convert the image into RGB format. (5 points)
% 8. Display the original and reconstructed images (the image restored from
% the YCbCr coordinate). (5 points)
% 9. Comment on the visual quality of the reconstructed image for both the 
% upsampling cases. (5 points)
display('see report for quality comments');

% 10. Measure MSE between the original and reconstructed images (obtained 
% using linear interpolation only). Comment on the results. (10 points)
% 11. Comment on the compression ratio achieved by subsampling Cb and Cr 
% components for 4:2:0 approach. Please note that you do not send the 
% pixels which are made zero in the row and columns during subsampling. 
% (5 points)

subsample