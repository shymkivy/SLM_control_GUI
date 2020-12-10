function f_SLM_ops_save(app)

saved_data.region_list = app.region_list;
saved_data.xyz_patterns = app.xyz_patterns;

saved_data.dd.SelectRegionDropDown = app.SelectRegionDropDown.Value;
saved_data.dd.PatterngroupDropDown = app.PatterngroupDropDown.Value;
saved_data.dd.CurrentregionDropDown = app.CurrentregionDropDown.Value;

save('SLM_GUI_local_ops.mat', 'saved_data');

end