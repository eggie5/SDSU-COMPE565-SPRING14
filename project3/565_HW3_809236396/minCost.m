function [dx, dy, min] = minCost(costs)

[row, col] = size(costs);

min = 65537;

for i = 1:row
    for j = 1:col
        if (costs(i,j) < min)
            min = costs(i,j);
            dx = j; dy = i;
        end
    end
end




