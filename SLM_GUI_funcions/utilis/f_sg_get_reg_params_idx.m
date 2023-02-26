function reg_params_idx = f_sg_get_reg_params_idx(app, reg_name)

reg_params_idx1 = strcmpi(app.SLMtypeDropDown.Value, {app.region_obj_params.SLM_name});
reg_params_idx2 = strcmpi(app.ObjectiveDropDown.Value, {app.region_obj_params.obj_name});
reg_params_idx3 = strcmpi(reg_name, {app.region_obj_params.reg_name});
reg_params_idx = logical(reg_params_idx1.*reg_params_idx2.*reg_params_idx3);

end