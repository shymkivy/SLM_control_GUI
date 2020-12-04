function f_SLM_apply_xyz_calibration(app)

for n_reg = 1:numel(app.region_list)
    app.region_list(n_reg).xyz_affine_tf_mat = f_SLM_compute_xyz_affine_tf_mat_reg(app, app.region_list(n_reg));
end
if app.ApplyXYZcalibrationButton.Value
    app.XYZcalibrationLamp.Color = [0,1,0];
    pause(0.05);
else
    app.XYZcalibrationLamp.Color = [0.80,0.80,0.80];
    pause(0.05);
end

end