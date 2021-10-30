function f_sg_load_default_ops(app)

%% copy specific SLM params
SLM_params = app.SLM_ops.SLM_params(strcmpi({app.SLM_ops.SLM_params.SLM_name}, app.SLM_ops.SLM_type));
app.SLM_ops = f_copy_fields(app.SLM_ops, SLM_params);

app.SLMtypeDropDown.Items = {app.SLM_ops.SLM_params.SLM_name};
app.SLMtypeDropDown.Value = app.SLM_ops.SLM_type;

%% Objective params

app.ObjectiveDropDown.Items = unique({app.SLM_ops.obj_params.obj_name},'stable');

obj_params = app.SLM_ops.obj_params(strcmpi({app.SLM_ops.obj_params.SLM_name},app.SLMtypeDropDown.Value));
obj_params = app.SLM_ops.obj_params(strcmpi({obj_params.obj_name},app.ObjectiveDropDown.Value));

%% copy regions data
obj_def.reg_name = {'default'};
obj_def.height_range = [0, 1];
obj_def.width_range = [0, 1];
obj_def.obj_name = {'default'};
obj_def.SLM_name = {'default'};
obj_def.wavelength = 940;
obj_def.effective_NA = .5;
obj_def.beam_diameter = [];
obj_def.FOV_size = 500;
obj_def.lut_correction_fname = [];
obj_def.xyz_affine_tf_fname = [];
obj_def.AO_correction_fname = [];

region_list = cell(numel(SLM_params.regions_use),1);
for n_reg = 1:numel(SLM_params.regions_use)
    reg0 = obj_def;
    reg_source1 = app.SLM_ops.region_list(strcmpi(SLM_params.regions_use(n_reg), [app.SLM_ops.region_list.reg_name]));
    reg1 = f_copy_fields(reg0, reg_source1);
    reg_source2 = obj_params(strcmpi(reg_source1.reg_name, {obj_params.region}));
    if ~isempty(reg_source2)
        region_list{n_reg} = f_copy_fields(reg1, reg_source2);
    end
end
region_list = cat(1,region_list{:});

if isempty(region_list)
    region_list = obj_def;
end

app.region_list = region_list;
app.SelectRegionDropDown.Items = [region_list.reg_name];
app.CurrentregionDropDown.Items = [region_list.reg_name];

app.FOVsizeumEditField.Value = region_list(strcmpi(app.CurrentregionDropDown.Value, [region_list.reg_name])).FOV_size;
%% copy patterns
app.xyz_patterns = app.SLM_ops.xyz_patterns;

end