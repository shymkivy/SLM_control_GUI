%% Script for getting data for calibration lut
%% Try closing thing from past

try
    [~] = f_SLM_close_YS(ops);
catch
end
try
    TLDC_set_Cam_Close(hdl_cam);
catch
end


%% Parameters
NumDataPoints = 256;    % bit depth
NumRegions = 1;         % field has to be divisible by the number of regions
PixelsPerStripe = 8;    


addpath('C:\Users\ys2605\Desktop\SLM stuff\Prairie_2_scratch');
save_file_name = sprintf('calibraton_data_%s_%sh_%sm',datestr(now,'mm_dd_yy'),datestr(now,'HH'),datestr(now,'MM'));

%% Initialize SLM

ops = f_SLM_initialize_ops_YS();
ops = f_SLM_initialize_YS(ops);

%% Set up the camera
% Camera parameters
cam_params.GammaCal_Camera='Thorlabs';
cam_params.GammaCal_CameraExposeTime=0.2;

% Thorlabs Camera 1024x1280 pixels
cam_params.TLCAM_exptm       = 50;%40;       % exposure time in milliseconds (max~ 1/frame rate)
cam_params.TLCAM_fps         = 19.78;    % frames per second
cam_params.TLCAM_pxlclock    = 34;       % pixel clock in MHz (5-43MHz)
% select pixels
cam_params.TLCAM_win_start_M       = 0;  % beginning with 2, then steps in intervals of 2;  456
cam_params.TLCAM_win_start_N       = 0;  % beginning with 4, then steps in intervals of 4;  156
cam_params.TLCAM_win_Width   = 1280;%640;      % 32-1280, intervals of 4
cam_params.TLCAM_win_Height  = 1024;%640;      % 4-1024, intervals of 2
cam_params.TLCAM_gain        = 1;        % gain factor varying from 1 to 100
cam_params.path_TLCAM_MEX = 'C:\Users\ys2605\Desktop\SLM stuff\Prairie_2_scratch\MEX';
addpath('C:\Users\ys2605\Desktop\SLM stuff\Prairie_2_scratch\MEX');

if strcmp(cam_params.GammaCal_Camera, 'Thorlabs')
    
    [hdl_cam, cam_im, act] = f_TLDC_Cam_Init_YS(cam_params); 
    TLDC_get_Cam_Im(hdl_cam);
    %calib_im_series = zeros( size(cam_im,1), size(cam_im,2), GRATvnum );
    %tmp_im = zeros( size(cam_im,1), size(cam_im,2), 1 );
end

% figure;
% h = imagesc();
% xlim([1 cam_params.TLCAM_win_Width]);
% ylim([1 cam_params.TLCAM_win_Height]);
% n_frames = 500;
% times_T = zeros(n_frames,1);
% tic
% for ii = 1:n_frames
%     TLDC_get_Cam_Im(hdl_cam);
%     h.CData = cam_im';
%     drawnow;
%     times_T(ii) = toc;
% end
% 
% figure; plot(diff(times_T))

%% create gratings and upload
if ops.SDK_created == 1
    
    if strcmp(cam_params.GammaCal_Camera, 'Thorlabs')
        calib_im_series = zeros(size(cam_im,1), size(cam_im,2), NumDataPoints);
    end
    
    %allocate arrays for our images
    SLM_image = libpointer('uint8Ptr', zeros(ops.width*ops.height,1));
    
    % Create an array to hold measurements from the analog input (AI) board
    AI_Intensities = zeros(NumDataPoints,2);
    
    % Generate a blank wavefront correction image, you should load your
    % custom wavefront correction that was shipped with your SLM.
    PixelValue = 0;
    calllib('ImageGen', 'Generate_Solid', SLM_image, ops.width, ops.height, PixelValue);
    
    f_SLM_update_YS(ops, SLM_image);
	
    figure;
    SLM_image_plot = imagesc(reshape(SLM_image.Value, ops.width, ops.height)');
    caxis([1 256]);
    title('SLM phase');
    
    figure;
    Cam_image_plot = imagesc(cam_im');
    %caxis([1 256]);
    title('Camera');
    
    %loop through each region
    for Region = 0:(NumRegions-1)
      
        %AI_Index = 1;
        %loop through each graylevel
        for Gray = 0:(NumDataPoints-1)
            %Generate the stripe pattern and mask out current region
            calllib('ImageGen', 'Generate_Stripe', SLM_image, ops.width, ops.height, PixelValue, Gray, PixelsPerStripe);
            calllib('ImageGen', 'Mask_Image', SLM_image, ops.width, ops.height, Region, NumRegions);
            
            %write the image
            f_SLM_update_YS(ops, SLM_image);
            SLM_image_plot.CData = reshape(SLM_image.Value, ops.width, ops.height)';
            
            %let the SLM settle for 10 ms
            pause(0.01);
            
            if strcmp(cam_params.GammaCal_Camera, 'Thorlabs')   % Thorlabs camera
                TLDC_get_Cam_Im(hdl_cam);
                Cam_image_plot.CData = cam_im';
                calib_im_series(:,:,Gray+1) = mean(double(cam_im),3);
                title(sprintf('Gray %d/%d; Region %d/%d', Gray+1,NumDataPoints,Region+1,NumRegions));
            end 
            drawnow;
            pause(cam_params.GammaCal_CameraExposeTime);
            
            
            
            %YOU FILL IN HERE...FIRST: read from your specific AI board, note it might help to clean up noise to average several readings
            %SECOND: store the measurement in your AI_Intensities array
            %AI_Intensities(AI_Index, 1) = Gray; %This is the varable graylevel you wrote to collect this data point
            %AI_Intensities(AI_Index, 2) = 0; % HERE YOU NEED TO REPLACE 0 with YOUR MEASURED VALUE FROM YOUR ANALOG INPUT BOARD
 
            %AI_Index = AI_Index + 1;
        
        end
        
        % extrac intensities
        
        figure;
        
        
        % dump the AI measurements to a csv file
        %filename = ['Raw' num2str(Region) '.csv'];
        %csvwrite(filename, AI_Intensities);  
    end
    
    %save(save_file_name, 'calib_im_series', 'NumDataPoints', 'NumRegions', 'PixelsPerStripe', 'cam_params', 'ops', '-v7.3')
    
end


%% close SLM
ops = f_SLM_close_YS(ops);


%% Close the camera 
if strcmp(cam_params.GammaCal_Camera, 'Thorlabs')       % Thorlabs camera
% close the camera handle
    TLDC_set_Cam_Close(hdl_cam);            
end
