function f_SLM_ops_save(app)

saved_data.SLM_roi_list = app.SLM_roi_list;
saved_data.xyz_patterns = app.xyz_patterns;

save('SLM_GUI_local_ops.mat', 'saved_data');

end