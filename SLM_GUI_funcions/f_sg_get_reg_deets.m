function [m_idx, n_idx, xyz_affine_tf_mat, reg1] = f_sg_get_reg_deets(app, name_tag)

% get slm region
idx_reg = strcmpi(name_tag, [app.region_list.name_tag]);
reg1 = app.region_list(idx_reg);
m = reg1.height_range;
n = reg1.width_range;

m_px = (1:app.SLM_ops.height)'/app.SLM_ops.height;
n_px = (1:app.SLM_ops.width)'/app.SLM_ops.width;

m_idx = logical((m_px>m(1)).*(m_px<=m(2)));
n_idx = logical((n_px>n(1)).*(n_px<=n(2)));

reg1 = app.region_list(idx_reg);
xyz_affine_tf_mat = reg1.xyz_affine_tf_mat;

end