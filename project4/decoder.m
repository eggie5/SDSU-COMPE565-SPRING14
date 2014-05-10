function decoder(res_y, res_cb, res_cr, mv_y,mv_cbcr, raw_frames)
for n=1:5
    
    decoded_res = jpeg_decode(res_y(:,:,n), res_cb(:,:,n), res_cr(:,:,n));
    y = decoded_res(:,:,1);
    cb = decoded_res(:,:,2);
    cr = decoded_res(:,:,3);
    
    if n==1
        %just pass I frame to output sink
        ref_y = (y);
        ref_cb =(cb);
        ref_cr =(cr);
    else        
        %decode P frames 
        y = motion_comp_inv(ref_y, y, mv_y(:,:,n));
        cb = motion_comp_inv(ref_cb, cb, mv_cbcr(:,:,n));
        cr = motion_comp_inv(ref_cr, cr, mv_cbcr(:,:,n));
    end
    
    reconstructed = cat(3, y, cb, cr);
        
    raw_frame = raw_frames(:,:,:,n);
    error = raw_frame-reconstructed;
    
    %set the next ref frame
    
    
    figure();
    subplot(1,3,1),subimage(raw_frame), title(['Original Frame #', num2str(n)]);
    subplot(1,3,2),subimage(ycbcr2rgb(reconstructed)), title(['Decoded Frame #', num2str(n)]);
    subplot(1,3,3),subimage(error), title(['Error of Frame #', num2str(n)]);
end
