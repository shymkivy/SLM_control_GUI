function f_sg_load_calibration(app)

%%
f_sg_lut_correctios_load_list(app);

%% XYZ lateral corrections
ops = app.SLM_ops;

% load lateral
lateral_calib_fnames = f_sg_get_file_names(ops.xyz_calibration_dir, '*xyz*.mat', false);
ops.xyz_corrections_list = cell(numel(lateral_calib_fnames),2);
for n_fl = 1:numel(lateral_calib_fnames)
    ops.xyz_corrections_list(n_fl,1) = lateral_calib_fnames(n_fl);
    ops.xyz_corrections_list{n_fl,2} = load([ops.xyz_calibration_dir '\' lateral_calib_fnames{n_fl}]);
end
ops.xyz_corrections_list = [{'None'}, {[]}; ops.xyz_corrections_list];

%% load Zernike files
AO_fnames = f_sg_get_file_names(ops.AO_correction_dir, '*AO_corr*.mat', false);
ops.AO_corrections_list = cell(numel(AO_fnames),2);
for n_fl = 1:numel(AO_fnames)
    ops.AO_corrections_list{n_fl, 1} = AO_fnames{n_fl};
    ops.AO_corrections_list{n_fl, 2} = load([ops.AO_correction_dir '\' AO_fnames{n_fl}]);
end
ops.AO_corrections_list = [{'None'}, {[]}; ops.AO_corrections_list];

%% check if specified files exist, and erase if not

% for n_reg = 1:numel(app.region_list)
%     if ~sum(strcmpi(app.region_list(n_reg).lut_correction_fname, app.lut_corrections_list(:,1)))
%         app.region_list(n_reg).lut_correction_fname = [];
%     end
%     if ~sum(strcmpi(app.region_list(n_reg).xyz_affine_tf_fname, ops.xyz_corrections_list(:,1)))
%         app.region_list(n_reg).xyz_affine_tf_fname = [];
%     end
%     if ~sum(strcmpi(app.region_list(n_reg).AO_correction_fname, ops.AO_corrections_list(:,1)))
%         app.region_list(n_reg).AO_correction_fname = [];
%     end
% end
% 
% %%

app.LUTcorrectionDropDown.Items = app.lut_corrections_list(:,1);
app.XYZaffinetransformDropDown.Items = ops.xyz_corrections_list(:,1);
app.AOcorrectionDropDown.Items = ops.AO_corrections_list(:,1);

%%
app.SLM_ops = ops;
end