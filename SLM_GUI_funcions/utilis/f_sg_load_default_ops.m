function f_sg_load_default_ops(app)

%% copy specific SLM params
SLM_params = app.SLM_ops.SLM_params(strcmpi({app.SLM_ops.SLM_params.SLM_name}, app.SLM_ops.SLM_type));
app.SLM_ops = f_copy_fields(app.SLM_ops, SLM_params);

app.SLMtypeDropDown.Items = {app.SLM_ops.SLM_params.SLM_name};
app.SLMtypeDropDown.Value = app.SLM_ops.SLM_type;

%%
f_sg_lut_load_list(app);

% update from default
if isfield(SLM_params, 'lut_fname')
    if sum(strcmpi(SLM_params.lut_fname, app.LUTDropDown.Items))
        app.LUTDropDown.Value = SLM_params.lut_fname;
    end
else
    if sum(strcmpi('linear.lut', app.LUTDropDown.Items))
        SLM_params.lut_fname = 'linear.lut';
        app.SLM_ops.lut_fname = 'linear.lut';
        app.LUTDropDown.Value = SLM_params.lut_fname;
    end
end

%% some default params if not defined
idx = 1;

default_objectives(idx).obj_name = 'default';
default_objectives(idx).FOV_size = 500;

default_region_list(idx).reg_name = 'Full SLM';
default_region_list(idx).height_range = [0, 1];
default_region_list(idx).width_range = [0, 1];

% default_region_params(idx).obj_name = default_objectives.obj_name;
% default_region_params(idx).SLM_name = app.SLM_ops.SLM_type;
% default_region_params(idx).reg_name = default_region_list.reg_name;
default_region_params(idx).phase_diameter = [];
default_region_params(idx).zero_outside_phase_diameter = true;
default_region_params(idx).beam_diameter = [];
default_region_params(idx).wavelength = 940;
default_region_params(idx).effective_NA = .5;
default_region_params(idx).lut_correction_fname = [];
default_region_params(idx).xyz_affine_tf_fname = [];
default_region_params(idx).AO_correction_fname = [];
default_region_params(idx).point_weight_correction_fname = [];
default_region_params(idx).lut_correction_data = [];
default_region_params(idx).xyz_affine_tf_mat = [];
default_region_params(idx).AO_wf = [];
default_region_params(idx).pw_corr_data = [];
default_region_params(idx).xyz_offset = [0 0 0];
default_region_params(idx).xy_over_z_offset = [0 0]; % axial beam offset by z
default_region_params(idx).zero_order_supp_phase = 0; % in radians % 224 from [0 - 255] 
default_region_params(idx).zero_order_supp_w = 0;
default_region_params(idx).beam_dump_xy = [0 0]; % axial beam offset by z

app.SLM_ops.default_objectives = default_objectives;
app.SLM_ops.default_region_list = default_region_list;
app.SLM_ops.default_region_params = default_region_params;

%% Load objectives
objectives = default_objectives;
if isfield(app.SLM_ops, 'objectives')
    if ~isempty(app.SLM_ops.objectives)
        objectives = app.SLM_ops.objectives;
    end
end

app.ObjectiveDropDown.Items = unique({objectives.obj_name},'stable');
current_obj = objectives(strcmpi(app.ObjectiveDropDown.Value, {objectives.obj_name}));
app.FOVsizeumEditField.Value = current_obj.FOV_size;

%% Load region list
region_list = default_region_list;
if isfield(app.SLM_ops, 'region_list')
    if ~isempty(app.SLM_ops.region_list)
        region_list = app.SLM_ops.region_list;
    end
end

if isfield(SLM_params, 'regions_use')
    if ~isempty(SLM_params.regions_use)
        is_reg = false(numel(region_list),1);
        for n_reg = 1:numel(region_list)
            is_reg(n_reg) = sum(strcmpi(region_list(n_reg).reg_name, SLM_params.regions_use));
        end
        region_list(~is_reg) = [];
    end
end

if isempty(region_list)
    region_list = default_region_list;
end

app.region_list = region_list;
app.SelectRegionDropDown.Items = {region_list.reg_name};
app.CurrentregionDropDown.Items = {region_list.reg_name};


%%
reg_obj_params = app.SLM_ops.region_params;
rop_to_use = false(numel(reg_obj_params),1);
for n_p = 1:numel(reg_obj_params)
    if strcmpi(reg_obj_params(n_p).SLM_name, app.SLM_ops.SLM_type)
        if sum(strcmpi(reg_obj_params(n_p).reg_name, {region_list.reg_name}))
            rop_to_use(n_p) = 1;
        end
    end
end

if sum(rop_to_use)
    app.region_obj_params = reg_obj_params(rop_to_use);
else
    default_roparams.obj_name = default_objectives.obj_name;
    default_roparams.SLM_name = app.SLM_ops.SLM_type;
    default_roparams.reg_name = default_region_list.reg_name;
    default_roparams = f_copy_fields(default_roparams, default_region_params);
    app.region_obj_params = default_roparams;
end

%% copy patterns
Varnames = {'Idx', 'Pattern', 'X', 'Y', 'Z', 'W_set', 'W_est', 'Power'};
app.GUI_ops.table_var_names = Varnames;
xyz_patterns(1).pat_name = 'Multiplane';
tab_data = f_sg_initialize_tabxyz(app, 0);
xyz_patterns(1).xyz_pts = tab_data;
xyz_patterns(1).SLM_region = app.CurrentregionDropDown.Value;

if isfield(app.SLM_ops, 'xyz_patterns')
    temp_pat = app.SLM_ops.xyz_patterns;
    if ~isempty(temp_pat)
        reg_exists = false(numel(temp_pat),1);
        for n_pat = 1:numel(temp_pat)
            reg_exists(n_pat) = sum(strcmpi(temp_pat(n_pat).SLM_region, {app.region_list.reg_name}));
        end
        temp_pat(~reg_exists) = [];
        if ~isempty(temp_pat)
            for n_pat = 1:numel(temp_pat)
                if ~isempty(temp_pat(n_pat).xyz_pts)
                    [num_row, ~] = size(temp_pat(n_pat).xyz_pts);
                    tab_data2 = f_sg_initialize_tabxyz(app, num_row);
                    xyz1 = temp_pat(n_pat).xyz_pts;
                    tab_data2.X = xyz1(:,1);
                    tab_data2.Y = xyz1(:,2);
                    tab_data2.Z = xyz1(:,3);
                else
                    tab_data2 = tab_data;
                end
                temp_pat(n_pat).xyz_pts = tab_data2;
            end
            xyz_patterns = temp_pat;
        end
    end
end
app.xyz_patterns = xyz_patterns;

%%
app.PWsmoothstdEditField.Value = app.SLM_ops.pw_calibration.smooth_std;
app.PWmincorrthreshEditField.Value = app.SLM_ops.pw_calibration.min_thresh;
app.PWsqrt2pCheckBox.Value = app.SLM_ops.pw_calibration.pw_sqrt;

%%
app.ZoomEditField.Value = app.SLM_ops.zoom;


end