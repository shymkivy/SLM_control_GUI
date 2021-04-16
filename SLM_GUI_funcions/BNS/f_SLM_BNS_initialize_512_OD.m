function ops = f_SLM_BNS_initialize_512_OD(ops)
% regionalLUTfileName, SLMInitializationImageFileName 
% [ sdk ]
%% SLM params
if ~exist('ops', 'var')
    ops = struct;
end

%% directories
% library path
if ~isfield(ops, 'SLM_SDK_dir') % where is SDK
    ops.SLM_SDK_dir = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\SDK';
end

if ~isfield(ops, 'lut_dir') % where are lut files
    ops.lut_dir = 'lut_calibration\'; % regionalLUTfileName goes here
end

%% Lut global
% the 512 BNS with OD needs to upload regional lut during creation for OD
% to work, otherwise it will be disabled per Anna
% for new BNS 1920 can send null, because it has no OD technically

if ~isfield(ops, 'lut_fname')   % use linear if not specified
    ops.lut_fname = 'linear.lut';
end

lut_path = [ops.lut_dir '\' ops.lut_fname];

if ~exist(lut_path, 'file')
    error('lut file missing in specified path: %s',lut_path);
end

%% path to blank calibration image for BNS 512 OD
if ~isfield(ops, 'cal_image_path')   % use linear if not specified
    ops.cal_image_path = ''; % add default path here
end


%% Load the DLL
% Blink_C_wrapper.dll, Blink_SDK.dll, ImageGen.dll, FreeImage.dll and wdapi1021.dll
% should all be located in the same directory as the program referencing the
% library

%ops.path_library = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\SDK';
addpath(ops.SLM_SDK_dir);

if ~libisloaded('Blink_SDK_C')  % this is for old 512 BNS with OverDrive
    loadlibrary('Blink_SDK_C.dll', 'Blink_SDK_C_matlab.h');
end

%% load imagegen library which is in new BNS 1920 slm sdk path
f_SLM_BNS_load_imagegen();

%% Basic parameters for calling Create_SDK for BNS 512 with OD
ops.bit_depth = 8;
ops.num_boards_found = libpointer('uint32Ptr', 0);
ops.constructed_okay = libpointer('int32Ptr', 0);
ops.is_nematic_type = 1; %  for SLMs built with Nematic Liquid Crystal
ops.RAM_write_enable = 1;
ops.use_GPU = 1;    % not sure, new SLM does not need GPU for uploading; was 0
ops.max_transients = 10;
ops.true_frames = 3;
ops.slm_resolution = 512;

% % not sure if needed
% % from new slm code
% ops.wait_For_Trigger = 0; % This feature is user-settable; use 1 for 'on' or 0 for 'off'
% ops.external_Pulse = 0;
% ops.timeout_ms = 5000;

%% load blank calibration image
ops.cal_image = imread(SLMInitializationImageFileName);

%%

ops.sdk = calllib('Blink_SDK_C', 'Create_SDK', ops.bit_depth, ops.slm_resolution, ops.num_boards_found, ops.constructed_okay,...
                    ops.is_nematic_type, ops.RAM_write_enable, ops.use_GPU, ops.max_transients, lut_path);

if ops.constructed_okay.value == 0
    disp('Blink SDK was not successfully constructed');
    disp(calllib('Blink_SDK_C', 'Get_last_error_message', ops.sdk));
    calllib('Blink_SDK_C', 'Delete_SDK', ops.sdk);
else
    %% 
    disp('Blink SDK was successfully constructed');
    fprintf('Found %u SLM controller(s)\n', ops.num_boards_found.value);
    % Set the basic SLM parameters
    calllib('Blink_SDK_C', 'Set_true_frames', ops.sdk, ops.true_frames);
    % A blank calibration file must be loaded to the SLM controller
    calllib('Blink_SDK_C', 'Write_cal_buffer', ops.sdk, 1, ops.cal_image);
    % A linear LUT must be loaded to the controller for OverDrive Plus
    calllib('Blink_SDK_C', 'Load_linear_LUT', ops.sdk, 1);
        
    % Turn the SLM power on
    calllib('Blink_SDK_C', 'SLM_power', ops.sdk, 1);
end