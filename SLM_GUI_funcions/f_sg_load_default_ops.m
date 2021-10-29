function f_sg_load_default_ops(app)

%% copy specific SLM params
SLM_params = app.SLM_ops.SLM_params(strcmpi({app.SLM_ops.SLM_params.name}, app.SLM_ops.SLM_type));
SLM_fieldnames = fieldnames(SLM_params);
for n_fl = 1:numel(SLM_fieldnames)
    if ~isempty(SLM_params.(SLM_fieldnames{n_fl}))
        app.SLM_ops.((SLM_fieldnames{n_fl})) = SLM_params.(SLM_fieldnames{n_fl});
    end
end
app.SLMtypeDropDown.Items = {app.SLM_ops.SLM_params.name};
app.SLMtypeDropDown.Value = app.SLM_ops.SLM_type;


%% Objective params
app.ObjectiveDropDown.Items = unique({app.SLM_ops.obj_params.name},'stable');

obj_params = app.SLM_ops.obj_params(strcmpi({app.SLM_ops.obj_params.SLM},app.SLMtypeDropDown.Value));
obj_params = app.SLM_ops.obj_params(strcmpi({obj_params.name},app.ObjectiveDropDown.Value));

%% copy regions data

region_list = [];
for n_reg = 1:numel(SLM_params.regions_use)
    reg1 = app.SLM_ops.region_list(strcmpi(SLM_params.regions_use(n_reg), [app.SLM_ops.region_list.name_tag]));
    temp_params = obj_params(strcmpi(reg1.name_tag, {obj_params.region}));
    if ~isempty(temp_params)
        reg2 = f_copy_fields(reg1, temp_params);
    else
    end
    region_list = [region_list; reg2];
end


app.region_list = region_list;

%% copy patterns

end