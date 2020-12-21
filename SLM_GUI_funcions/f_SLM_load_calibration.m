function f_SLM_load_calibration(app)

ops = app.SLM_ops;

%% load calibratio files

% load LUT files
if ~exist(ops.lut_dir, 'dir')
    mkdir(ops.lut_dir)
end

f_SLM_lut_load_list(app);
f_SLM_lut_correctios_load_list(app);

ops = app.SLM_ops;

% xyz calibration
if ~exist(ops.xyz_calibration_dir, 'dir')
    mkdir(ops.xyz_calibration_dir)
end

% load lateral
lateral_calib_fnames = f_SLM_get_file_names(ops.xyz_calibration_dir, '*lateral_affine*.mat', false);
ops.lateral_calibration = cell(numel(lateral_calib_fnames),2);
for n_fl = 1:numel(lateral_calib_fnames)
    ops.lateral_calibration(n_fl,1) = lateral_calib_fnames(n_fl);
    ops.lateral_calibration{n_fl,2} = load([ops.xyz_calibration_dir '\' lateral_calib_fnames{n_fl}]);
end
ops.lateral_calibration = [{'None'}, {[]};ops.lateral_calibration];

% load Zernike files
if ~exist(ops.AO_correction_dir, 'dir')
    mkdir(ops.AO_correction_dir)
end
AO_fnames = f_SLM_get_file_names(ops.AO_correction_dir, '*zernike*.mat', false);
ops.AO_correction = cell(numel(AO_fnames),2);
for n_fl = 1:numel(AO_fnames)
    ops.AO_correction{n_fl, 1} = AO_fnames{n_fl};
    ops.AO_correction{n_fl, 2} = load([ops.AO_correction_dir '\' AO_fnames{n_fl}]);
end
ops.AO_correction = [{'None'}, {[]};ops.AO_correction];

%% update dropdowns
app.LUTDropDown.Items = app.lut_list;
app.LUTDropDown.Value = ops.lut_fname;

app.LateralaffinetransformDropDown.Items = ops.lateral_calibration(:,1);
app.AOcorrectionDropDown.Items = ops.AO_correction(:,1);

%%
app.SLM_ops = ops;
end