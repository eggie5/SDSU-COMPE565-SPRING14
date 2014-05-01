function cost = costFuncMAD(currentBlk,refBlk, n)


err = 0;
for i = 1:n
    for j = 1:n
        err = err + abs((currentBlk(i,j) - refBlk(i,j)));
        
    end
end
cost = err / (n*n); % this is the mean part

