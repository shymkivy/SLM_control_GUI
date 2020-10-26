%% Script for getting data for calibration lut
% can either use TDLC and grab frames or wait for trigger with some other method
% start by running the 


%% Parameters
ops.use_TLDC = 0;   % otherwise wait for trigger
ops.plot_phase = 1;

ops.bit_depth = 256;    % bit depth
ops.NumRegions = 4;         % (squares only [1,4,9,16...])
ops.PixelsPerStripe = 8;  
ops.PixelValue = 0;

save_pref = '940_slm5221_maitai';

%% add paths
ops.working_dir = fileparts(which('SLM_lut_calibrationTLDC.m'));
addpath([ops.working_dir '\..\']);
addpath([ops.working_dir '\..\SLM_GUI_funcions']);

ops.time_stamp = sprintf('%s_%sh_%sm',datestr(now,'mm_dd_yy'),datestr(now,'HH'),datestr(now,'MM'));
ops.save_path = [ops.working_dir '\..\..\SLM_outputs\lut_calibration'];
ops.save_file_name = sprintf('%s\\lut_raw_%s_%dr_%s.mat',ops.save_path, save_pref,ops.NumRegions, ops.time_stamp);

%% Initialize SLM
try %#ok<*TRYNC>
    f_SLM_BNS_close(ops);
end
ops = f_SLM_default_ops(ops);
ops = f_SLM_BNS_initialize(ops);

if ops.use_TLDC
    try
        TLDC_set_Cam_Close(hdl_cam);
    end
    [cam_out, ops.cam_params] = f_TLDC_initialize(ops);
else
    % Setup counter
    session = daq.createSession('ni');
    session.addCounterInputChannel(app.NIDAQdeviceEditField.Value, 'ctr0', 'EdgeCount');
    resetCounters(session);
end

%% create gratings and upload
if ops.SDK_created == 1
    region_gray = zeros(ops.bit_depth*ops.NumRegions,2);
    
    %allocate arrays for our images
    SLM_image = libpointer('uint8Ptr', zeros(ops.width*ops.height,1));
    calllib('ImageGen', 'Generate_Solid', SLM_image, ops.width, ops.height, ops.PixelValue);
    f_SLM_BNS_update(ops, SLM_image);
	
    if ops.plot_phase
        SLM_fig = figure;
        SLM_im = imagesc(reshape(SLM_image.Value, ops.width, ops.height)');
        caxis([1 256]);
        SLM_fig.Children.Title.String = 'SLM phase';
    end
    
    if ops.use_TLDC
        calib_im_series = zeros(size(cam_out.cam_frame,1), size(cam_out.cam_frame,2), ops.bit_depth*ops.NumRegions);
        cam_fig = figure;
        cam_im = imagesc(cam_out.cam_frame');
        %caxis([1 256]);
        cam_fig.Children.Title.String = 'Camera';
    end
    
    if ~ops.use_TLDC
        frame_start_times = zeros(num_planes_all,1);
        SLM_frame = 1;
        tic;
    end
    n_idx = 1;
    %loop through each region
    for Region = 0:(ops.NumRegions-1)
        for Gray = 0:(ops.bit_depth-1)
            
            region_gray(n_idx,:) = [Region, Gray];
            n_idx = n_idx + 1;
            
            %Generate the stripe pattern and mask out current region
            calllib('ImageGen', 'Generate_Stripe', SLM_image, ops.width, ops.height, ops.PixelValue, Gray, ops.PixelsPerStripe);
            calllib('ImageGen', 'Mask_Image', SLM_image, ops.width, ops.height, Region, ops.NumRegions); % 
            
            
            if ~ops.use_TLDC
                % wait for counter
                imaging = 1;
                while imaging
                    scan_frame = inputSingleScan(session)+1;
                    if scan_frame > SLM_frame
                        f_SLM_BNS_update(ops, SLM_image);
                        frame_start_times(scan_frame) = toc;
                        SLM_frame = scan_frame;
                        if scan_frame > ops.bit_depth*ops.NumRegions
                            imaging = 0;
                        end
                    end

                    if (toc -  frame_start_times(scan_frame)) > 15
                        pause(0.0001);
                        if ~imaging_button.Value
                            imaging = 0;
                            disp(['Aborted trigger wait frame ' num2str(SLM_frame)]);
                        end
                    end
                end
            end
            
            if ops.use_TLDC   % Thorlabs camera
                f_SLM_BNS_update(ops, SLM_image);
                pause(0.01); %let the SLM settle for 10 ms
                TLDC_get_Cam_Im(cam_out.hdl_cam);
                cam_im.CData = cam_out.cam_frame';
                calib_im_series(:,:,n_idx) = mean(double(cam_out.cam_frame),3);
                cam_fig.Children.Title.String = sprintf('Gray %d/%d; Region %d/%d', Gray+1,ops.bit_depth,Region+1,ops.NumRegions);
                pause(.2);
            end
            
            if ops.plot_phase
                SLM_im.CData = reshape(SLM_image.Value, ops.width, ops.height)';
                SLM_fig.Children.Title.String = sprintf('Gray %d/%d; Region %d/%d', Gray+1,ops.bit_depth,Region+1,ops.NumRegions);
                drawnow;
                %figure; imagesc(reshape(SLM_image.Value, ops.width, ops.height)')
            end
        end
    end
    calllib('ImageGen', 'Generate_Solid', SLM_image, ops.width, ops.height, ops.PixelValue);
    f_SLM_BNS_update(ops, SLM_image);
    
    save(save_file_name, 'region_gray', 'ops', '-v7.3')
end

%% close SLM
try 
    f_SLM_BNS_close(ops);
end
if ops.use_TLDC
    TLDC_set_Cam_Close(cam_out.hdl_cam);            
end

