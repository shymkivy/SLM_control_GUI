function [m, n] = f_SLM_xyz_get_roimn(app)

% get slm roi
idx_pat = strcmpi(app.PatterngroupDropDown.Value, [app.xyz_patterns.name_tag]);
idx_roi = strcmpi(app.xyz_patterns(idx_pat).SLM_roi, [app.SLM_roi_list.name_tag]);
roi1 = app.SLM_roi_list(idx_roi);
m = roi1.height_range;
n = roi1.width_range;

end