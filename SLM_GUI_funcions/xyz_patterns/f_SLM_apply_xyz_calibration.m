function f_SLM_apply_xyz_calibration(app)

f_SLM_compute_xyz_affine_tf_mat(app);
if app.ApplyXYZcalibrationButton.Value
    app.XYZcalibrationLamp.Color = [0,1,0];
    pause(0.05);
else
    app.XYZcalibrationLamp.Color = [0.80,0.80,0.80];
    pause(0.05);
end

end