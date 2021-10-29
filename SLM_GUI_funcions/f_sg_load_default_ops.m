function f_sg_load_default_ops(app)

%% copy specific SLM params
fields1 = app.SLM_ops.SLM_params(strcmpi({app.SLM_ops.SLM_params.name}, app.SLM_ops.SLM_type));
fieldnames1 = fieldnames(fields1);
for n_fl = 1:numel(fieldnames1)
    if ~isempty(fields1.(fieldnames1{n_fl}))
        app.SLM_ops.((fieldnames1{n_fl})) = fields1.(fieldnames1{n_fl});
    end
end
app.SLMtypeDropDown.Items = {app.SLM_ops.SLM_params.name};
app.SLMtypeDropDown.Value = app.SLM_ops.SLM_type;


%% Objective params
app.ObjectiveDropDown.Items = unique({app.SLM_ops.obj_params.name},'stable');

app.SLM_ops.obj_params

%% copy regions
app.region_list

[app.SLM_ops.region_list.name_tag]


%% copy patterns

end