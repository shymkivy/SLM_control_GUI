function f_SLM_load_calibration(app)

ops = app.SLM_ops;

%% load calibratio files

% load LUT files
if ~exist(ops.lut_dir, 'dir')
    mkdir(ops.lut_dir)
end

f_SLM_lut_global_load_list(app);
f_SLM_lut_regional_load_list(app);
f_SLM_lut_correctios_load_list(app);

% xyz calibration
if ~exist(ops.xyz_calibration_dir, 'dir')
    mkdir(ops.xyz_calibration_dir)
end

% load axial
axial_calibration_fnames = f_SLM_get_file_names([ops.GUI_dir '\' ops.xyz_calibration_dir], '*axial_calibration*.mat', false);
if ~isempty(axial_calibration_fnames)
    ops.axial_calib_file = axial_calibration_fnames{1};
else
    ops.axial_calib_file = '';
end

% load lateral
lateral_calib_fnames = f_SLM_get_file_names([ops.GUI_dir '\' ops.xyz_calibration_dir], '*lateral_affine*.mat', false);
if ~isempty(lateral_calib_fnames)
    ops.lateral_calib_affine_transf_file = lateral_calib_fnames{1};
else
    ops.lateral_calib_affine_transf_file = '';
end

% pixel um
lateral_calib_pixel_um_fnames = f_SLM_get_file_names([ops.GUI_dir '\' ops.xyz_calibration_dir], '*lateral_calibration_pixel*.mat', false);
if ~isempty(lateral_calib_pixel_um_fnames)
    ops.lateral_calib_pixel_um_file = lateral_calib_pixel_um_fnames{1};
else
    ops.lateral_calib_pixel_um_file = '';
end

% load Zernike files
if ~exist(ops.AO_correction_dir, 'dir')
    mkdir(ops.AO_correction_dir)
end
ops.zernike_file_names = f_SLM_get_file_names([ops.GUI_dir '\' ops.AO_correction_dir], '*ernike*.mat', false);

%%
app.SLM_ops = ops;
end