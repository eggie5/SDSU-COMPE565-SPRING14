%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Authors:    Alex Egg
%   Assignment: HW Assignment 3
%   Date:       11 April 2014
%   email:      eggie5@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function []=proj3()

    clear;

    vr=VideoReader('walk_qcif.avi');
    frames=read(vr);
    frames=frames(:,:,:,1:5); %clip off extra frames

    %get Y component of the first 5 frames
     for i = 1:5
         frames(:,:,:,i)= rgb2ycbcr(frames(:,:,:,i));
     end

    for f = 1:4
        
        ref=double(frames(:,:,1,1));
        current=double(frames(:,:,1,f+1));
        
        fprintf('Frame %d\n', f);

        %%%%%%%%%%%%%%%%%%%%%
        % exhaustive search
        fprintf('\tExhaustive Search\n')
        ES_CPU(f) = cputime;
        [motionVect, mad_computations, es_avg_mad] = motionEstES(current,ref,16,7);
        EScomputations(f) = mad_computations; %#ok<AGROW>
        imgComp = motionComp(ref, motionVect, 16);
        ESpsnr(f) = imgPSNR(current, imgComp, 255); %#ok<AGROW>
        error_image=uint8(abs(current-imgComp));
        
        ES_CPU(f) = cputime - ES_CPU(f); %#ok<AGROW>
        fprintf('\t\tCPU time: %.3f seconds\n', ES_CPU(f));
        printer('ES', f, imgComp, error_image, motionVect, ESpsnr(f), EScomputations(f), es_avg_mad);


        %%%%%%%%%%%%%%%%%%%
        % Three Step Search
        fprintf('\tThree Step Search\n');
        TSS_CPU(f) = cputime; %#ok<AGROW>
        [tsmotionVect, tscomputations, tss_avg_mad] = motionEstTSS(current,ref,16,7);
        ts_imgComp = motionComp(ref, tsmotionVect, 16);
        TSSpsnr(f) = imgPSNR(current, ts_imgComp, 255); %#ok<AGROW>
        TSScomputations(f) = tscomputations; %#ok<AGROW>
        tserror_image=uint8(abs(current-ts_imgComp));

        TSS_CPU(f) = cputime - TSS_CPU(f); %#ok<AGROW>
        fprintf('\t\tCPU time: %.3f seconds\n',  TSS_CPU(f));
        printer('TSS', f, ts_imgComp, tserror_image, tsmotionVect, TSSpsnr(f), TSScomputations(f), tss_avg_mad );


    end
end

function [] = printer(label, f, reconstructed_image, error_image, motion_vectors, psnr, comp_sum, avg_mad)   
   %display figures
   %just bootstrap code to get axis for plot

    x=[1    17    33    49    65    81    97   113   129   145   161];
    x_axis=[x x x x x x x x x];
    y=[1    17    33    49    65    81    97   113   129];
    y_axis=[y y y y y y y y y y y];

    
    fprintf('\t\tSearches per block: %d\n', comp_sum);
    
    %this is how many times we had to calc MAD for this frame
    %this is the computational overhead
    fprintf('\t\tTotal MAD operations %.3f\n', comp_sum);
    
    fprintf('\t\tAverge MAD/block %.3f\n', avg_mad);
    
    
    %the PSNR of the reconstructed image VS the refernce
    %this quantifies the quality of the reconsturction
    fprintf('\t\tPSNR %.3f \n', psnr);
    

    figure
    subplot(1,2,1);
    imshow(uint8(reconstructed_image));
    title(sprintf('Reconstructed %s Image for Frame %d',label, f+1)); 
    
    subplot(1,2,2);
    imshow(error_image);
    title(sprintf('%s Error Img. for Frame %d', label, f+1));
    
    figure %motion vector figure
    quiver(x_axis,y_axis,motion_vectors(2,:), motion_vectors(1,:))
    axis([0 176 0 144]);
    title(sprintf('%s M. Vectors: Frames %d to %d',label,f,f+1));
end