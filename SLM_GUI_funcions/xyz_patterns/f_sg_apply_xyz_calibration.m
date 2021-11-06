function f_sg_apply_xyz_calibration(app)

for n_reg = 1:numel(app.region_obj_params)
    app.region_obj_params(n_reg).xyz_affine_tf_mat = f_sg_compute_xyz_affine_tf_mat_reg(app, app.region_obj_params(n_reg).xyz_affine_tf_fname);
end
if app.ApplyXYZcalibrationButton.Value
    app.XYZcalibrationLamp.Color = [0,1,0];
    pause(0.05);
else
    app.XYZcalibrationLamp.Color = [0.80,0.80,0.80];
    pause(0.05);
end

end