
function [motionVect, ES_mad_computations, avg_mad] = motionEstES(imgP, imgI, mbSize, p)

[row col] = size(imgI);

vectors = zeros(2,row*col/mbSize^2);
costs = ones(2*p + 1, 2*p +1) * 65537;

mad_computations = 0;
mins=[];


mbCount = 1;
%this shifts the search window
for i = 1 : mbSize : row-mbSize+1
    for j = 1 : mbSize : col-mbSize+1
        

        
        %this shifts the search MB relative to the search frame. Compares P
        %against I1608
        for m = -p : p        
            for n = -p : p
                refBlkVert = i + m;   % row/Vert co-ordinate for ref block
                refBlkHor = j + n;   % col/Horizontal co-ordinate
                if ( refBlkVert < 1 || refBlkVert+mbSize-1 > row  || refBlkHor < 1 || refBlkHor+mbSize-1 > col) %pathalogical case where we are off the image edge
                    continue;
                end
                costs(m+p+1,n+p+1) = costFuncMAD(imgP(i:i+mbSize-1, j:j+mbSize-1), imgI(refBlkVert:refBlkVert+mbSize-1, refBlkHor:refBlkHor+mbSize-1), mbSize);
                mad_computations = mad_computations + 1;
                
            end
        end
        
        % Now we find the vector where the cost is minimum
        % and store it ... this is what will be passed back.
        
        [dx, dy, min] = minCost(costs); % finds which macroblock in imgI gave us min Cost
        mins=[mins min];
        vectors(1,mbCount) = dy-p-1;    % row co-ordinate for the vector
        vectors(2,mbCount) = dx-p-1;    % col co-ordinate for the vector
        mbCount = mbCount + 1;
        costs = ones(2*p + 1, 2*p +1) * 65537; %reset for next iteration
    end
end

motionVect = vectors;
ES_mad_computations = mad_computations;%/(mbCount - 1);
avg_mad=mean(mins);
                    