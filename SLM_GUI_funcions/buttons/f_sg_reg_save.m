function f_sg_reg_save(app)

[reg_list, reg_params] = f_sg_reg_read(app);

current_reg_name = app.SelectRegionDropDown.Value;
current_reg_idx = strcmpi(current_reg_name, {app.region_list.reg_name});

if sum(current_reg_idx)
    app.region_list(current_reg_idx) = reg_list;
    app.SelectRegionDropDown.Items = {app.region_list.reg_name};
    app.SelectRegionDropDown.Value = reg_list.reg_name;
    app.CurrentregionDropDown.Items = {app.region_list.reg_name};
else
    disp('save region did not work');
end

reg_params_idx = f_sg_get_reg_params_idx(app, current_reg_name);

if sum(reg_params_idx)
    app.region_obj_params(reg_params_idx) = reg_params;
else
    disp('Adding new reg params');
    app.region_obj_params = [app.region_obj_params, reg_params];
    f_sg_reg_update(app);
end

% to load new lut xyz and ao
reg_params_idx = f_sg_get_reg_params_idx(app, current_reg_name);
f_sg_reg_load_corrections(app, reg_params_idx);

end