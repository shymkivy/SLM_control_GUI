function f_sg_ops_load(app)

fname = 'SLM_GUI_local_ops.mat';

if exist(fname, 'file')
    load_data = load(fname, 'saved_data');
    load_data = load_data.saved_data;

    app.region_list = load_data.region_list;
    app.xyz_patterns = load_data.xyz_patterns;
    
    f_sg_load_calibration(app)
    
    app.SelectRegionDropDown.Value = load_data.dd.SelectRegionDropDown;
    app.PatterngroupDropDown.Items = [app.xyz_patterns.name_tag];
    app.PatterngroupDropDown.Value = load_data.dd.PatterngroupDropDown;
    app.CurrentregionDropDown.Value = load_data.dd.CurrentregionDropDown;
    
    f_sg_reg_update(app);
    f_sg_pat_update(app);
end

end