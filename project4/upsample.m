%upsamples an image%
%Daniel Tarantino (813-25-2720)
%Mohammad Iqbal (809-86-2450)
%Agha Zain (815-07-1719)
%Soroush Tamizi (817-35-2933)
%COMPE 565 Fall 2013
%Dr. Kumar

function Image_Upsampled = upsample (Image)


width =  176;
height = 144;

%Create a filter 
avg_filter = [0.5, 0.5];

%Average elements 
row_average = filter(double(avg_filter), 1, double(Image));

%Copy the average values 
I_row_upsample= zeros(height, width/2);
I_row_upsample(2:2:height-1, :) = row_average(2:1:height/2, :);

%Copy the rows
I_row_upsample(1:2:height-1,:) = Image;

%Replicate row height
I_row_upsample(height, :)= I_row_upsample(height-1,:);

%Get the transpose 
I_col_upsample = I_row_upsample';

%Average elements 
col_average = filter(double(avg_filter), 1, double(I_col_upsample));
%Transpose again
col_average = col_average';

%Create a matrix 
Image_Upsampled = zeros(height, width);

%Copy columns 
Image_Upsampled(:, 1:2:width-1) = I_row_upsample;
Image_Upsampled(:, 2:2:width-1) = col_average(:, 2:1:width/2);

%Replicate column 
Image_Upsampled(:, width) = Image_Upsampled(:, width-1);
	
%Round off the decimal values 
 Image_Upsampled = floor(Image_Upsampled);
