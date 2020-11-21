function f_SLM_xyz_pat_update_reg(app)

new_reg = {app.GroupRegionDropDown.Value};
idx_pat = strcmpi(app.PatterngroupDropDown.Value, [app.xyz_patterns.name_tag]);
app.xyz_patterns(idx_pat).SLM_reg = new_reg;

end