function ops = f_SLM_BNS1920_sdk3_initialize(ops)

%% SLM params
if ~exist('ops', 'var')
    ops = struct;
end

%% directories
% library path
if ~isfield(ops, 'SLM_SDK_dir')
    ops.SLM_SDK_dir = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\SDK';
    warning('SLM_SDK_dir ops parameter not set, using default: %s', ops.SLM_SDK_dir)
end

if isempty(ops.SLM_SDK_dir)
    ops.SLM_SDK_dir = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\SDK';
    warning('SLM_SDK_dir ops parameter is not specified, using default: %s', ops.SLM_SDK_dir)
end

if ~isfield(ops, 'lut_dir')
    ops.lut_dir = 'lut_calibration\';
end

%% Lut global
if ~isfield(ops, 'lut_fname')
    ops.lut_fname = 'linear.lut';
end

lut_path = [ops.lut_dir '\' ops.lut_fname];

if ~exist(lut_path, 'file')
    error('lut file missing: %s',lut_path);
end

%% Load the DLL
% Blink_C_wrapper.dll, Blink_SDK.dll, ImageGen.dll, FreeImage.dll and wdapi1021.dll
% should all be located in the same directory as the program referencing the
% library

%ops.path_library = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\SDK';
%addpath(ops.SLM_SDK_dir);

if ~libisloaded('Blink_C_wrapper')
    loadlibrary([ops.SLM_SDK_dir, '\Blink_C_wrapper.dll'], [ops.SLM_SDK_dir, '\Blink_C_wrapper.h']); % [not_found,warn] = 
end

%% Basic parameters for calling Create_SDK
ops.bit_depth = 12;
ops.num_boards_found = libpointer('uint32Ptr', 0);
ops.constructed_okay = libpointer('int32Ptr', 0);
ops.is_nematic_type = 1; %  for SLMs built with Nematic Liquid Crystal
ops.RAM_write_enable = 1;
ops.use_GPU = 0;    % this is specific to ODP slms (512)
ops.max_transients = 10; % this is specific to ODP slms (512)
ops.wait_For_Trigger = 0; % This feature is user-settable; use 1 for 'on' or 0 for 'off'
ops.external_Pulse = 0;
ops.timeout_ms = 5000;

%% - create SDK
init_lut_fpath = libpointer('string'); % null for new bns, only important for old

calllib('Blink_C_wrapper', 'Create_SDK', ops.bit_depth, ops.num_boards_found,...
    ops.constructed_okay, ops.is_nematic_type, ops.RAM_write_enable,...
    ops.use_GPU, ops.max_transients, init_lut_fpath);

% Convention follows that of C function return values: 0 is success, nonzero integer is an error
if ~ops.constructed_okay.value ~= 0   % 0 for 1 for v4.856
    disp('Blink SDK was not successfully constructed');
    disp(calllib('Blink_C_wrapper', 'Get_last_error_message'));
    calllib('Blink_C_wrapper', 'Delete_SDK');
else
    ops.board_number = 1;
    disp('Blink SDK was successfully constructed');
    fprintf('Found %u SLM controller(s)\n', ops.num_boards_found.value);
    ops.SDK_created = 1;
    
    % load a LUT 
    calllib('Blink_C_wrapper', 'Load_LUT_file',ops.board_number, lut_path);
    
    %allocate arrays for our images
    ops.height = calllib('Blink_C_wrapper', 'Get_image_height', ops.board_number);
    ops.width = calllib('Blink_C_wrapper', 'Get_image_width', ops.board_number);
end

end