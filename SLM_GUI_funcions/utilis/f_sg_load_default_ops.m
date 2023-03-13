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
f_sg_initialize_default_regobj_params(app);

%% Load objectives
objectives = app.SLM_ops.default_objectives;
if isfield(app.SLM_ops, 'objectives')
    if ~isempty(app.SLM_ops.objectives)
        objectives = app.SLM_ops.objectives;
    end
end

app.ObjectiveDropDown.Items = unique({objectives.obj_name},'stable');
current_obj = objectives(strcmpi(app.ObjectiveDropDown.Value, {objectives.obj_name}));
app.FOVsizeumEditField.Value = current_obj.FOV_size;

%% Load region list
f_sg_load_region_list(app);

%%
f_sg_load_load_regobj_params(app);

%% copy patterns
f_sg_initialize_xyz_table(app);

%%
app.PWsmoothstdEditField.Value = app.SLM_ops.pw_calibration.smooth_std;
app.PWmincorrthreshEditField.Value = app.SLM_ops.pw_calibration.min_thresh;
app.PWsqrt2pCheckBox.Value = app.SLM_ops.pw_calibration.pw_sqrt;

%%
app.ZoomEditField.Value = app.SLM_ops.zoom;


end