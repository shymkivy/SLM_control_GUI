function [cam_out, cam_params] = f_TLDC_initialize(ops)
% Set up the camera

cam_params.path_TLCAM_MEX = [ops.working_dir '\..\MEX'];
addpath(cam_params.path_TLCAM_MEX);

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

if strcmp(cam_params.GammaCal_Camera, 'Thorlabs')
    
    [cam_out.hdl_cam, cam_out.cam_frame, cam_out.act] = f_TLDC_Cam_Init_YS(cam_params); 
    TLDC_get_Cam_Im(cam_out.hdl_cam);
    %calib_im_series = zeros( size(cam_im,1), size(cam_im,2), GRATvnum );
    %tmp_im = zeros( size(cam_im,1), size(cam_im,2), 1 );
end

end