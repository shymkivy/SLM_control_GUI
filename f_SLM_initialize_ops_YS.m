function ops = f_SLM_initialize_ops_YS(ops)

if ~exist('ops', 'var')
    ops = struct;
end

% library path
ops.path_library = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\SDK';
ops.GUI_dir = 'C:\Users\ys2605\Desktop\SLM stuff\Prairie_2_scratch\SLM_microscope_GUI\';
ops.lut_dir = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\LUT Files';
% - In your program you should use the path to your custom LUT as opposed to linear LUT

% subdirectories
ops.calibration_dir = 'SLM_calibration';
ops.save_AO_dir = 'SLM_AO_save_path';
ops.save_LUT_dir = 'lut_calibration';

% calibration files
ops.axial_calib_file = 'axial_calibration_3_3_20.mat';
ops.lateral_calib_affine_transf_file = 'lateral_affine_transform_mat_3_3_20.mat';
ops.lateral_calib_pixel_um_file = 'lateral_calibration_pixel_um_3_3_20.mat';


% defaults
ops.lut_default_num = 2;

% offset coordinate
ops.X_offset = 30;      % amount to offset with X offset
ops.ref_offset = 50;    % reference image offset (makes + pattern)

% load LUT files
[ops.lut_names, ops.lut_data] = f_SLM_get_file_names(ops.lut_dir, '*.lut', true);
ops.current_lut = ops.lut_names{ops.lut_default_num};
%ops.current_lut = 'linear.lut';

% load Zernike files
ops.zernike_file_names = f_SLM_get_file_names([ops.GUI_dir '\' ops.calibration_dir], '*ernike*.mat', false);


end