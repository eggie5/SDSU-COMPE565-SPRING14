function []=encoder()

    clear;

    vr=VideoReader('walk_qcif.avi');
    frames=read(vr);
    dimensions=size(frames)
    width=dimensions(1);
    height=dimensions(2);
    
    frames=frames(:,:,:,1:5); %clip off extra frames

    %convert frames to ycbcr
     for i = 1:5
         frames(:,:,:,i)= rgb2ycbcr(frames(:,:,:,i));
     end
     
 
    ybuff = zeros(width, height, 5);
    size(ybuff)
    cbbuff = zeros(width/2, height/2, 5);
    crbuff = zeros(width/2, height/2, 5);

    mvlbuff = zeros(2, width*height/16.^2, 5); 
    size(mvlbuff)
    mvcbuff = zeros(2, width*height/16.^2, 5);
     
    %I frame
    ref=double(frames(:,:,:,1)); 
    [refQ_Y, refQ_Cb, refQ_Cr] = jpeg_encode(ref);
    
    %add compressed iframe to the buffer
    ybuff(:,:,1)=refQ_Y;
    cbbuff(:,:,1)=refQ_Cb;
    crbuff(:,:,1)=refQ_Cr;
    
    dec_I = (predictRefImage(ybuff(:,:,1), cbbuff(:,:,1), crbuff(:,:,1)));
    
    imshow(dec_I)
    
    ref_Y = double(dec_I(:,:,1)); 
    ref_Cb = double(dec_I(:,:,2));
    ref_Cr = double(dec_I(:,:,3));
   
    
    for f = 1:4
        
        current=double(frames(:,:,:,f+1));
        
        fprintf('Frame %d\n', f);
        
        %%%%%%%%%%%%%%%%%%%
        % Three Step Search
        fprintf('\tThree Step Search\n');
        [tsmotionVect, tscomputations, tss_avg_mad] = motionEstTSS(current(:,:,1),ref_Y,16,7);
        size(tsmotionVect)
        mvlbuff(:,:,f+1)=tsmotionVect;
        mvchroma=tsmotionVect/2;
        mvcbuff(:,:,f+1)=mvchroma;
        
        %now do I zig zag this or what?
        
        %reconstrct the image and take the diff
        compy = motionComp(ref_Y, tsmotionVect, 16)
        
        %subsample 
        ref_Cb_SS = ref_Cb(1:2:size(ref_Cb, 1), 1:2:size(ref_Cb, 2));
        ref_Cr_SS = ref_Cr(1:2:size(ref_Cr, 1), 1:2:size(ref_Cr, 2));
        compcb=motionComp(ref_Cb_SS, mvchroma, 8)
        compcr=motionComp(ref_Cr_SS, mvchroma, 8)
        
        %Upsample function
        Compensated_Cb_US = upsample(compcb);
        Compensated_Cr_US = upsample(compcr);
      
        Comp_YCbCr_US = (zeros(144, 176, 3));
         Comp_YCbCr_US(:,:,1) =  (compy);
         Comp_YCbCr_US(:,:,2) =  (Compensated_Cb_US);
          Comp_YCbCr_US(:,:,3) =  (Compensated_Cr_US);
       
        
        %now jpeg compress this resuidual
        residual = current - Comp_YCbCr_US;
        
        
        [Q_Y Q_Cb Q_Cr] = jpeg_encode(residual)
        
        ybuff(:,:,f+1)=Q_Y;
        cbbuff(:,:,f+1)=Q_Cb;
        crbuff(:,:,f+1)=Q_Cr;
        
        decoded_diff = predictRefImage(ybuff(:,:,f+1), cbbuff(:,:,f+1), crbuff(:,:,f+1));
        
      
        
       ref_frame = double(decoded_diff) + Comp_YCbCr_US;
        ref_Y = double(ref_frame(:,:,1));
        ref_Cb = double(ref_frame(:,:,2));
        ref_Cr = double(ref_frame(:,:,3));
        
        return;
       


    end
    
    motion_vector_buffer
    size(motion_vector_buffer)
end
