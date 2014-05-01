function [y_out, cb_out, cr_out] = dct_quantize(y_in, cb_in, cr_in, blocksize)
% dct_quantize: This function finds quantized values for the
%                   given frame
% @param y_in, cb_in, cr_in: the full valued y/cb/cr components for the frame
%
% @return y_out, cb_out, cr_out: the quantized values for the
%                                   y/cb/cr components for the frame
y_in = (y_in);
cb_in = (cb_in);
cr_in = (cr_in);
y_quant_matrix = [
    16  11  10  16  24  40  51  61;
    12  12  14  19  26  58  60  55;
    14  13  16  24  40  57  69  56;
    14  17  22  29  51  87  89  62;
    18  22  37  56  68 109 103  77;
    24  35  55  64  81 104 113  92;
    49  64  78  87 108 121 120 101;
    72  92  95  98 112 100 103  99
    ];
cr_quant_matrix = [
    17 18 24 47 99 99 99 99;
    18 21 26 66 99 99 99 99;
    24 26 56 99 99 99 99 99;
    47 66 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    ];

quantize_y = @(block_struct) ...
    round(block_struct.data ./ y_quant_matrix);
quantize_cbcr = @(block_struct) ...
    round(block_struct.data ./ cr_quant_matrix);

y_out =  (blockproc(y_in, [blocksize blocksize], quantize_y));
cb_out =  (blockproc(cb_in, [blocksize blocksize], quantize_cbcr));
cr_out =  (blockproc(cr_in, [blocksize blocksize], quantize_cbcr));
end