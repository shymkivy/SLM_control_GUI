function ops = f_SLM_BNS_initialize(ops)

%% SLM params
if ~exist('ops', 'var')
    ops = struct;
end

%% directories
% library path
if ~isfield(ops, 'SLM_SDK_dir')
    ops.SLM_SDK_dir = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\SDK';
end

if ~isfield(ops, 'lut_dir')
    ops.lut_dir = 'lut_calibration\';
end

if ~isfield(ops, 'lut_fname')
    ops.lut_fname = 'linear.lut';
end

%% Load the DLL
% Blink_C_wrapper.dll, Blink_SDK.dll, ImageGen.dll, FreeImage.dll and wdapi1021.dll
% should all be located in the same directory as the program referencing the
% library

%ops.path_library = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\SDK';
addpath(ops.SLM_SDK_dir);

if ~libisloaded('Blink_C_wrapper')
    loadlibrary('Blink_C_wrapper.dll', 'Blink_C_wrapper.h');
end

% This loads the image generation functions
if ~libisloaded('ImageGen')
    loadlibrary('ImageGen.dll', 'ImageGen.h');
end

lut_file_path = [ops.lut_dir '\' ops.lut_fname];

%% Basic parameters for calling Create_SDK
ops.bit_depth = 12;
ops.num_boards_found = libpointer('uint32Ptr', 0);
ops.constructed_okay = libpointer('int32Ptr', 0);
ops.is_nematic_type = 1; %  for SLMs built with Nematic Liquid Crystal
ops.RAM_write_enable = 1;
ops.use_GPU = 0;
ops.max_transients = 10;
ops.wait_For_Trigger = 0; % This feature is user-settable; use 1 for 'on' or 0 for 'off'
ops.external_Pulse = 0;
ops.timeout_ms = 5000;

%% - In your program you should use the path to your custom LUT as opposed to linear LUT
%ops.path_lut_file = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\LUT Files\linear.LUT';
ops.reg_lut = libpointer('string'); % null or custom regional lut for slm creation

calllib('Blink_C_wrapper', 'Create_SDK', ops.bit_depth, ops.num_boards_found, ops.constructed_okay, ops.is_nematic_type, ops.RAM_write_enable, ops.use_GPU, ops.max_transients, ops.reg_lut);

% Convention follows that of C function return values: 0 is success, nonzero integer is an error
if ops.constructed_okay.value ~= 0  
    disp('Blink SDK was not successfully constructed');
    disp(calllib('Blink_C_wrapper', 'Get_last_error_message'));
    calllib('Blink_C_wrapper', 'Delete_SDK');
else
    ops.board_number = 1;
    disp('Blink SDK was successfully constructed');
    fprintf('Found %u SLM controller(s)\n', ops.num_boards_found.value);
    ops.SDK_created = 1;
    
    % load a LUT 
    calllib('Blink_C_wrapper', 'Load_LUT_file',ops.board_number, lut_file_path);
    
    %allocate arrays for our images
    ops.height = calllib('Blink_C_wrapper', 'Get_image_height', ops.board_number);
    ops.width = calllib('Blink_C_wrapper', 'Get_image_width', ops.board_number);
end

end