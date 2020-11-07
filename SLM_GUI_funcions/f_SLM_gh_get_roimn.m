function [m_idx, n_idx] = f_SLM_gh_get_roimn(app)

% get slm roi
idx_roi = strcmpi(app.SelectROIDropDownGH.Value, [app.SLM_roi_list.name_tag]);
roi1 = app.SLM_roi_list(idx_roi);
m = roi1.height_range;
n = roi1.width_range;

m_px = (1:app.SLM_ops.height)'/app.SLM_ops.height;
n_px = (1:app.SLM_ops.width)'/app.SLM_ops.width;

m_idx = logical((m_px>m(1)).*(m_px<=m(2)));
n_idx = logical((n_px>n(1)).*(n_px<=n(2)));

end