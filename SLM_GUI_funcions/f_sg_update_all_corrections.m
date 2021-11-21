function f_sg_update_all_corrections(app)
%% update all

for n_reg = 1:numel(app.region_obj_params)
    app.region_obj_params(n_reg).lut_correction_data = f_sg_get_corr_data(app, app.region_obj_params(n_reg).lut_correction_fname);
    app.region_obj_params(n_reg).xyz_affine_tf_mat = f_sg_compute_xyz_affine_tf_mat_reg(app, app.region_obj_params(n_reg).xyz_affine_tf_fname);
    app.region_obj_params(n_reg).AO_wf = f_sg_AO_compute_wf(app, app.region_obj_params(n_reg));
end

end