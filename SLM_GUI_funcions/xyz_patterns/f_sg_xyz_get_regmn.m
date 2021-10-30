function [m, n] = f_sg_xyz_get_regmn(app)

% get slm region
idx_pat = strcmpi(app.PatterngroupDropDown.Value, [app.xyz_patterns.pat_name]);
idx_reg = strcmpi(app.xyz_patterns(idx_pat).SLM_region, [app.region_list.reg_name]);
reg1 = app.region_list(idx_reg);
m = reg1.height_range;
n = reg1.width_range;

end