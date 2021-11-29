%% Script for getting data for calibration lut
%% Try closing thing from past

try
    [~] = f_SLM_close(ops);
catch
end


%% Parameters
NumDataPoints = 256;    % bit depth
NumRegions = 1;         % field has to be divisible by the number of regions
PixelsPerStripe = 8;    

save_pref = '940_slm5221_maitai2';
AI_integratin_time = 0.5; % sec
order = 0;

addpath('C:\Users\rylab_901c\Desktop\Yuriy_scripts\SLM_Control');
time_stamp = sprintf('%s_%sh_%sm',datestr(now,'mm_dd_yy'),datestr(now,'HH'),datestr(now,'MM'));
save_path = 'C:\Users\rylab_901c\Desktop\Yuriy_scripts\SLM_Control\lut_calibration';
save_csv_path = [save_path '\' 'lut_raw' save_pref time_stamp '\'];
mkdir(save_csv_path);
%% Initialize SLM
ops = f_SLM_initialize();

%% Initialize DAQ
session = daq.createSession ('ni');
session.addCounterInputChannel('dev2', 'ctr0', 'EdgeCount');
resetCounters(session);

%% create gratings and upload
if ops.SDK_created == 1
    
    %allocate arrays for our images
    SLM_image = libpointer('uint8Ptr', zeros(ops.width*ops.height,1));
    
    % Create an array to hold measurements from the analog input (AI) board
    
    
    % Generate a blank wavefront correction image, you should load your
    % custom wavefront correction that was shipped with your SLM.
    PixelValue = 0;
    calllib('ImageGen', 'Generate_Solid', SLM_image, ops.width, ops.height, PixelValue);
    
    f_SLM_update(ops, SLM_image);
	
    figure;
    SLM_phase_plot = imagesc(reshape(SLM_image.Value, ops.width, ops.height)');
    caxis([1 256]);
    title('SLM phase');
    
    AI_stack = cell(NumRegions,1);
    
    %loop through each region
    for Region = 0:(NumRegions-1)
        
        AI_Intensities = zeros(NumDataPoints,2);
        
        %AI_Index = 1;
        %loop through each graylevel
        for Gray = 0:(NumDataPoints-1)
            %Generate the stripe pattern and mask out current region
            calllib('ImageGen', 'Generate_Stripe', SLM_image, ops.width, ops.height, PixelValue, Gray, PixelsPerStripe);
            calllib('ImageGen', 'Mask_Image', SLM_image, ops.width, ops.height, Region, NumRegions);
            
            %write the image
            f_SLM_update(ops, SLM_image);
            SLM_phase_plot.CData = reshape(SLM_image.Value, ops.width, ops.height)';
            
            %let the SLM settle for 10 ms
            pause(0.01);
            
            AI_Intensities(Gray+1,1) = Gray;
            
            % record
            % mean 
        
        end
    
        % dump the AI measurements to a csv file
        
        if order
            fold_dir = [save_csv_path 'first_ord\'];
            if ~exist(fold_dir, 'dir'); mkdir(fold_dir); end
            csvwrite([fold_dir  'raw' num2str(Region) '.csv'], [AI_Intensities(:, 1) AI_Intensities(:, 2)]);
        else
            fold_dir = [save_csv_path 'zero_ord\'];
            if ~exist(fold_dir, 'dir'); mkdir(fold_dir); end
            csvwrite([fold_dir  'raw' num2str(Region) '.csv'], [AI_Intensities(:, 1) AI_Intensities(:, 2)]);
        end

        AI_stack{Region+1} = AI_Intensities;
    end
    
    save_file_name = [save_path '\' 'lut_raw_' save_pref time_stamp '.mat'];
    save(save_file_name, 'AI_stack', 'order', 'NumDataPoints', 'NumRegions', 'PixelsPerStripe', 'cam_params', 'ops', 'save_raw_stack', '-v7.3')

end


%% close SLM
ops = f_SLM_close(ops);

