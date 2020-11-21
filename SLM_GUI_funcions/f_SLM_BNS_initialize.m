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

%% Lut global
if ~isfield(ops, 'global_lut_fname')
    ops.global_lut_fname = 'linear.lut';
end

global_lut_path = [ops.lut_dir '\' ops.global_lut_fname];

if ~exist(global_lut_path, 'file')
    error('global lut file missing: %s',global_lut_path);
end

%% regional lut
if ~isfield(ops, 'regional_lut_fname') || isempty(ops.regional_lut_fname)
    ops.regional_lut_fname = libpointer('string'); % null or custom regional lut for slm creation
end

if ischar(ops.regional_lut_fname)
    regional_lut_path = [ops.lut_dir '\' ops.global_lut_fname(1:end-4) '_regional\' ops.regional_lut_fname];
    if ~exist(regional_lut_path, 'file')
        warning('Regional lut file missing, changed to null: %s', regional_lut_path);
        regional_lut_path = libpointer('string');
        ops.regional_lut_fname = libpointer('string');
    end
else
    regional_lut_path = ops.regional_lut_fname;
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

%% - create SDK

calllib('Blink_C_wrapper', 'Create_SDK', ops.bit_depth, ops.num_boards_found, ops.constructed_okay, ops.is_nematic_type, ops.RAM_write_enable, ops.use_GPU, ops.max_transients, regional_lut_path);

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
    calllib('Blink_C_wrapper', 'Load_LUT_file',ops.board_number, global_lut_path);
    
    %allocate arrays for our images
    ops.height = calllib('Blink_C_wrapper', 'Get_image_height', ops.board_number);
    ops.width = calllib('Blink_C_wrapper', 'Get_image_width', ops.board_number);
end

end