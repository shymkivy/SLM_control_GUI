%% Script for getting data for calibration lut
% can either use TDLC and grab frames or wait for trigger with some other method
% start by running the 


%% Parameters
use_TLDC = 1;   % otherwise wait for trigger

bit_depth = 256;    % bit depth
NumRegions = 4;         % (squares only [1,4,9,16...])
PixelsPerStripe = 8;    
save_raw_stack = 0;

save_pref = '940_slm5221_maitai_4r';

%% Try closing thing from past
try %#ok<*TRYNC>
    [~] = f_SLM_BNS_close(ops);
end
if use_TLDC
    try
        TLDC_set_Cam_Close(hdl_cam);
    end
end

%% add paths
ops.working_dir = fileparts(which('SLM_lut_calibrationTLDC.m'));
addpath([ops.working_dir '\..\']);
addpath([ops.working_dir '\..\SLM_GUI_funcions']);
time_stamp = sprintf('%s_%sh_%sm',datestr(now,'mm_dd_yy'),datestr(now,'HH'),datestr(now,'MM'));
save_path = [ops.working_dir '\..\..\SLM_outputs\lut_calibration'];
save_csv_path = [save_path '\lut_raw' save_pref time_stamp '\'];
mkdir(save_csv_path);

%% Initialize SLM
ops = f_SLM_default_ops(ops);
ops = f_SLM_BNS_initialize(ops);

if use_TLDC
    [cam_out, cam_params] = f_TLDC_initialize(ops);
end

%% create gratings and upload
if ops.SDK_created == 1
    
    if use_TLDC
        [cam_d1, cam_d2] = size(cam_out.cam_frame);
        calib_im_series = zeros(cam_d1, cam_d2, bit_depth);
    end
    
    %allocate arrays for our images
    SLM_image = libpointer('uint8Ptr', zeros(ops.width*ops.height,1));
    
    % Create an array to hold measurements from the analog input (AI) board
    AI_Intensities = zeros(bit_depth,3);
    
    % Generate a blank wavefront correction image, you should load your
    % custom wavefront correction that was shipped with your SLM.
    PixelValue = 0;
    calllib('ImageGen', 'Generate_Solid', SLM_image, ops.width, ops.height, PixelValue);
    
    f_SLM_BNS_update(ops, SLM_image);
	
    SLM_fig = figure;
    SLM_im = imagesc(reshape(SLM_image.Value, ops.width, ops.height)');
    caxis([1 256]);
    title('SLM phase');
    
    if use_TLDC
        cam_fig = figure;
        cam_im = imagesc(cam_out.cam_frame');
        %caxis([1 256]);
        title('Camera');
    end
    
    AI_stack = cell(NumRegions,1);
    AI_sq_stack = cell(NumRegions,1);
    if save_raw_stack
        calib_im_stack = cell(NumRegions,1);
        coord_stack = cell(NumRegions,1);
    end
    
    %loop through each region
    for Region = 0:(NumRegions-1)
        for Gray = 0:(bit_depth-1)
            %Generate the stripe pattern and mask out current region
            calllib('ImageGen', 'Generate_Stripe', SLM_image, ops.width, ops.height, PixelValue, Gray, PixelsPerStripe);
            calllib('ImageGen', 'Mask_Image', SLM_image, ops.width, ops.height, Region, NumRegions); % 
            
            %write the image
            f_SLM_BNS_update(ops, SLM_image);
            SLM_im.CData = reshape(SLM_image.Value, ops.width, ops.height)';
            %figure; imagesc(reshape(SLM_image.Value, ops.width, ops.height)')
           
            %let the SLM settle for 10 ms
            pause(0.01);
            
            if use_TLDC   % Thorlabs camera
                TLDC_get_Cam_Im(cam_out.hdl_cam);
                cam_im.CData = cam_out.cam_frame';
                calib_im_series(:,:,Gray+1) = mean(double(cam_out.cam_frame),3);
                title(cam_im, sprintf('Gray %d/%d; Region %d/%d', Gray+1,bit_depth,Region+1,NumRegions));
            end 
            drawnow;
            pause(.2);

            %YOU FILL IN HERE...FIRST: read from your specific AI board, note it might help to clean up noise to average several readings
            %SECOND: store the measurement in your AI_Intensities array
            %AI_Intensities(AI_Index, 1) = Gray; %This is the varable graylevel you wrote to collect this data point
            %AI_Intensities(AI_Index, 2) = 0; % HERE YOU NEED TO REPLACE 0 with YOUR MEASURED VALUE FROM YOUR ANALOG INPUT BOARD
            %AI_Index = AI_Index + 1;
        end
        
        % extrac intensities
        
        figure;
        plot_int = floor(size(calib_im_series,3)/6);
        for n_plot = 1:6
            interval = (plot_int*(n_plot-1)+1):(plot_int*n_plot);
            subplot(2,3,n_plot);
            imagesc(mean(calib_im_series(:,:,interval),3)');axis image;
            title(sprintf('Gray pix %d-%d', interval(1), interval(end)));
        end
        
        figure;
        imagesc(mean(calib_im_series,3)');axis image;
        title('Select the zero point');
        pt_zero_ord = ginput(1);
        title('Select the first order point');
        pt_first_ord = ginput(1);
        
        
        pt_zero_ord = round(pt_zero_ord);
        pt_first_ord = round(pt_first_ord);
        
        ds = 35;
        figure;
        subplot(1,2,1);
        zero_ord_im = calib_im_series(round((pt_zero_ord(1)-ds):(pt_zero_ord(1)+ds)), round((pt_zero_ord(2)-ds):(pt_zero_ord(2)+ds)),:);
        imagesc(mean(zero_ord_im,3)');axis image;
        title('Zero order point');
        subplot(1,2,2);
        first_ord_im = calib_im_series(round((pt_first_ord(1)-ds):(pt_first_ord(1)+ds)), round((pt_first_ord(2)-ds):(pt_first_ord(2)+ds)),:);
        imagesc(mean(first_ord_im,3)');axis image;
        title('First order point');
        
        AI_Intensities(:, 1) = 1:size(calib_im_series,3);
        AI_Intensities(:, 2) = mean(mean(zero_ord_im,1),2);
        AI_Intensities(:, 3) = mean(mean(first_ord_im,1),2);
        
        
        
        figure; plot(AI_Intensities(:,2)); hold on; plot(AI_Intensities(:,3));
        legend('Zero ord', 'First ord');
        title('intensities vs gray')

        % dump the AI measurements to a csv file
        
        fold_dir = [save_csv_path 'zero_ord\'];
        if ~exist(fold_dir, 'dir'); mkdir(fold_dir); end
        csvwrite([fold_dir  'raw' num2str(Region) '.csv'], [AI_Intensities(:, 1) AI_Intensities(:, 2)]);
        
        fold_dir = [save_csv_path 'first_ord\'];
        if ~exist(fold_dir, 'dir'); mkdir(fold_dir); end
        csvwrite([fold_dir  'raw' num2str(Region) '.csv'], [AI_Intensities(:, 1) AI_Intensities(:, 3)]);
        
        AI_stack{Region+1} = AI_Intensities;
        if save_raw_stack
            calib_im_stack{Region+1} = calib_im_series;
            coord_stack{Region+1} = [pt_zero_ord; pt_first_ord];
        end
    end
    save_file_name = [save_path '\' 'lut_raw_' save_pref time_stamp '.mat'];
    save(save_file_name, 'AI_stack', 'NumDataPoints', 'NumRegions', 'PixelsPerStripe', 'cam_params', 'ops', 'save_raw_stack', '-v7.3')
    if save_raw_stack
        save(save_file_name, 'calib_im_stack', 'coord_stack', '-append')
    end
    
    calllib('ImageGen', 'Generate_Solid', SLM_image, ops.width, ops.height, PixelValue);
    f_SLM_BNS_update(ops, SLM_image);
end


%% close SLM
ops = f_SLM_BNS_close(ops);


%% Close the camera 
if strcmp(cam_params.GammaCal_Camera, 'Thorlabs')       % Thorlabs camera
% close the camera handle
    TLDC_set_Cam_Close(cam_out.hdl_cam);            
end
