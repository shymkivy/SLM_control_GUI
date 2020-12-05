function [m, n] = f_SLM_xyz_get_regmn(app)

% get slm region
idx_pat = strcmpi(app.PatterngroupDropDown.Value, [app.xyz_patterns.name_tag]);
idx_reg = strcmpi(app.xyz_patterns(idx_pat).SLM_region, [app.region_list.name_tag]);
reg1 = app.region_list(idx_reg);
m = reg1.height_range;
n = reg1.width_range;

end