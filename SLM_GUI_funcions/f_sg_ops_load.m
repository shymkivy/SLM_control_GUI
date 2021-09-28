function f_sg_ops_load(app)

fname = 'SLM_GUI_local_ops.mat';

if exist(fname, 'file')
    load_data = load(fname, 'saved_data');
    load_data = load_data.saved_data;
    
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

    
    app.region_list = load_data.region_list;
    app.xyz_patterns = temp_xyz;
    
    f_sg_load_calibration(app)
    
    app.SelectRegionDropDown.Value = load_data.dd.SelectRegionDropDown;
    app.PatterngroupDropDown.Items = [app.xyz_patterns.name_tag];
    app.PatterngroupDropDown.Value = load_data.dd.PatterngroupDropDown;
    app.CurrentregionDropDown.Value = load_data.dd.CurrentregionDropDown;
    
    f_sg_reg_update(app);
    f_sg_pat_update(app);
end

end