function f_SLM_apply_xyz_calibration(app, turn_on)

if turn_on
    try
        load([app.SLM_ops.xyz_calibration_dir '\' app.AxialcalibrationfileEditField.Value], 'axial_calibration');
        load([app.SLM_ops.xyz_calibration_dir '\' app.AffinetransformatiomatrixfileEditField.Value], 'lateral_affine_transform_mat');
        load([app.SLM_ops.xyz_calibration_dir '\' app.LateralpixelumscalingfileEditField.Value], 'lateral_calibration_pixel_um');
        
        % regress number of pixels\um
        pum_fraction = abs(lateral_calibration_pixel_um(:,2)\lateral_calibration_pixel_um(:,1));

        % regress  um\input distance
        axial_in_um_fraction = axial_calibration(:,2)\axial_calibration(:,1);

%         x = -200:1:200;
%         figure; plot(axial_calibration(:,1), axial_calibration(:,2), 'o')
%         hold on;
%         plot(x,x*axial_in_um_fraction)
        
        xyz_affine_tf_mat = zeros(3,3);
        
        % add affine XY input to pixel transformation
        xyz_affine_tf_mat(1:2,1:2) = lateral_affine_transform_mat;
        % scale from pixels to um in sample
        xyz_affine_tf_mat = xyz_affine_tf_mat*pum_fraction;
        % add z scaling component
        xyz_affine_tf_mat(3,3) = axial_in_um_fraction;
        
        app.xyz_affine_tf_mat = xyz_affine_tf_mat;
        
        app.ApplyXYZcalibrationButton.Value = 1;
        app.XYZcalibrationLamp.Color = [0,1,0];
        
        %[-100, 0, 10; 0, -100,-10] *xyz_affine_tf_mat
    catch
        disp('XYZ calibration failed');
        app.xyz_affine_tf_mat = [1 0 0; 0 1 0; 0 0 1];
        app.ApplyXYZcalibrationButton.Value = 0;
        app.XYZcalibrationLamp.Color = [0.80,0.80,0.80];
        pause(0.05);
    end
else
    app.xyz_affine_tf_mat = [1 0 0; 0 1 0; 0 0 1];
    app.ApplyXYZcalibrationButton.Value = 0;
    app.XYZcalibrationLamp.Color = [0.80,0.80,0.80];
    pause(0.05);
end



end