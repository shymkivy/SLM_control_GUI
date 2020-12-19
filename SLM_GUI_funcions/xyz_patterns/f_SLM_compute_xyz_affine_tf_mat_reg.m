function xyz_affine_tf_mat = f_SLM_compute_xyz_affine_tf_mat_reg(app, reg1)

if app.ApplyXYZcalibrationButton.Value
        if isempty(reg1.lateral_affine_transform)
            lateral_affine_transform_mat = diag(ones(2,1));
        else
            idx_lat = strcmpi(reg1.lateral_affine_transform, app.SLM_ops.lateral_calibration(:,1));
            lat_cal = app.SLM_ops.lateral_calibration{idx_lat,2};
            
            % convert affine mat to um
            lateral_affine_transform_mat = diag(lat_cal.xy_calib)\lat_cal.lateral_affine_transform_mat;
        end

        xyz_affine_tf_mat = zeros(3,3);
        
        % add affine XY input to pixel transformation
        xyz_affine_tf_mat(1:2,1:2) = lateral_affine_transform_mat;
        xyz_affine_tf_mat(3,3) = 1;
        
else
        xyz_affine_tf_mat = diag(ones(3,1));
end


end