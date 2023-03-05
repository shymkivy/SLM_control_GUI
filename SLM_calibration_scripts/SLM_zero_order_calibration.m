%% Script for getting data for calibration lut
% can either use TDLC and grab frames or wait for trigger with some other method
% start by running the global calibration
% if need regional, use previos global for blaze deflect blank
% for better calibration, especially regional better to use photodiode and
% first order, not zero

% lut pipeline step 1/3

%%
try %#ok<*TRYNC>
    f_SLM_close(ops);
end
try 
    TLDC_set_Cam_Close(cam_out.hdl_cam);            
end

clear;

%% initialize params
script_dir = fileparts(mfilename('fullpath'));
ops = f_SLM_default_ops([script_dir '\\..']);

addpath(genpath(script_dir));
addpath(genpath([ops.GUI_dir '\..\SLM_GUI_funcions']));

%%
ops.SLM_type = 'BNS1920'; % 'BNS1920', 'BNS512', 'BNS512OD'

SLM_params = ops.SLM_params(strcmpi({ops.SLM_params.SLM_name}, ops.SLM_type));
ops = f_copy_fields(ops, SLM_params);

%% Parameters
ops.use_TLDC = 0;           % otherwise wait for trigger
ops.use_photodiode = 0;
ops.plot_phase = 1;

ops.NumGray = 256;          % bit depth

% to use meadolwark analysis need 8x8, to use their mask need equal m and n
ops.num_regions_m = 1;% 4 8;
ops.num_regions_n = 1;% 8 16;

ops.BlazePeriod = 20;
ops.BlazeIncreasing = true;
ops.BlazeHorizontal = true;

ops.DAQ_num_sessions = 200;

%%
slm_roi = 'right_half'; % 'full' 'left_half'(1064) 'right_half'(940)

save_pref = '940_maitai';
%save_pref = '1064_Fianium_maitai_corr2';
%save_pref = '1064_slm5221_fianium';

ops.NumRegions = ops.num_regions_m  * ops.num_regions_n;

%% other
ops.time_stamp = sprintf('%s_%sh_%sm',datestr(now,'mm_dd_yy'),datestr(now,'HH'),datestr(now,'MM'));
ops.save_file_name = sprintf('lut_%s_%dr_%s.mat', save_pref,ops.NumRegions, ops.time_stamp);
if ~exist(ops.save_lut_dir, 'dir')
    mkdir(ops.save_lut_dir);
end

%%
regions_run = f_lut_get_regions_run2(slm_roi, ops.num_regions_m, ops.num_regions_n);
regions_run = sort(regions_run(:));

%% Initialize SLM
ops = f_SLM_initialize(ops);
ops = f_SLM_BNS_load_imagegen(ops);
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
    session = daq('ni');
%     session.addCounterInputChannel('dev2', 'ctr0', 'EdgeCount');
%     resetCounters(session);
    
    % last time differential setting worked well, with diff switch on on
    % the daq as well. single ended on both stopped working for some reason
    session.addinput('dev2','ai1','Voltage');
    % make the data acquisition 'SingleEnded, to separate the '
%     for nchan = 1:length(session.Channels)
%         if strcmpi(session.Channels(nchan).ID(1:2), 'ai')
%             session.Channels(nchan).TerminalConfig = 'SingleEnded';
%             session.Channels(nchan).Range = [-10 10];
%         end
%     end
    ops.DAQ_rate = 1000;
    session.Rate = ops.DAQ_rate;
    %session.NumberOfScans = ops.DAQ_num_sessions;
end


%% create gratings and upload
if ops.SDK_created == 1 && strcmpi(cont1, 'y')
    region_gray = zeros(ops.NumGray*numel(regions_run),2);
    
    SLM_blank = libpointer('uint8Ptr', zeros(ops.width*ops.height,1));
    %calllib('ImageGen', 'Generate_Solid', SLM_blank, ops.width, ops.height, ops.PixelValue);
    f_SLM_update(ops, SLM_blank);
    
    SLM_mask = libpointer('uint8Ptr', zeros(ops.width*ops.height,1));
    %calllib('ImageGen', 'Generate_Solid', SLM_mask, ops.width, ops.height, 1);
    
    %% generate SLM image
    
    blazed = libpointer('uint8Ptr', zeros(ops.width*ops.height,1));
    calllib('ImageGen', 'Generate_Grating',...
                blazed,...
                ops.width, ops.height,...
                ops.BlazePeriod,...
                ops.BlazeIncreasing,...
                ops.BlazeHorizontal);
    
    region_idx = f_gen_region_index_mask(ops.height, ops.width, ops.num_regions_m, ops.num_regions_n);
    %ops.region_idx = region_idx;
    %%
    if ops.plot_phase
        SLM_fig = figure;
        SLM_im = imagesc(reshape(blazed.Value, ops.width, ops.height)'); axis equal tight;
        caxis([0 255]);
        SLM_fig.Children.Title.String = 'SLM phase';
    end
    
    if ops.use_TLDC
        calib_im_series = zeros(size(cam_out.cam_frame,1), size(cam_out.cam_frame,2), ops.NumGray*numel(regions_run), 'uint8');
        cam_fig = figure;
        cam_im = imagesc(cam_out.cam_frame'); axis equal tight;
        %caxis([1 256]);
        cam_fig.Children.Title.String = 'Camera';
    end
    
    if ops.use_photodiode
        AI_intensity = zeros(ops.NumGray*numel(regions_run), 1);
        phd_fig = figure;
        x1 = ones(ops.NumGray, numel(regions_run))*255;
        y1 = zeros(ops.NumGray, numel(regions_run));
        phd_plot = plot(x1,y1); axis tight;
        %caxis([1 256]);
        phd_fig.Children.Title.String = 'Photodiode';
    end
    
    %loop through each region
    for n_reg = 1:numel(regions_run)
        for Gray = 0:(ops.NumGray-1)
            Region = regions_run(n_reg);
            idx1 = (n_reg-1)*ops.NumGray+Gray + 1;
            
            region_gray(idx1,:) = [Region, Gray];
            
            region_mask = zeros(ops.height, ops.width);
            region_mask(region_idx == Region) = 1;
            region_mask = flipud(region_mask);
            holo_image = stripes.*region_mask*Gray;

            holo_image_corr = f_apply_lut_corr(holo_image, lut_data);
            SLM_mask.Value = reshape(rot90(uint8(holo_image_corr), 3),[],1);

            %Generate the stripe pattern and mask out current region
            %calllib('ImageGen', 'Generate_Stripe', SLM_blank, ops.width, ops.height, ops.PixelValue, Gray, ops.PixelsPerStripe);
            %calllib('ImageGen', 'Mask_Image', SLM_blank, ops.width, ops.height, Region, ops.NumRegions); % 
            
            % update mask
            %calllib('ImageGen', 'Generate_Solid', SLM_mask, ops.width, ops.height, 1);
            %calllib('ImageGen', 'Mask_Image', SLM_mask, ops.width, ops.height, Region, ops.NumRegions); % 
            
            if ops.use_photodiode
                f_SLM_update(ops, SLM_mask);
                pause(0.01); %let the SLM settle for 10 ms
                % scan intensity
                %data = startForeground(session);
                data = read(session,ops.DAQ_num_sessions,"OutputFormat","Matrix");
                AI_intensity(idx1) = mean(data);
                phd_plot(n_reg).XData(Gray+1) = region_gray(idx1,2); 
                phd_plot(n_reg).YData(Gray+1) = AI_intensity(idx1);
                phd_fig.Children.Title.String = sprintf('Gray %d/%d; Region %d/%d', Gray+1,ops.NumGray,Region+1,ops.NumRegions);
            end
            
            if ops.use_TLDC   % Thorlabs camera
                f_SLM_update(ops, SLM_mask);
                pause(0.01); %let the SLM settle for 10 ms
                TLDC_get_Cam_Im(cam_out.hdl_cam);
                cam_im.CData = cam_out.cam_frame';
                calib_im_series(:,:,idx1) = (cam_out.cam_frame);
                cam_fig.Children.Title.String = sprintf('Gray %d/%d; Region %d/%d', Gray+1,ops.NumGray,Region+1,ops.NumRegions);
                pause(.02);
            end
            
            if ops.plot_phase
                SLM_im.CData = reshape(SLM_mask.Value, ops.width, ops.height)';
                SLM_fig.Children.Title.String = sprintf('Gray %d/%d; Region %d/%d', Gray+1,ops.NumGray,Region+1,ops.NumRegions);
                drawnow;
                %figure; imagesc(reshape(SLM_image.Value, ops.width, ops.height)')
            end
        end
    end
    f_SLM_update(ops, SLM_blank);
    
    if ops.use_photodiode
        save([ops.ops.save_lut_dir '\photodiode_' ops.save_file_name], 'region_gray', 'AI_intensity', 'ops', '-v7.3');
        new_dir1 = [ops.ops.save_lut_dir '\photodiode_' ops.save_file_name(1:end-4)];
        % dump the AI measurements to a csv file
        mkdir(new_dir1);
        for n_reg = 1:numel(regions_run)
            Region = regions_run(n_reg);
            r_idx = region_gray(:,1) == Region;
            filename = ['Raw' num2str(Region) '.csv'];
            csvwrite([new_dir1 '\' filename], [region_gray(r_idx,2), AI_intensity(r_idx)]);  
        end
    end
    if ops.use_TLDC
        save([ops.ops.save_lut_dir '\TDLC_' ops.save_file_name], 'region_gray', 'calib_im_series', 'ops', '-v7.3');
    end
else
    disp('Not running anything...')
end

%% close SLM

cont1 = input('Done, turnb off laser and press [y] close SLM:', 's');

try 
    f_SLM_close(ops);
end
if ops.use_TLDC
    TLDC_set_Cam_Close(cam_out.hdl_cam);            
end

