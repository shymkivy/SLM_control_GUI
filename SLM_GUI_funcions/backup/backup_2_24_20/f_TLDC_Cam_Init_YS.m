function [ hdl_cam, cam_im, act ] = f_TLDC_Cam_Init_YS(cam_params)
    %% parameters
    addpath(cam_params.path_TLCAM_MEX);
    
    TLCAM_exptm = cam_params.TLCAM_exptm;           % exposure time in milliseconds
    TLCAM_fps = cam_params.TLCAM_fps;               % frames per second
    TLCAM_pxlclock = cam_params.TLCAM_pxlclock;     % pixel clock in MHz
    TLCAM_win_start_M= cam_params.TLCAM_win_start_M;            % beginning with 2, then steps in intervals of 2;  456
    TLCAM_win_start_N = cam_params.TLCAM_win_start_N;           % beginning with 4, then steps in intervals of 4;  156
    TLCAM_win_Width = cam_params.TLCAM_win_Width;   % 32-1280, intervals of 4
    TLCAM_win_Height = cam_params.TLCAM_win_Height; % 4-1024, intervals of 2
    
    
    %% mex commands to initialize the camera
    [hdl_cam, im_add] = TLDC_set_Cam_Open(TLCAM_win_start_M,TLCAM_win_start_N,TLCAM_win_Width,TLCAM_win_Height);
    % set the pixel clock speed in MHz
    TLDC_set_Cam_PixClock(hdl_cam,TLCAM_pxlclock);
    % collect the associated range of acceptable frame times
    % and assign a frame rate accordingly
    [t1, t2, ~] = TLDC_get_Cam_FrameRate(hdl_cam);
    if ( (TLCAM_fps >= 1/t2) && (TLCAM_fps <= 1/t1) )
        [act.CAM_fps] = TLDC_set_Cam_FrameRate(hdl_cam,TLCAM_fps);
    elseif (TLCAM_fps < 1/t2)
        TLCAM_fps = 1/t2;
        [act.CAM_fps] = TLDC_set_Cam_FrameRate(hdl_cam,TLCAM_fps);
    elseif (TLCAM_fps > 1/t1)
        TLCAM_fps = 1/t1;
        [act.CAM_fps] = TLDC_set_Cam_FrameRate(hdl_cam,TLCAM_fps);
    end
    % assign the exposure time according to the valid range
    [t1, t2, ~] = TLDC_get_Cam_ExpTime(hdl_cam);
    if ( TLCAM_exptm >= t2 )
        [act.CAM_exptm] = TLDC_set_Cam_ExpTime(hdl_cam,t2);
    elseif ( TLCAM_exptm <= t1 )
        [act.CAM_exptm] = TLDC_set_Cam_ExpTime(hdl_cam,t1);
    else
        [act.CAM_exptm] = TLDC_set_Cam_ExpTime(hdl_cam,TLCAM_exptm);
    end
    cam_im = im_add.image;
    % assign the desired gain
    %TLDC_set_Cam_Gain(hdl_cam,usr.CAM_gain);   
end