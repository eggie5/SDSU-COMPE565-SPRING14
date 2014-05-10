%this is conj method

function [motionVect, computations] = motionEstimation(imgP, imgI, mbSize, p)

[row col] = size(imgI);

vectors = zeros(2,row*col/mbSize^2);
costs = ones(3, 3) * 65537;

comp = 0;


L = floor(log10(p+1)/log10(2));   
MaximumStep = 2^(L-1);


mbCount = 1;
for i = 1 : mbSize : row-mbSize+1
    for j = 1 : mbSize : col-mbSize+1


        x = j;
        y = i;
        
        
        costs(2,2) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), imgI(i:i+mbSize-1,j:j+mbSize-1),mbSize);
        comp = comp + 1;
        stepSize = MaximumStep;               

        while(stepSize >= 1)  

            for m = -stepSize : stepSize : stepSize        
                for n = -stepSize : stepSize : stepSize
                    refBlkVertical = y + m;  
                    refBlkHoriz = x + n;   
                    if ( refBlkVertical < 1 || refBlkVertical+mbSize-1 > row ...
                        || refBlkHoriz < 1 || refBlkHoriz+mbSize-1 > col)
                        continue;
                    end


                    costRow = m/stepSize + 2;
                    costCol = n/stepSize + 2;
                    if (costRow == 2 && costCol == 2)
                        continue
                    end
                    costs(costRow, costCol ) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                        imgI(refBlkVertical:refBlkVertical+mbSize-1, refBlkHoriz:refBlkHoriz+mbSize-1), mbSize);
                    
                    comp = comp + 1;
                end
            end
        

            [dx, dy, min] = minCost(costs);      
            
           
            x = x + (dx-2)*stepSize;
            y = y + (dy-2)*stepSize;
            
            stepSize = stepSize / 2;
            costs(2,2) = costs(dy,dx);
            
        end
        vectors(1,mbCount) = y - i;   
        vectors(2,mbCount) = x - j;                
        mbCount = mbCount + 1;
        costs = ones(3,3) * 65537;
    end
end

motionVect = vectors;
computations = comp/(mbCount - 1);


                    