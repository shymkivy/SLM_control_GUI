function f_SLM_xyz_pat_update_roi(app)

new_roi = {app.PatternROIDropDown.Value};
idx_pat = strcmpi(app.PatternlistDropDown.Value, [app.xyz_patterns.name_tag]);
app.xyz_patterns(idx_pat).SLM_roi = new_roi;

end