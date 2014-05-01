%Decoder
%Daniel Tarantino (813-25-2720)
%Mohammad Iqbal (809-86-2450)
%Agha Zain (815-07-1719)
%Soroush Tamizi (817-35-2933)
%COMPE 565 Fall 2013
%Dr. Kumar

function decoder(y_fr1,cb_fr1,cr_fr1,mv_y,mv_cbcr,ff)
for n=1:5
    y = y_fr1(:,:,n);
    cb = cb_fr1(:,:,n);
    cr = cr_fr1(:,:,n);
    
    [y,cb,cr] = IDCT(y,cb,cr);
    cb = upsample(cb);
    cr = upsample(cr);
    
    if n==1
        % Save the I frame components 
        reference_y = uint8(y);
        reference_cb = uint8(cb);
        reference_cr = uint8(cr);
        
        received(:,:,1) = reference_y;
        received(:,:,2) = reference_cb;
        received(:,:,3) = reference_cr;
        original = ff(n).cdata(:,:,:);
        imageError=original-received;
        %Display images
        figure();
        subplot(1,3,1),subimage(original),title('Original I Frame');
        subplot(1,3,2),subimage(ycbcr2rgb(received)),title('Decoded I Frame');
        subplot(1,3,3),subimage(imageError),title('Error I Frame');
    else
        motionVy = mv_y(:,:,n);
        motionVb = mv_cbcr(:,:,n);
        motionVr = mv_cbcr(:,:,n);
        
        %Sending P frames for Decoding 
        y = DecoderMV(reference_y,y,motionVy);
        cb = DecoderMV(reference_cb,cb,motionVb);
        cr = DecoderMV(reference_cr,cr,motionVr);

        reference_y=y;
        reference_cb=cb;
        reference_cr=cr;
        
        received(:,:,1) = reference_y;
        received(:,:,2) = reference_cb;
        received(:,:,3) = reference_cr;
        
        originalpicture = ff(n).cdata(:,:,:);
        error=originalpicture-received;
        figure();
        subplot(1,3,1),subimage(originalpicture),title(['Original Frame #', num2str(n)]);
        subplot(1,3,2),subimage(ycbcr2rgb(received)),title(['Decoded Frame #', num2str(n)]);
        subplot(1,3,3),subimage(error),title(['Error of Frame #', num2str(n)]);
    end
end
