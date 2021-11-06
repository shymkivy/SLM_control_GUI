function f_sg_reg_add(app)

[region1, reg_params] = f_sg_reg_read(app);

idx1 = strcmpi(region1.reg_name, {app.region_list.reg_name});

if sum(idx1)
    disp('Region name already exists');
else
    app.region_list = [app.region_list, region1];
    app.SelectRegionDropDown.Items = {app.region_list.reg_name};
    app.SelectRegionDropDown.Value = region1.reg_name;
    app.CurrentregionDropDown.Items = {app.region_list.reg_name};
end

reg_params_idx = f_sg_get_reg_params_idx(app, reg_params.reg_name);

if sum(reg_params_idx)
    disp('Region params data already exists');
    ans1 = input('Do you want to overwrite? [y/n]:','s');
    if strcmpi(ans1, 'y')
        app.region_obj_params(reg_params_idx) = reg_params;
    elseif strcmpi(ans1, 'n')
        disp('Using old reg params data');
        f_sg_reg_update(app);
    else
        disp('Unrecognized response, try again');
    end
else
    app.region_obj_params = [app.region_obj_params, reg_params];
end

reg_params_idx2 = f_sg_get_reg_params_idx(app, reg_params.reg_name);
f_sg_reg_load_corrections(app, reg_params_idx2);

end