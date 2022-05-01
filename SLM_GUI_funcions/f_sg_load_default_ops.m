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
default_objectives(1).obj_name = 'default';
default_objectives(1).FOV_size = 500;

default_region_list(1).reg_name = 'Full SLM';
default_region_list(1).height_range = [0, 1];
default_region_list(1).width_range = [0, 1];

% default_region_params(1).obj_name = default_objectives.obj_name;
% default_region_params(1).SLM_name = app.SLM_ops.SLM_type;
% default_region_params(1).reg_name = default_region_list.reg_name;
default_region_params(1).beam_diameter = [];
default_region_params(1).wavelength = 940;
default_region_params(1).effective_NA = .5;
default_region_params(1).lut_correction_fname = [];
default_region_params(1).xyz_affine_tf_fname = [];
default_region_params(1).AO_correction_fname = [];
default_region_params(1).point_weight_correction_fname = [];
default_region_params(1).lut_correction_data = [];
default_region_params(1).xyz_affine_tf_mat = [];
default_region_params(1).AO_wf = [];
default_region_params(1).pw_corr_data = [];
default_region_params(1).xyz_offset = [0 0 0];
default_region_params(1).xy_over_z_offset = [0 0]; % axial beam offset by z
default_region_params(1).beam_dump_xy = [0 0]; % axial beam offset by z

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
Varnames = {'Idx', 'Pattern', 'X', 'Y', 'Z', 'Weight', 'Power'};
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
                    [num_row, num_col] = size(temp_pat(n_pat).xyz_pts);
                    tab_data2 = f_sg_initialize_tabxyz(app, num_row);
                    if num_col == 3
                        xyz1 = temp_pat(n_pat).xyz_pts;
                    elseif num_col == 4
                        xyz1 = temp_pat(n_pat).xyz_pts(:,1:3);
                        tab_data2.Weight = temp_pat(n_pat).xyz_pts(:,4);
                    elseif num_col == 5
                        xyz1 = temp_pat(n_pat).xyz_pts(:,2:4);
                        tab_data2.Pattern = temp_pat(n_pat).xyz_pts(:,1);
                        tab_data2.Weight = temp_pat(n_pat).xyz_pts(:,5);
                    end
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
% %%
% current_reg = region_list(strcmpi(app.SelectRegionDropDown.Value, {region_list.reg_name}));
% 
% 
% app.RegionnameEditField.Value
% app.regionheightminEditField.Value
% app.regionheightmaxEditField.Value
% region_list(1).reg_name
% 
% %% region-objective params
% 
% region_params = default_region_params;
% 
% current_reg = region_list(strcmpi(default_region_params.reg_name, {region_list.reg_name}));
% current_reg_params = app.SLM_ops.region_params(strcmpi(app.ObjectiveDropDown.Value, {app.SLM_ops.region_params.obj_name}));
% 
% region_params.obj_name = current_obj.obj_name;
% region_params.reg_name = current_reg.reg_name;
% region_params.height_range = current_reg.height_range;
% region_params.width_range = current_reg.width_range;
% 
% obj_params = app.SLM_ops.obj_params(strcmpi({app.SLM_ops.obj_params.SLM_name},app.SLMtypeDropDown.Value));
% obj_params = app.SLM_ops.obj_params(strcmpi({obj_params.obj_name},app.ObjectiveDropDown.Value));
% 
% %% copy regions data
% 
% region_list = cell(numel(SLM_params.regions_use),1);
% for n_reg = 1:numel(SLM_params.regions_use)
%     reg0 = default_region_params;
%     reg_source1 = app.SLM_ops.region_list(strcmpi(SLM_params.regions_use(n_reg), [app.SLM_ops.region_list.reg_name]));
%     reg1 = f_copy_fields(reg0, reg_source1);
%     reg_source2 = obj_params(strcmpi(reg_source1.reg_name, {obj_params.region}));
%     if ~isempty(reg_source2)
%         region_list{n_reg} = f_copy_fields(reg1, reg_source2);
%     end
% end
% region_list = cat(1,region_list{:});
% 
% if isempty(region_list)
%     region_list = default_region_params;
% end
% 
% 

end