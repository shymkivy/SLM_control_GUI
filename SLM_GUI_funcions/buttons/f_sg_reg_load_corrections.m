function f_sg_reg_load_corrections(app, reg_params_idx)

reg_params = app.region_obj_params(reg_params_idx);

app.region_obj_params(reg_params_idx).lut_correction_data = f_sg_get_corr_data(app, reg_params.lut_correction_fname);
app.region_obj_params(reg_params_idx).xyz_affine_tf_mat = f_sg_compute_xyz_affine_tf_mat_reg(app, reg_params.xyz_affine_tf_fname);
app.region_obj_params(reg_params_idx).AO_wf = f_sg_AO_compute_wf(app, reg_params);

end