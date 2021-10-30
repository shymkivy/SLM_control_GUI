function f_sg_load_calibration(app)

ops = app.SLM_ops;

%% load calibratio files

% load LUT files
if ~exist(ops.lut_dir, 'dir')
    mkdir(ops.lut_dir)
end

% xyz calibration
if ~exist(ops.xyz_calibration_dir, 'dir')
    mkdir(ops.xyz_calibration_dir)
end

if ~exist(ops.AO_correction_dir, 'dir')
    mkdir(ops.AO_correction_dir)
end

%% load luts dropdowns
f_sg_lut_load_list(app);

% update from default
if isfield(ops, 'lut_fname')
    if sum(strcmpi(ops.lut_fname, app.LUTDropDown.Items))
        app.LUTDropDown.Value = ops.lut_fname;
    end
else
    if sum(strcmpi('linear.lut', app.LUTDropDown.Items))
        ops.lut_fname = 'linear.lut';
        app.SLM_ops.lut_fname = 'linear.lut';
        app.LUTDropDown.Value = ops.lut_fname;
    end
end

f_sg_lut_correctios_load_list(app);

%% XYZ lateral corrections
ops = app.SLM_ops;

% load lateral
lateral_calib_fnames = f_sg_get_file_names(ops.xyz_calibration_dir, '*lateral_*.mat', false);
ops.lateral_calibration_list = cell(numel(lateral_calib_fnames),2);
for n_fl = 1:numel(lateral_calib_fnames)
    ops.lateral_calibration_list(n_fl,1) = lateral_calib_fnames(n_fl);
    ops.lateral_calibration_list{n_fl,2} = load([ops.xyz_calibration_dir '\' lateral_calib_fnames{n_fl}]);
end
ops.lateral_calibration_list = [{'None'}, {[]}; ops.lateral_calibration_list];

%% load Zernike files
AO_fnames = f_sg_get_file_names(ops.AO_correction_dir, '*zernike*.mat', false);
ops.AO_correction_list = cell(numel(AO_fnames),2);
for n_fl = 1:numel(AO_fnames)
    ops.AO_correction_list{n_fl, 1} = AO_fnames{n_fl};
    ops.AO_correction_list{n_fl, 2} = load([ops.AO_correction_dir '\' AO_fnames{n_fl}]);
end
ops.AO_correction_list = [{'None'}, {[]}; ops.AO_correction_list];

%% check if specified files exist, and erase if not

for n_reg = 1:numel(app.region_list)
    if ~sum(strcmpi(app.region_list(n_reg).lut_correction_fname, app.lut_corrections_list(:,1)))
        app.region_list(n_reg).lut_correction_fname = [];
    end
    if ~sum(strcmpi(app.region_list(n_reg).xyz_affine_tf_fname, ops.lateral_calibration_list(:,1)))
        app.region_list(n_reg).xyz_affine_tf_fname = [];
    end
    if ~sum(strcmpi(app.region_list(n_reg).AO_correction_fname, ops.AO_correction_list(:,1)))
        app.region_list(n_reg).AO_correction_fname = [];
    end
end

%%
app.LUTcorrectionDropDown.Items = app.lut_corrections_list(:,1);
app.XYZaffinetransformDropDown.Items = ops.lateral_calibration_list(:,1);
app.AOcorrectionDropDown.Items = ops.AO_correction_list(:,1);

%%
app.SLM_ops = ops;
end