%% Script for getting data for calibration lut
% can either use TDLC and grab frames or wait for trigger with some other method
% start by running the global calibration
% if need regional, use previos global for blaze deflect blank

% lut pipeline step 1/3

%% Parameters
ops.use_TLDC = 0;           % otherwise wait for trigger
ops.use_photodiode = 1;
ops.plot_phase = 1;

ops.NumGray = 256;          % bit depth
ops.NumRegions = 64;        % (squares only [1,4,9,16...])
%16R 940nm p120
ops.PixelsPerStripe = 4;	
ops.PixelValue = 0;

ops.global_lut_fname = 'photodiode_lut_comb_1064L_940R_64r_11_12_20_from_linear.txt'; %;linear.lut
%ops.lut_fname = 'slm5221_at940_fo_1r_11_5_20.lut'; %'linear.lut';
%ops.lut_fname = 'slm5221_at1064_fo_1r_11_5_20.lut'; %'linear.lut';

slm_roi = 'left_half'; % 'full' 'left_half'(1064) 'right_half'(940)

%%
%save_pref = '940_slm5221_maitai';
save_pref = '1064_slm5221_fianium';
%%
blaze_deflect_blank = 0;
blaze_period = 20;
blaze_increaseing = 1;
blaze_horizontal = 0;
blaze_reverse_dir = 1;
bkg_lut_correction = 'computed_lut_940_slm5221_maitai_1r_11_05_20_15h_19m_fo.mat';

%% add paths
ops.working_dir = fileparts(which('SLM_lut_calibrationTLDC.m'));
addpath([ops.working_dir '\..\']);
addpath([ops.working_dir '\..\SLM_GUI_funcions\BNS']);

ops.time_stamp = sprintf('%s_%sh_%sm',datestr(now,'mm_dd_yy'),datestr(now,'HH'),datestr(now,'MM'));
ops.save_path = [ops.working_dir '\..\..\SLM_outputs\lut_calibration'];
ops.save_file_name = sprintf('lut_%s_%dr_%s.mat', save_pref,ops.NumRegions, ops.time_stamp);
if ~exist(ops.save_path, 'dir')
    mkdir(ops.save_path);
end

%%
if blaze_deflect_blank
    lut_path = [ops.working_dir '\lut_calibration\linear_correction\' bkg_lut_correction];
    lut_load = load(lut_path);
    LUT_correction = lut_load.LUT_correction;
    LUT_correction = round(LUT_correction);
end

%%
regions = (1:ops.NumRegions)-1;

if numel(regions) > 1
    if strcmpi(slm_roi, 'full')
        regions_run = regions;
    elseif strcmpi(slm_roi, 'left_half')
        [rows, cols] = ind2sub([sqrt(numel(regions)) sqrt(numel(regions))], 1:numel(regions));
        ind1 = sub2ind([sqrt(numel(regions)) sqrt(numel(regions))], cols(cols<=(max(cols)/2)), rows(cols<=(max(cols)/2)));
        regions_run = sort(regions(ind1));
    elseif strcmpi(slm_roi, 'right_half')
        [rows, cols] = ind2sub([sqrt(numel(regions)) sqrt(numel(regions))], 1:numel(regions));
        ind1 = sub2ind([sqrt(numel(regions)) sqrt(numel(regions))], cols(cols>(max(cols)/2)), rows(cols<=(max(cols)/2)));
        regions_run = sort(regions(ind1));
    end
else
    regions_run = regions;
end

%% Initialize SLM
try %#ok<*TRYNC>
    f_SLM_BNS_close(ops);
end
ops = f_SLM_BNS_initialize(ops);

%%
cont1 = input('Turn laser on and reply [y] to continue:', 's');

%%
if ops.use_TLDC
    try
        TLDC_set_Cam_Close(cam_out.hdl_cam);
    end
    [cam_out, ops.cam_params] = f_TLDC_initialize(ops);
end

if ops.use_photodiode
    % Setup counter
    session = daq.createSession('ni');
%     session.addCounterInputChannel('dev2', 'ctr0', 'EdgeCount');
%     resetCounters(session);
    
    session.addAnalogInputChannel('dev2','ai1','Voltage');
    % make the data acquisition 'SingleEnded, to separate the '
    for nchan = 1:length(session.Channels)
        if strcmpi(session.Channels(nchan).ID(1:2), 'ai')
            session.Channels(nchan).TerminalConfig = 'SingleEnded';
            session.Channels(nchan).Range = [-10 10];
        end
    end
    ops.DAQ_rate = 1000;
    session.Rate = ops.DAQ_rate;
    ops.DAQ_num_sessions = 200;
    session.NumberOfScans = ops.DAQ_num_sessions;
end


%% create gratings and upload
if ops.SDK_created == 1 && strcmpi(cont1, 'y')
    region_gray = zeros(ops.NumGray*numel(regions_run),2);
    
    %allocate arrays for our images
    SLM_image = libpointer('uint8Ptr', zeros(ops.width*ops.height,1));
    calllib('ImageGen', 'Generate_Solid', SLM_image, ops.width, ops.height, ops.PixelValue);
    f_SLM_BNS_update(ops, SLM_image);
    
    SLM_mask = libpointer('uint8Ptr', zeros(ops.width*ops.height,1));
    calllib('ImageGen', 'Generate_Solid', SLM_mask, ops.width, ops.height, 1);
	
    if ops.plot_phase
        SLM_fig = figure;
        SLM_im = imagesc(reshape(SLM_image.Value, ops.width, ops.height)');
        caxis([0 255]);
        SLM_fig.Children.Title.String = 'SLM phase';
    end
    
    if ops.use_TLDC
        calib_im_series = zeros(size(cam_out.cam_frame,1), size(cam_out.cam_frame,2), ops.NumGray*numel(regions_run), 'uint8');
        cam_fig = figure;
        cam_im = imagesc(cam_out.cam_frame');
        %caxis([1 256]);
        cam_fig.Children.Title.String = 'Camera';
    end
    
    if ops.use_photodiode
        AI_intensity = zeros(ops.NumGray*numel(regions_run), 1);
        phd_fig = figure;
        phd_plot = plot(1,1); axis tight;
        %caxis([1 256]);
        phd_fig.Children.Title.String = 'Photodiode';
    end
    
    if blaze_deflect_blank
        pointer_bkg = libpointer('uint8Ptr', zeros(ops.width*ops.height,1));
        calllib('ImageGen', 'Generate_Grating',...
                pointer_bkg,...
                ops.width, ops.height,...
                blaze_period,...
                blaze_increaseing,...
                blaze_horizontal);
        
        pointer_bkg.Value = LUT_correction(pointer_bkg.Value+1,2);
        if blaze_reverse_dir
            pointer_bkg.Value = max(pointer_bkg.Value) - pointer_bkg.Value;
        end
    end
    
    n_idx = 1;
    %loop through each region
    for Region = regions_run
        for Gray = 0:(ops.NumGray-1)
            
            region_gray(n_idx,:) = [Region, Gray];

            %Generate the stripe pattern and mask out current region
            calllib('ImageGen', 'Generate_Stripe', SLM_image, ops.width, ops.height, ops.PixelValue, Gray, ops.PixelsPerStripe);
            calllib('ImageGen', 'Mask_Image', SLM_image, ops.width, ops.height, Region, ops.NumRegions); % 
            
            % update mask
            calllib('ImageGen', 'Generate_Solid', SLM_mask, ops.width, ops.height, 1);
            calllib('ImageGen', 'Mask_Image', SLM_mask, ops.width, ops.height, Region, ops.NumRegions); % 
            
            if blaze_deflect_blank
                SLM_image.Value(~logical(SLM_mask.Value)) = pointer_bkg.Value(~logical(SLM_mask.Value));
            end
            
            if ops.use_photodiode
                f_SLM_BNS_update(ops, SLM_image);
                pause(0.01); %let the SLM settle for 10 ms
                % scan intensity
                data = startForeground(session);
                AI_intensity(n_idx) = mean(data);
                phd_plot.XData = region_gray(1:n_idx,2);
                phd_plot.YData = AI_intensity(1:n_idx);
                phd_fig.Children.Title.String = sprintf('Gray %d/%d; Region %d/%d', Gray+1,ops.NumGray,Region+1,ops.NumRegions);
            end
            
            if ops.use_TLDC   % Thorlabs camera
                f_SLM_BNS_update(ops, SLM_image);
                pause(0.01); %let the SLM settle for 10 ms
                TLDC_get_Cam_Im(cam_out.hdl_cam);
                cam_im.CData = cam_out.cam_frame';
                calib_im_series(:,:,n_idx) = (cam_out.cam_frame);
                cam_fig.Children.Title.String = sprintf('Gray %d/%d; Region %d/%d', Gray+1,ops.NumGray,Region+1,ops.NumRegions);
                pause(.02);
            end
            
            if ops.plot_phase
                SLM_im.CData = reshape(SLM_image.Value, ops.width, ops.height)';
                SLM_fig.Children.Title.String = sprintf('Gray %d/%d; Region %d/%d', Gray+1,ops.NumGray,Region+1,ops.NumRegions);
                drawnow;
                %figure; imagesc(reshape(SLM_image.Value, ops.width, ops.height)')
            end
            
            n_idx = n_idx + 1;
        end
    end
    calllib('ImageGen', 'Generate_Solid', SLM_image, ops.width, ops.height, ops.PixelValue);
    f_SLM_BNS_update(ops, SLM_image);
    
    if ops.use_photodiode
        save([ops.save_path '\photodiode_' ops.save_file_name], 'region_gray', 'AI_intensity', 'ops', '-v7.3');
        new_dir1 = [ops.save_path '\photodiode_' ops.save_file_name(1:end-4)];
        % dump the AI measurements to a csv file
        mkdir(new_dir1);
        for Region = regions_run
            r_idx = region_gray(:,1) == Region;
            filename = ['Raw' num2str(Region) '.csv'];
            csvwrite([new_dir1 '\' filename], [region_gray(r_idx,2), AI_intensity(r_idx)]);  
        end
    end
    if ops.use_TLDC
        save([ops.save_path '\TDLC_' ops.save_file_name], 'region_gray', 'calib_im_series', 'ops', '-v7.3');
    end
end

%% close SLM

cont1 = input('Done, turnb off laser and press [y] close SLM:', 's');

try 
    f_SLM_BNS_close(ops);
end
if ops.use_TLDC
    TLDC_set_Cam_Close(cam_out.hdl_cam);            
end

