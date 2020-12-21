function holo_image = f_SLM_xyz_gen_holo(app, coord, region_name_tag)

% get region
[m_idx, n_idx, xyz_affine_tf_mat, ~] = f_SLM_get_reg_deets(app, region_name_tag);
SLMm = sum(m_idx);
SLMn = sum(n_idx);

app.current_SLM_coord = coord;

% calib
coord.xyzp = (xyz_affine_tf_mat*coord.xyzp')';

% make im;
holo_image = app.SLM_Image;
holo_image(m_idx,n_idx) =  f_SLM_gen_holo_multiplane_image(app, coord, SLMm, SLMn);
end