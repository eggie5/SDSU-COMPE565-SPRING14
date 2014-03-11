function [ dct ] = jpeg_dct( block_struct )

    A = block_struct.data
    D = dctmtx(size(A,1));
    dct = D*A*D';

end

