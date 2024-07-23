function f_sg_params_SLM_type(app)

was_on = app.SLM_ops.sdkObj.SDK_created;

if was_on
    app.SLM_ops = f_SLM_close(app.SLM_ops);
    if ~app.SLM_ops.sdkObj.SDK_created
        app.ActivateSLMLamp.Color = [0.80,0.80,0.80]; %[0.00,1.00,0.00];
        app.ActivateSLMButton.Value = 0;
    end
end

app.SLM_ops.SLM_type = app.SLMtypeDropDown.Value;

%%
SLM_params = app.SLM_ops.SLM_params(strcmpi({app.SLM_ops.SLM_params.SLM_name}, app.SLM_ops.SLM_type));
app.SLM_ops = f_copy_fields(app.SLM_ops, SLM_params);

%%
f_sg_lut_load_list(app);

f_sg_set_lut(app);

%%
if was_on
    app.SLM_ops = f_SLM_initialize(app.SLM_ops);
    if app.SLM_ops.sdkObj.SDK_created
        app.ActivateSLMLamp.Color = [0.00,1.00,0.00];
        app.ActivateSLMButton.Value = 1;
    end
end

%%
f_sg_load_region_list(app);

%%
% first save region object params before reloading

for n_par = 1:numel(app.region_obj_params)
    temp_data = app.region_obj_params(n_par);

    idx_SLM_name = strcmpi(temp_data.SLM_name, {app.SLM_ops.region_params.SLM_name});
    idx_obj_name = strcmpi(temp_data.obj_name, {app.SLM_ops.region_params.obj_name});
    idx_reg_name = strcmpi(temp_data.reg_name, {app.SLM_ops.region_params.reg_name});
    
    idx_joint = and(and(idx_SLM_name, idx_obj_name), idx_reg_name);
    
    if sum(idx_joint)
        fields1 = fields(app.SLM_ops.region_params(idx_joint));
        for n_fl = 1:numel(fields1)
            app.SLM_ops.region_params(idx_joint).(fields1{n_fl}) = temp_data.(fields1{n_fl});
        end
    else
        warning('Cannot update region data in f_sg_update_params_SLM, line 61ish');
    end
end
% load new reg params
f_sg_load_load_regobj_params(app);

%%
f_sg_load_calibration(app);
f_sg_reg_update(app);

end