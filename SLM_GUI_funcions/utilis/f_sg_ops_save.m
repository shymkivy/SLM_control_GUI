function f_sg_ops_save(app)

saved_data.region_list = app.region_list;
saved_data.region_obj_params = app.region_obj_params;
saved_data.xyz_patterns = app.xyz_patterns;

saved_data.dd.SelectRegionDropDown = app.SelectRegionDropDown.Value;
saved_data.dd.PatterngroupDropDown = app.PatterngroupDropDown.Value;
saved_data.dd.CurrentregionDropDown = app.CurrentregionDropDown.Value;

save([app.SLM_ops.GUI_dir '\SLM_GUI_local_ops.mat'], 'saved_data');

end