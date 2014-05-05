function [ output_args ] = printMV(label, f, motion_vectors )
%PRINTMV Summary of this function goes here
%   Detailed explanation goes here
  


    x=[1    17    33    49    65    81    97   113   129   145   161];
    x_axis=[x x x x x x x x x];
    y=[1    17    33    49    65    81    97   113   129];
    y_axis=[y y y y y y y y y y y];

    
  
    figure %motion vector figure
    quiver(x_axis,y_axis,motion_vectors(2,:), motion_vectors(1,:))
    axis([0 176 0 144]);
    title(sprintf('%s M. Vectors: Frames %d to %d',label,f,f+1));

end

