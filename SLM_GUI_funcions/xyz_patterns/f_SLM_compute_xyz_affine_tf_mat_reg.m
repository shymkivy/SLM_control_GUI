function xyz_affine_tf_mat = f_SLM_compute_xyz_affine_tf_mat_reg(app, reg1)

if app.ApplyXYZcalibrationButton.Value
        if isempty(reg1.lateral_affine_transform)
            lateral_affine_SLM_inv_um = diag(ones(2,1));
        else
            idx_lat = strcmpi(reg1.lateral_affine_transform, app.SLM_ops.lateral_calibration(:,1));
            lat_cal = app.SLM_ops.lateral_calibration{idx_lat,2};
            
            % get transform % input * affine = slm actual
            lateral_affine_SLM = lat_cal.input_coords\lat_cal.displacement_mat;
            lateral_affine_SLM_inv = inv(lateral_affine_SLM);
            
            %lat_cal.input_coords * lateral_affine_SLM_inv * lateral_affine_SLM

            % convert affine mat to um
            lateral_affine_SLM_inv_um = diag(lat_cal.xy_pix_step)\lateral_affine_SLM_inv;
        end

        xyz_affine_tf_mat = zeros(3,3);
        
        % add affine XY input to pixel transformation
        xyz_affine_tf_mat(1:2,1:2) = lateral_affine_SLM_inv_um;
        xyz_affine_tf_mat(3,3) = 1;
        
else
        xyz_affine_tf_mat = diag(ones(3,1));
end


end