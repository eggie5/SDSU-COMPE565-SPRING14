function [out_buff_y, out_buff_cb, out_buff_cr, mvlbuff, mvcbuff]=encoder(video_path)

    vr=VideoReader(video_path);
    frames=read(vr);
    dimensions=size(frames);
    width=dimensions(1);
    height=dimensions(2);
    
    mbSize = 16; 
    fc = 5;
    initialStepSize = 8; 
    
    frames=frames(:,:,:,1:5); %clip off extra frames

 
    out_buff_y = zeros(width, height, fc);
    out_buff_cb = zeros(width/2, height/2, fc);
    out_buff_cr = zeros(width/2, height/2, fc);

    mvlbuff = zeros(2, width*height/mbSize.^2, fc); 
    mvcbuff = zeros(2, width*height/mbSize.^2, fc);
     
   
    
    for f = 0:4
        target= double(rgb2ycbcr(frames(:,:,:,f+1)));
        
        %every 10th frame is I frame
        if(mod(f,10)==0)
            
            %skip all Motion Compensation, jpeg compress and add ooutput
            %buffer
            
            Iframe = target;
            [refQ_Y, refQ_Cb, refQ_Cr] = jpeg_encode(Iframe);
           
            out_buff_y(:,:,1)=refQ_Y;
            out_buff_cb(:,:,1)=refQ_Cb;
            out_buff_cr(:,:,1)=refQ_Cr;
            
            dec_I = jpeg_decode(out_buff_y(:,:,1), out_buff_cb(:,:,1), out_buff_cr(:,:,1));
            
            %figure
            %imshow(ycbcr2rgb(uint8(dec_I)));

            
            %use this compressed I frame for motion estimation on the next
            %frame
            next_ref=dec_I;
            
            
        else
             
            fprintf('Frame %d\n', f+1);

            target_y=target(:,:,1);     

            %3 step search
            [motion_vectors, ~, ~] = motionEstTSS(target_y ,ref_y, mbSize, initialStepSize);
            mvlbuff(:,:,f+1) = motion_vectors;
            mvcbuff(:,:,f+1) = motion_vectors./2;
            printMV('asfd', f, motion_vectors);

            %reconstrct y comp.
            mcomp_y = motionComp(ref_y, motion_vectors, mbSize);

            %reconstrct cb & cr comp's. 
            ref_Cb_SS = subsample420(ref_Cb);
            ref_Cr_SS = subsample420(ref_Cr);
            mcomp_cb = motionComp(ref_Cb_SS, mvcbuff(:,:,f+1), mbSize/2);
            mcomp_cr = motionComp(ref_Cr_SS, mvcbuff(:,:,f+1), mbSize/2);
            m_compensated_cb_us = upsample(mcomp_cb);
            m_compenstaed_cr_us = upsample(mcomp_cr);
            
            motion_compensated_ycbcr_us = cat(3, mcomp_y, m_compensated_cb_us, m_compenstaed_cr_us);
            

            % compute the diff of each P frame & original
            % After predicting frames using motion compensation, the coder finds the error (residual) which is then compressed and transmitted.
            residual =  target - (motion_compensated_ycbcr_us);

            
            %jpeg encode for transmittion
            [Q_Y Q_Cb Q_Cr] = jpeg_encode(residual);
            
      
            
            %add to output buffer
            out_buff_y(:,:,f+1)=Q_Y;
            out_buff_cb(:,:,f+1)=Q_Cb;
            out_buff_cr(:,:,f+1)=Q_Cr;

            
            %embedded decoder
            decoded_residue = predictRefImage(out_buff_y(:,:,f+1), out_buff_cb(:,:,f+1), out_buff_cr(:,:,f+1));
            decoded_frame = (motion_compensated_ycbcr_us) + double(decoded_residue);
            
           
            next_ref = Iframe;
            
        end
        
        %sets the ref for the next iteration
        %The refs should be in this order: 
        %ref frame#     1,  2,  3,  4
        %target frame#  2,  3,  4,  5
        %this creates a I -> P -> P -> P -> P
        %frame sequence

        ref_y = double(next_ref(:,:,1));
        ref_Cb = double(next_ref(:,:,2));
        ref_Cr = double(next_ref(:,:,3));
    end
end
