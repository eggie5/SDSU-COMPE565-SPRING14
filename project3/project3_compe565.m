
function project3_compe565(filepath)
% params\ filepath: The string path of the file to use for this function
%                   i.e. 'C:\Users\Thomas\Pictures\video.avi'
clc;
clear;
try
    v_handle = VideoReader('walk_qcif.avi');
    video_frames = read(v_handle);
catch err
    error('prog:input', 'Invalid filepath! Enter as ''C:\\filelocation\\file.avi'' ');
end
sizeOfFrame = size(video_frames);
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%% Constants %%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
global BLOCKSIZE;

% Use these variables to control the Macroblock size, the search frame
% size, and the number of frames to find motion vectors for
NUM_FRAMES = 5;
BLOCKSIZE = 16;
W_SEARCH = 8;
    % Noneditable Constants %
MAXROWS = sizeOfFrame(1);
MAXCOLS = sizeOfFrame(2);
BLOCKS_PER_ROW = MAXROWS/BLOCKSIZE;
BLOCKS_PER_COL = MAXCOLS/BLOCKSIZE;
TOTAL_FRAME_COUNT = sizeOfFrame(4);

fprintf('MACROBLOCK SIZE: %d\n', BLOCKSIZE);

% Convert to YCbCr color space
for n = 1:TOTAL_FRAME_COUNT
               % r,g,b,frame -----> y,cb,cr,frame
    video_frames(:,:,:,n) = rgb2ycbcr(video_frames(:,:,:, n));
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
% Exhaustive Search Motion                                                %
% Searches all macroblock positions in the search window                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('BEGIN EXHAUSTIVE SEARCH\n');
% Vector matrices for use in quiver
ES_vector_x = zeros(BLOCKS_PER_ROW,BLOCKS_PER_COL,2,NUM_FRAMES);
ES_vector_y = zeros(BLOCKS_PER_ROW,BLOCKS_PER_COL,2,NUM_FRAMES);

% Stores the amount of time each frame takes to find the best motion
% vectors
ES_CPU = zeros(NUM_FRAMES,1);

% Stores the total Mean Absolute Difference for each frame
ES_MAD = zeros(NUM_FRAMES,1);

% The residual must be signed integers because the residue could be
% negative
ES_residual = int16(zeros(MAXROWS,MAXCOLS,NUM_FRAMES));

%%% frame FOR loop %%%
for frame=2:NUM_FRAMES
    ES_CPU(frame) = cputime; %get starting time
    
    % Grab the current frame and the frame before as the reference
    ref_frame = video_frames(:,:,1, frame-1);
    cur_frame = video_frames(:,:,1, frame);
    
    % row/col_count are used for the vector matrix indices 
    row_count = 1;
    col_count = 1;
    
    %%%%%%%%%%% Loop through all the macroblocks in the frame %%%%%%%%%%%%%
    for block_row=1:BLOCKSIZE:MAXROWS
        for block_col=1:BLOCKSIZE:MAXCOLS
            
            % Set the block in the current frame
            cur_block = cur_frame(block_row:mb_end(block_row), block_col:mb_end(block_col));
            
            % Record the starting position of the block
            ES_vector_x(row_count,col_count,1,frame) = block_col;
            ES_vector_y(row_count,col_count,1,frame) = block_row;
            
            % Set the search window edges
            top = block_row - W_SEARCH;
            left = block_col - W_SEARCH;
            bottom = block_row + BLOCKSIZE + W_SEARCH;
            right = block_col + BLOCKSIZE + W_SEARCH;
            % If the search window is outside of the bounds of the frame,
            % truncate it to the first/last pixel
            if (top < 1)
                top = 1;
            end
            if (left < 1)
                left = 1;
            end
            if (bottom > MAXROWS)
                bottom = MAXROWS;
            end
            if (right > MAXCOLS)
                right = MAXCOLS;
            end

            % Set the reference block to the top left of search window and
            % the min_MAD to the difference of this
            % int16 is needed because uint8(140-255) = 0
            ref_block = ref_frame(top:mb_end(top), left:mb_end(left));
            min_MAD = sum(abs(int16(cur_block(:)) - int16(ref_block(:))));
            col_vector = left;
            row_vector = top;
            
            %%%%%%%%%%%%%%%% Begin exhaustive search %%%%%%%%%%%%%%%%%%%%%%
            % Searches each block possible from left to right, top to bottom
            % in the search window, then stores the vector and MAD of the
            % of the lowest error.
            for i = top:bottom-BLOCKSIZE+1     % -BLOCKSIZE is used because the 
                for j = left:right-BLOCKSIZE+1 % whole MB must fit in window
                    ref_block = ref_frame(i:mb_end(i), j:mb_end(j));
                    MAD = mean(abs(int16(cur_block(:))- int16(ref_block(:))));
                    % If the MAD of the search candidate is less than the 
                    % previous minimum, record the location and new min
                    if(MAD < min_MAD)
                        min_MAD = MAD;
                        col_vector = j;
                        row_vector = i;
                    end
                end
            end % Search
            
            % Add in to the total MAD for the frame
          
            ES_MAD(frame) = ES_MAD(frame) + min_MAD;
            
            % record the location of the best match in the vector matrix
            ES_vector_x(row_count,col_count,2,frame) = col_vector;
            ES_vector_y(row_count,col_count,2,frame) = row_vector;
            
            % Store the residual difference: 
            %           cur_frame - best_match(in reference frame)
            % int16 is needed due to negative residual values
            best_match = ref_frame(row_vector:mb_end(row_vector), col_vector:mb_end(col_vector));
            ES_residual(block_row:mb_end(block_row),block_col:mb_end(block_col),frame) = ...
                int16(cur_block) - int16(best_match);

            col_count = col_count+1;
        end % block_col
        row_count = row_count+1;
        col_count = 1;
    end % block_row
    
    % Get the end CPU time for the current frame and display
    ES_CPU(frame) = cputime - ES_CPU(frame);
    fprintf('Frame %d CPU time: %.3f seconds\n', frame, ES_CPU(frame));
    
    % Plot the motion vectors for the frame
    x_start = ES_vector_x(:,:,1,frame);
    x_end = ES_vector_x(:,:,2,frame) - x_start;
    y_start = ES_vector_y(:,:,1,frame);
    y_end = ES_vector_y(:,:,2,frame) - y_start;
    figure();
    quiver(x_start,y_start,x_end,y_end);
    axis([0 MAXCOLS 0 MAXROWS]);
    title(['Full Search Motion Vector for Frames ',num2str(frame-1),' to ',num2str(frame)]);
end % Frame

%% %% Print out metrics for Exhaustive Search %% %%
tot_searches = (2*W_SEARCH+1).^2;
fprintf('\t# Searches     per block: %d\n', tot_searches);
fprintf('\t# Subtractions per block: %d\n', BLOCKSIZE.^2*tot_searches);
fprintf('\t# Additions    per block: %d\n', 2*BLOCKSIZE.^2*tot_searches);
fprintf('\t# Comparisons  per block: %d\n', (2*W_SEARCH + 1).^2);
fprintf('\t Average MAD   per block: %d\n', int32(sum(ES_MAD(:))/(BLOCKS_PER_ROW*BLOCKS_PER_COL*(NUM_FRAMES-1))));
fprintf('\t Average Error per pixel: %.3f\n', sum(ES_MAD(:))/(MAXROWS*MAXCOLS*(NUM_FRAMES-1)));
fprintf('\tTotal CPU time taken: %.3f\n',sum(ES_CPU(:)));


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
% Conjugate Directions Search                                             %
% Searches blocks in all directions of center and                         %
% reiterates on  the block with the lowest MAD                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\nBEGIN CONJUGATE DIRECTIONS SEARCH\n');

% Vector matrices for use in quiver
CDS_vector_x = zeros(BLOCKS_PER_ROW,BLOCKS_PER_COL,2,NUM_FRAMES);
CDS_vector_y = zeros(BLOCKS_PER_ROW,BLOCKS_PER_COL,2,NUM_FRAMES);

% Stores the amount of time each frame takes to find the best motion
% vectors
CDS_CPU = zeros(NUM_FRAMES,1);

% Stores the total Mean Absolute Difference for each frame
CDS_MAD = zeros(NUM_FRAMES,1);

% The residual must be signed integers because the residue could be
% negative
CDS_residual = int16(zeros(MAXROWS,MAXCOLS,NUM_FRAMES));

% Counter of how many searches were needed to find the best motion vector
tot_searches = 0;

%%% frame FOR loop %%%
for frame=2:NUM_FRAMES
    CDS_CPU(frame) = cputime; % get starting time

    % Grab the current frame and the frame before as a reference
    ref_frame = video_frames(:,:,1, frame-1);
    cur_frame = video_frames(:,:,1, frame);
    
    % row/col_count are used for the vector matrix indices 
    row_count = 1;
    col_count = 1;
    
    %%%%%%%%%%% Loop through all the macroblocks in the frame %%%%%%%%%%%%%
    for block_row=1:BLOCKSIZE:MAXROWS
        for block_col=1:BLOCKSIZE:MAXCOLS
            % Set the block in the current frame
            cur_block = cur_frame(block_row:mb_end(block_row), block_col:mb_end(block_col));
            
            % Record the starting position of the block
            CDS_vector_x(row_count,col_count,1,frame) = block_col;
            CDS_vector_y(row_count,col_count,1,frame) = block_row;
            
            % Set the search window edges
            top = block_row - W_SEARCH;
            left = block_col - W_SEARCH;
            bottom = block_row + BLOCKSIZE + W_SEARCH;
            right = block_col + BLOCKSIZE + W_SEARCH;
            % If the search window is outside of the bounds of the frame,
            % truncate it to the first/last pixel
            if (top < 1)
                top = 1;
            end
            if (left < 1)
                left = 1;
            end
            if (bottom > MAXROWS)
                bottom = MAXROWS;
            end
            if (right > MAXCOLS)
                right = MAXCOLS;
            end
            
            % Save coordinates of the current middle block
            cur_row = block_row;
            cur_col = block_col;
            new_row = cur_row;
            new_col = cur_col;
            % Set Center Block in reference frame and find the Center MAD
            mb_c = ref_frame(cur_row:mb_end(cur_row),cur_col:mb_end(cur_col));
            min_MAD = sum(abs(int16(cur_block(:)) - int16(mb_c(:))));
            
            tot_searches = tot_searches + 1;
            %%%%%%%%%%%%%%%%%% Begin CDS Search Algorithm %%%%%%%%%%%%%%%%%
            % The CDS algorithm starts in the center and searches all 4
            % blocks on each side. If the center block has the lowest MAD, 
            % end algorithm.  Otherwise, reiterate by setting the block
            % with the lowest mad as the new center block.
            while 1
                %Check if able to shift macroblock upwards
                if(cur_row-1 >= top)
                    mb_u = ref_frame(cur_row-1:mb_end(cur_row-1),cur_col:mb_end(cur_col));
                    mad_u = sum(abs(int16(cur_block(:))- int16(mb_u(:))));
                    % Check if this block is less than the previous minimum
                    if (mad_u < min_MAD)
                        min_MAD = mad_u;
                        new_row = cur_row - 1;
                        new_col = cur_col;
                    end
                end
                %Check if able to shift macroblock downwards
                if(cur_row+1 <= bottom-BLOCKSIZE+1)
                    mb_d = ref_frame(cur_row+1:mb_end(cur_row+1),cur_col:mb_end(cur_col));
                    mad_d = sum(abs(int16(cur_block(:))- int16(mb_d(:))));
                    % Check if this block is less than the previous minimum
                    if (mad_d < min_MAD)
                        min_MAD = mad_d;
                        new_row = cur_row + 1;
                        new_col = cur_col;
                    end
                end
                %Check if able to shift macroblock leftwards
                if(cur_col-1 >= left)
                    mb_l = ref_frame(cur_row:mb_end(cur_row),cur_col-1:mb_end(cur_col-1));
                    mad_l = sum(abs(int16(cur_block(:))- int16(mb_l(:))));
                    % Check if this block is less than the previous minimum
                    if (mad_l < min_MAD)
                        min_MAD = mad_l;
                        new_row = cur_row;
                        new_col = cur_col - 1;
                    end
                end
                %Check if able to shift macroblock rightwards
                if(cur_col+1 <= right-BLOCKSIZE+1)
                    mb_r = ref_frame(cur_row:mb_end(cur_row),cur_col+1:mb_end(cur_col+1));
                    mad_r = sum(abs(int16(cur_block(:))- int16(mb_r(:))));
                    % Check if this block is less than the previous minimum
                    if (mad_r < min_MAD)
                        min_MAD = mad_r;
                        new_row = cur_row;
                        new_col = cur_col + 1;
                    end
                end      
                %Check if the coordinates of the minimum didnt change
                if (new_col == cur_col && new_row == cur_row)
                    %current center macroblock is best fit, break from
                    %while loop
                    break;
                else
                    %update current locs and reiterate
                    cur_row = new_row;
                    cur_col = new_col;
                    tot_searches = tot_searches + 1;
                end                
            end % While
               
            % Add in to the total MAD for the frame
            CDS_MAD(frame) = CDS_MAD(frame) + min_MAD;
            
            % record the location of the best match in the vector matrix
            CDS_vector_x(row_count,col_count,2,frame) = cur_col;
            CDS_vector_y(row_count,col_count,2,frame) = cur_row;
            
            % Store the residual difference: cur_frame - ref_frame
            % int16 is needed due to negative residual values
            best_match = ref_frame(cur_row:mb_end(cur_row), cur_col:mb_end(cur_col));
            CDS_residual(block_row:mb_end(block_row),block_col:mb_end(block_col),frame) = ...
                int16(cur_block) - int16(best_match);

            col_count = col_count+1;
        end % block_col
        row_count = row_count+1;
        col_count = 1;
    end % block_row
    
    % Get the end CPU time for the current frame and display
    CDS_CPU(frame) = cputime - CDS_CPU(frame);
    fprintf('Frame %d CPU time: %.3f seconds\n', frame, CDS_CPU(frame));
    
    % Plot the motion vectors for the frame
    x_start = CDS_vector_x(:,:,1,frame);
    x_end = CDS_vector_x(:,:,2,frame) - x_start;
    y_start = CDS_vector_y(:,:,1,frame);
    y_end = CDS_vector_y(:,:,2,frame) - y_start;
    figure();
    quiver(x_start,y_start,x_end,y_end);
    axis([0 MAXCOLS 0 MAXROWS]);
    title(['Conjugate Directions Vector for Frames ',num2str(frame-1),' to ',num2str(frame)]);
end % Frame

%% %% Print out metrics for Conjugate Directions Search %% %%
avg_searches = tot_searches/(BLOCKS_PER_ROW*BLOCKS_PER_COL*(NUM_FRAMES-1));
fprintf('\tAvg Searches     per block: %.3f\n',avg_searches);
fprintf('\tAvg Subtractions per block: %.3f\n', BLOCKSIZE.^2*avg_searches);
fprintf('\tAvg Additions    per block: %.3f\n', 2*BLOCKSIZE.^2*avg_searches);
fprintf('\tAvg Comparisions per block: %.3f\n', 4*avg_searches);
fprintf('\t   Average MAD   per block: %d\n', int32(sum(CDS_MAD(:))/(BLOCKS_PER_ROW*BLOCKS_PER_COL*(NUM_FRAMES-1))));
fprintf('\t   Average Error per pixel: %.3f\n', sum(CDS_MAD(:))/(MAXROWS*MAXCOLS*(NUM_FRAMES-1)));
fprintf('\tTotal CPU time taken: %.3f\n',sum(CDS_CPU(:)));

%%% Print out the total MAD for each frame %%% 
fprintf('\nTotal MAD per frame:\n');
for frame=2:NUM_FRAMES
    fprintf('Frame %d:\n',frame);
    fprintf('\tExhaustive Search: %d\n', ES_MAD(frame));
    fprintf('\tConj.  Directions: %d\t(%d more)\n', CDS_MAD(frame),CDS_MAD(frame)-ES_MAD(frame));
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
% Reconstruct the Video Frames                                            %
% Using the motion vector and residual matrix                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\nRestoring and Displaying Exhaustive and Conj. Directions Frames...\n');
ES_video_frames = int16(zeros(MAXROWS,MAXCOLS,NUM_FRAMES));
CDS_video_frames = int16(zeros(MAXROWS,MAXCOLS,NUM_FRAMES));
%Retrieve the first reference frame
ES_video_frames(:,:,1)  = video_frames(:,:,1,1);
CDS_video_frames(:,:,1) = video_frames(:,:,1,1);
for frame = 2:NUM_FRAMES
    % Indicies for vector matrices
    row_count = 1;
    col_count = 1;
    for block_row = 1:BLOCKSIZE:MAXROWS
        for block_col = 1:BLOCKSIZE:MAXCOLS
            
            %Exhaustive Search rebuild
            row_vector = ES_vector_y(row_count, col_count, 2, frame);
            col_vector = ES_vector_x(row_count, col_count, 2, frame);
            ES_video_frames(block_row:mb_end(block_row), block_col:mb_end(block_col), frame) = ...
                ES_video_frames(row_vector:mb_end(row_vector), col_vector:mb_end(col_vector), frame-1) + ...
                ES_residual(block_row:mb_end(block_row), block_col:mb_end(block_col), frame);
            %Conjugate Directions Search rebuild
            row_vector = CDS_vector_y(row_count, col_count, 2, frame);
            col_vector = CDS_vector_x(row_count, col_count, 2, frame);
            CDS_video_frames(block_row:mb_end(block_row), block_col:mb_end(block_col), frame) = ...
                CDS_video_frames(row_vector:mb_end(row_vector), col_vector:mb_end(col_vector), frame-1) + ...
                CDS_residual(block_row:mb_end(block_row), block_col:mb_end(block_col), frame);
            
            %Increment counter
            col_count = col_count + 1;
        end
        row_count = row_count + 1;
        col_count = 1;
    end
    figure();
    imshow(uint8(ES_video_frames(:,:,frame)));
    title(['Reconstructed Exhaustive Search Image for Frame ',num2str(frame)]); 
    figure();
    imshow(uint8(CDS_video_frames(:,:,frame)));
    title(['Reconstructed Conjugate Directions Search Image for Frame ',num2str(frame)]); 
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
% Display the Error Frames                                                %
% The error frames are equivalent to the absolute value                   %
% of the residual matrices for each frame.                                %
% - Darker areas indicate less error                                      %
% - Lighter areas indicate higher error                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for frame = 2:NUM_FRAMES
    figure();
    imshow(uint8(abs(ES_residual(:,:,frame))));
    title(['Exhaustive Search Error Img. for Frame ', num2str(frame)]);
    figure();
    imshow(uint8(abs(CDS_residual(:,:,frame))));
    title(['Conj. Directions Search Error Img. for Frame ', num2str(frame)])
end;

fprintf('DONE\n');
end % Function
 
% Function returns the endpoint for the starting loc of the macroblock
% Example, block(1:mb_end(1), 17:mb_end(17)) = block(1:16,17:32)
function ret = mb_end(start)   
    global BLOCKSIZE;
    ret = start+BLOCKSIZE-1;
end
