function [m_idx, n_idx] = f_SLM_gh_get_regmn(app)

% get slm region
idx_reg = strcmpi(app.SelectRegionDropDownGH.Value, [app.region_list.name_tag]);
reg1 = app.region_list(idx_reg);
m = reg1.height_range;
n = reg1.width_range;

m_px = (1:app.SLM_ops.height)'/app.SLM_ops.height;
n_px = (1:app.SLM_ops.width)'/app.SLM_ops.width;

m_idx = logical((m_px>m(1)).*(m_px<=m(2)));
n_idx = logical((n_px>n(1)).*(n_px<=n(2)));

end