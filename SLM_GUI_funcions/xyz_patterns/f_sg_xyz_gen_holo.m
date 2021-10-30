function holo_image = f_sg_xyz_gen_holo(app, coord, region_name_tag)

% get region
[m_idx, n_idx, reg1] = f_sg_get_reg_deets(app, region_name_tag);

app.current_SLM_coord = coord;

% calib
coord.xyzp = coord.xyzp*reg1.xyz_affine_tf_mat;

% make im;
holo_image = app.SLM_Image;
holo_image(m_idx, n_idx) =  f_sg_gen_holo_multiplane_image(app, coord, reg1);
end