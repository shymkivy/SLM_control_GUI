function f_sg_ops_load(app)

fname = 'SLM_GUI_local_ops.mat';

if exist(fname, 'file')
    load_data = load(fname, 'saved_data');
    load_data = load_data.saved_data;

    %%
    temp_region_list = repmat(app.SLM_ops.default_region_list, [1, numel(load_data.region_list)]);
    for n_reg = 1:numel(load_data.region_list)
        temp_region_list(n_reg) = f_copy_fields(app.SLM_ops.default_region_list, load_data.region_list(n_reg));
    end
    app.region_list = temp_region_list;
    
    %%
    def_region_params.obj_name = app.SLM_ops.default_objectives.obj_name;
    def_region_params.SLM_name = app.SLM_ops.SLM_name;
    def_region_params.reg_name = 'Full SLM';
    def_region_params = f_copy_fields(def_region_params, app.SLM_ops.default_region_params);
    temp_region_obj_params = repmat(def_region_params, [1, numel(load_data.region_obj_params)]);
    for n_reg = 1:numel(load_data.region_obj_params)
        temp_region_obj_params(n_reg) = f_copy_fields(app.SLM_ops.default_region_params, load_data.region_obj_params(n_reg));
    end
    app.region_obj_params = temp_region_obj_params;
    
    %%
    temp_xyz = load_data.xyz_patterns;
    for n_pat = 1:numel(temp_xyz)
        if size(temp_xyz(n_pat).xyz_pts,2)>6
            temp_pts = temp_xyz(n_pat).xyz_pts;
            temp_pts(:,6) = [];
            temp_pts(:,3) = temp_xyz(n_pat).xyz_pts(:,4);
            temp_pts(:,4) = temp_xyz(n_pat).xyz_pts(:,5);
            temp_pts(:,5) = temp_xyz(n_pat).xyz_pts(:,3);
            temp_xyz(n_pat).xyz_pts = temp_pts;
        end
    end
    app.xyz_patterns = temp_xyz;
    
    %%
    f_sg_load_calibration(app)
    
    app.SelectRegionDropDown.Value = load_data.dd.SelectRegionDropDown;
    app.PatterngroupDropDown.Items = {app.xyz_patterns.pat_name};
    app.PatterngroupDropDown.Value = load_data.dd.PatterngroupDropDown;
    app.CurrentregionDropDown.Value = load_data.dd.CurrentregionDropDown;
    
    f_sg_reg_update(app);
    f_sg_pat_update(app);
    
    f_sg_update_all_corrections(app);
end

end