function psnr = imgPSNR(imgP, imgComp, n)

[row col] = size(imgP);

err = 0;

for i = 1:row
    for j = 1:col
        err = err + (imgP(i,j) - imgComp(i,j))^2;
    end
end
mse = err / (row*col);

psnr = 10*log10(n*n/mse);