

function [dx, dy, min] = minCost(costs)

[row, col] = size(costs);

% we check whether the current
% value of costs is less then the already present value in min. If its
% inded smaller then we swap the min value with the current one and note
% the indices.

min = 65537;

for i = 1:row
    for j = 1:col
        if (costs(i,j) < min)
            min = costs(i,j);
            dx = j; dy = i;
        end
    end
end




