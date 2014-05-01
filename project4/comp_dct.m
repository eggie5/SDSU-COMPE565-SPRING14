function [y_out, cb_out, cr_out] = find_dct(y_in, cb_in, cr_in, blocksize)
% find_dct: takes in a frame (all three components) and finds the DCT
%
% @params frame - the full frame [h, w, components] in the pixel domain
% @params blocksize - size for the block process to compute at a time
% @return y_out - the [h, w, components] in DCT coefficients 
%                   (type int16)

pDCT = @dct2;
y_out = ((blkproc(y_in, [blocksize blocksize], pDCT)));
cb_out = ((blkproc(cb_in, [blocksize blocksize], pDCT)));
cr_out = ((blkproc(cr_in, [blocksize blocksize], pDCT)));

end
