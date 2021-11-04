function f_sg_load_default_ops(app)

%% copy specific SLM params
SLM_params = app.SLM_ops.SLM_params(strcmpi({app.SLM_ops.SLM_params.SLM_name}, app.SLM_ops.SLM_type));
app.SLM_ops = f_copy_fields(app.SLM_ops, SLM_params);

app.SLMtypeDropDown.Items = {app.SLM_ops.SLM_params.SLM_name};
app.SLMtypeDropDown.Value = app.SLM_ops.SLM_type;

%% some default params if nto defined
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

app.region_obj_params = app.SLM_ops.region_params;

%%
f_sg_reg_update(app);

%%
current_reg = region_list(strcmpi(app.SelectRegionDropDown.Value, {region_list.reg_name}));


app.RegionnameEditField.Value
app.regionheightminEditField.Value
app.regionheightmaxEditField.Value
region_list(1).reg_name

%% region-objective params

region_params = default_region_params;

current_reg = region_list(strcmpi(default_region_params.reg_name, {region_list.reg_name}));
current_reg_params = app.SLM_ops.region_params(strcmpi(app.ObjectiveDropDown.Value, {app.SLM_ops.region_params.obj_name}));

region_params.obj_name = current_obj.obj_name;
region_params.reg_name = current_reg.reg_name;
region_params.height_range = current_reg.height_range;
region_params.width_range = current_reg.width_range;

obj_params = app.SLM_ops.obj_params(strcmpi({app.SLM_ops.obj_params.SLM_name},app.SLMtypeDropDown.Value));
obj_params = app.SLM_ops.obj_params(strcmpi({obj_params.obj_name},app.ObjectiveDropDown.Value));

%% copy regions data

region_list = cell(numel(SLM_params.regions_use),1);
for n_reg = 1:numel(SLM_params.regions_use)
    reg0 = default_region_params;
    reg_source1 = app.SLM_ops.region_list(strcmpi(SLM_params.regions_use(n_reg), [app.SLM_ops.region_list.reg_name]));
    reg1 = f_copy_fields(reg0, reg_source1);
    reg_source2 = obj_params(strcmpi(reg_source1.reg_name, {obj_params.region}));
    if ~isempty(reg_source2)
        region_list{n_reg} = f_copy_fields(reg1, reg_source2);
    end
end
region_list = cat(1,region_list{:});

if isempty(region_list)
    region_list = default_region_params;
end


%% copy patterns
app.xyz_patterns = app.SLM_ops.xyz_patterns;

end