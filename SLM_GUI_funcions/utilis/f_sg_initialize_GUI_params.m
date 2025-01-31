function f_sg_initialize_GUI_params(app)
ops = app.SLM_ops;

%% update lut corrections
parmals_to_init = {'lut_correction_fname', 'xyz_affine_tf_fname',...
                   'AO_correction_fname', 'point_weight_correction_fname',...
                   'lut_correction_data', 'AO_wf', 'pw_corr_data'};
                               
for n_par = 1:numel(parmals_to_init)
    if ~isfield(app.region_obj_params, parmals_to_init{n_par})
        app.region_obj_params(1).(parmals_to_init{n_par}) = [];
    end
end

if ~isfield(app.region_obj_params, 'xyz_affine_tf_mat')
    for n_reg = 1:numel(app.region_obj_params)
        app.region_obj_params(n_reg).xyz_affine_tf_mat = diag(ones(3,1));
    end
end

% first check if files exist
files_to_check = {'xyz_affine_tf_fname', 'xyz_corrections_list';...
                  'AO_correction_fname', 'AO_corrections_list';...
                  'point_weight_correction_fname', 'pw_corrections_list'};

for n_reg = 1:numel(app.region_obj_params)
    temp_fname = app.region_obj_params(n_reg).lut_correction_fname;
    temp_list = app.lut_corrections_list(:,1);
    if ~isempty(temp_fname)
        if ~sum(strcmpi(temp_fname, temp_list))
            disp(['File ' temp_fname ' not found']);
            app.region_obj_params(n_reg).lut_correction_fname = [];
        end
    end
    
    for n_fil = 1:size(files_to_check,1)
        temp_fname = app.region_obj_params(n_reg).(files_to_check{n_fil,1});
        temp_list = app.SLM_ops.(files_to_check{n_fil,2})(:,1);
        if ~isempty(temp_fname)
            if ~sum(strcmpi(temp_fname, temp_list))
                disp(['File ' temp_fname ' not found']);
                app.region_obj_params(n_reg).(files_to_check{n_fil,1}) = [];
            end
        end
    end
end

for n_reg = 1:numel(app.region_obj_params)
    app.region_obj_params(n_reg).lut_correction_data = f_sg_get_corr_data(app, app.region_obj_params(n_reg).lut_correction_fname);
    app.region_obj_params(n_reg).xyz_affine_tf_mat = f_sg_compute_xyz_affine_tf_mat_reg(app, app.region_obj_params(n_reg));
    app.region_obj_params(n_reg).AO_wf = f_sg_AO_compute_wf(app, app.region_obj_params(n_reg));
    app.region_obj_params(n_reg).pw_corr_data = f_sg_compute_pw_corr(app, app.region_obj_params(n_reg));
end

%%

app.XYZpatalgotithmDropDown.Items = {'superposition', 'global_GS_Meadowlark', 'superposition_LW', 'global_GS_LW', 'NOVO_CGH_VarI_LW', 'NOVO_CGH_VarIEuclid_LW', 'NOVO_CGH_2PEuclid_LW'}; % , 'global_GS'
app.ImageGenverEditField.Value = 'none';
app.TriggertypeDropDown.Items = {'Trigger to GUI', 'Trigger to SLM', 'Trigger to both'};

AO_params = app.SLM_ops.AO_params;

app.MinZnEditField.Value = AO_params.min_Zn;
app.MaxZnEditField.Value = AO_params.max_Zn;
app.WeightrangeEditField.Value = AO_params.w_range;
app.NumwstepsEditField.Value = AO_params.num_w_steps;
app.WsplinesmparamEditField.Value = AO_params.w_spline_sm_param;
app.WregfactorEditField.Value = AO_params.w_reg_factor;
app.AOignoresphericalmodeCheckBox.Value = AO_params.ignore_spherical;
app.ScanspermodeEditField.Value = AO_params.scans_per_mode;
app.ScanframesdirpathEditField.Value = AO_params.default_AO_scan_path;
app.RefocuseverynframesEditField.Value = AO_params.refocus_every_n_frames;
app.RefocusdistumEditField.Value = AO_params.refocus_dist;
app.RefocusnumstepsEditField.Value = AO_params.refocus_num_steps;
app.RefocussplinesmparamEditField.Value = AO_params.refocus_spline_sm_param;
app.ScanallcorreverynframesEditField.Value = AO_params.scan_all_corr_every_n_frames;
app.DecresegradntimesEditField.Value = AO_params.decrease_grad_n_times;
app.NumiterationsSpinner.Value = AO_params.num_iterations;
app.BeadwindowsizeEditField.Value = AO_params.bead_win_size;
app.PostscandelayEditField.Value = AO_params.post_scan_delay;

app.OptimizationmethodDropDown.Items = {'Sequential', 'Sequential gradient', 'Full gradient', 'Grid search'};
app.OptimizationmethodDropDown.Value = AO_params.Optimization_method;

app.FitmethodDropDown.Items = {'poly1_constrain_z0', 'Poly1', 'Poly2', 'Spline', 'smoothingspline', 'linearinterp'};
app.FitmethodDropDown.Value = AO_params.fit_ao_method;
app.splinesmparam01EditField.Value = AO_params.fit_spline_sm_param;
app.save_fit_weightsCheckBox.Value = AO_params.fit_save_weights;
app.Constrainz0CheckBox.Value = AO_params.constrain_z0;
app.ZcompthreshumEditField.Value = AO_params.z_comp_thresh;
app.CompensatezCheckBox.Value = AO_params.compensate_z;
app.Ignore0CheckBox.Value = AO_params.ignore_0;
app.PlotfitCheckBox.Value = AO_params.plot_fit;
app.PlotextraCheckBox.Value = AO_params.plot_extra;
app.IgnoreallsphericalCheckBox.Value = AO_params.ignore_all_spherical;

%% xyz table
app.UIImagePhaseTable.ColumnName = app.GUI_ops.table_var_names;
app.UIImagePhaseTable.ColumnEditable = true(1, numel(app.GUI_ops.table_var_names));
app.UIImagePhaseTable.ColumnEditable(7) = 0;
app.UIImagePhaseTable.ColumnWidth = {50, 68, 63, 63, 63, 63, 63, 63};

f_sg_pat_update(app, 1);
app.PatternDropDownCtr.Items = [{'None'}, app.xyz_patterns.pat_name];
app.PatternDropDownAI.Items = [{'None'}, app.xyz_patterns.pat_name];

%%
SLMm = ops.sdkObj.height;
SLMn = ops.sdkObj.width;

app.SLMheightEditField.Value = SLMm;
app.SLMwidthEditField.Value = SLMn;

app.ObjectiveRIEditField.Value = ops.objective_RI;
app.TubelengthEditField.Value = ops.tube_length;

app.NIDAQdeviceEditField.Value = ops.NI_DAQ_dvice;
app.DAQcounterchannelEditField.Value = ops.NI_DAQ_counter_channel;
app.DAQAIchannelEditField.Value = ops.NI_DAQ_AI_channel;
app.DAQAOchannelEditField.Value = ops.NI_DAQ_AO_channel;

app.GSnumiterationsEditField.Value = ops.GS_num_iterations;
app.GSzfactorEditField.Value = ops.GS_z_factor;

%%
% blank
app.BlankPixelValueEditField.Value = 0;

% Fresnel lens
app.FresCenterXEditField.Value = SLMn/2;
app.FresCenterYEditField.Value = SLMm/2;
app.FresRadiusEditField.Value = SLMm/2;
app.FresPowerEditField.Value = 1;
app.FresCylindricalCheckBox.Value = 1;
app.FresHorizontalCheckBox.Value = 0;

% Blazed grating
app.BlazPeriodEditField.Value = 127;
app.BlazIncreasingCheckBox.Value = 1;
app.BlazHorizontalCheckBox.Value = 0;

% Stripes
app.StripePixelPerStripeEditField.Value = 8;
app.StripePixelValueEditField.Value = 0;
app.StripeGrayEditField.Value = 127;

% zernike
app.CenterXEditField.Value = floor(SLMn/2);
app.CenterYEditField.Value = floor(SLMm/2);
app.RadiusEditField.Value = min([SLMm, SLMm])/2;

%%
% current regional buffer
app.GUI_buffer.current_SLM_coord = [];
app.GUI_buffer.current_region = [];
app.GUI_buffer.current_holo_phase = [];
app.GUI_buffer.current_AO_phase = [];
app.GUI_buffer.current_holo_phase_corr = [];
app.GUI_buffer.current_SLM_phase = [];
app.GUI_buffer.current_SLM_phase_corr = [];
app.GUI_buffer.current_SLM_phase_corr_lut = [];

f_sg_pat_save(app);

% AO zernike table
app.ZernikeListTable.Data = table();
f_sg_AO_fill_modes_table(app);
f_sg_LUT_update_total_frames(app);

% initialize af matrix
app.ApplyXYZcalibrationButton.Value = 1;
f_sg_apply_xyz_calibration(app);

app.ApplyAOcorrectionButton.Value = 1;
f_sg_apply_AO_correction_button(app);

app.ApplyPWcorrectionButton.Value = 1;
f_sg_apply_PW_correction_button(app);

% initialize blank image
app.SLM_blank_phase = zeros(SLMm, SLMn);
app.SLM_blank_pointer = f_sg_initialize_pointer(app);
app.SLM_blank_pointer.Value = f_sg_im_to_pointer(app.SLM_blank_phase);

app.SLM_phase = app.SLM_blank_phase;
app.SLM_phase_corr = app.SLM_blank_phase;
app.SLM_phase_corr_lut = zeros(SLMm, SLMn, 'uint8');

app.SLM_image_pointer = f_sg_initialize_pointer(app);
app.SLM_image_pointer.Value = f_sg_im_to_pointer(app.SLM_blank_phase);


    
% gh stuff
app.SLM_gh_phase_preview = app.SLM_blank_phase;
app.SLM_phase_plot = imagesc(app.UIAxesGenerateHologram, app.SLM_blank_phase+pi);
axis(app.UIAxesGenerateHologram, 'tight');
axis(app.UIAxesGenerateHologram, 'equal');
app.UIAxesGenerateHologram.CLim = [0 2*pi];

clim_x = linspace(app.UIAxesGenerateHologram.CLim(1), app.UIAxesGenerateHologram.CLim(2), size(app.UIAxesGenerateHologram.Colormap,1))/pi;
clim_im = reshape(app.UIAxesGenerateHologram.Colormap, [1 size(app.UIAxesGenerateHologram.Colormap,1) 3]);

app.SLM_image_gh_climits = imagesc(app.UIAxesColorLimits, clim_x, [], clim_im);
axis(app.UIAxesColorLimits, 'tight');

app.current_SLM_coord = f_sg_get_coords(app, 'zero');
app.current_SLM_AO_Image = [];

if ~exist(ops.save_AO_dir, 'dir')
    mkdir(ops.save_AO_dir);
end

if ~exist(ops.save_patterns_dir, 'dir')
    mkdir(ops.save_patterns_dir);
end

if ~exist(ops.custom_phase_dir, 'dir')
    mkdir(ops.custom_phase_dir);
end
app.ImagepathEditField.Value = [ops.custom_phase_dir '\'];

if ~exist(ops.pattern_editor_dir, 'dir')
    mkdir(ops.pattern_editor_dir);
end

% initialize DAQ
f_sg_initialize_DAQ(app);
%

end