function [m, n] = f_SLM_gh_get_roimn(app)

% get slm roi
idx_roi = strcmpi(app.SelectROIDropDownGH.Value, [app.SLM_roi_list.name_tag]);
roi1 = app.SLM_roi_list(idx_roi);
m = roi1.height_range;
n = roi1.width_range;

end