function out_component = subsample420( in_component )
% to420: converts a frame component to the 420 compression scheme
% @param in_component: the 2-dimensional array of one component
% @return out_component: the 2-dimensional array compressed
out_component = in_component;
out_component(:,2:2:end) = [];
out_component(2:2:end,:) = [];
end

