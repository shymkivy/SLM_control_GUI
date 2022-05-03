function xyz_affine_tf_mat = f_sg_compute_xyz_affine_tf_mat_reg(app, reg_params)

xyz_affine_tf_fname = reg_params.xyz_affine_tf_fname;
if app.ApplyXYZcalibrationButton.Value  
    if isempty(xyz_affine_tf_fname)
        xyz_affine_tf_mat = diag(ones(3,1));
    else
        idx_lat = strcmpi(xyz_affine_tf_fname, app.SLM_ops.xyz_corrections_list(:,1));
        lat_cal = app.SLM_ops.xyz_corrections_list{idx_lat,2}; % .xyz_affine_calib in future

        if isfield(lat_cal, 'xyz_affine_calib')
            xyz_affine_tf_mat = lat_cal.xyz_affine_calib.xyz_affine_tf_mat;
        else
            % get transform % input * affine = slm actual
            
            %lat_cal.input_coords(:,2) = lat_cal.input_coords(:,2)*-1;
            lateral_affine_SLM = lat_cal.input_coords\lat_cal.displacement_mat;
            lateral_affine_SLM_inv = inv(lateral_affine_SLM);

            %lat_cal.input_coords * lateral_affine_SLM_inv * lateral_affine_SLM
            
            if ~exist('xy_pix_step', 'var')
                xy_pix_step = [app.FOVsizeumEditField.Value/app.ZoomEditField.Value/app.xpixelsEditField.Value,...
                       app.FOVsizeumEditField.Value/app.ZoomEditField.Value/app.ypixelsEditField.Value];
            end
                   
            % convert affine mat to um
            lateral_affine_SLM_inv_um = diag(xy_pix_step)\lateral_affine_SLM_inv;    
            
            xyz_affine_tf_mat = zeros(3,3);

            % add affine XY input to pixel transformation
            xyz_affine_tf_mat(1:2,1:2) = lateral_affine_SLM_inv_um;
            xyz_affine_tf_mat(3,3) = 1;
            
        end
    end
    if isfield(reg_params, 'xy_over_z_offset')
        xyz_affine_tf_mat(3,1) = reg_params.xy_over_z_offset(1);
        xyz_affine_tf_mat(3,2) = reg_params.xy_over_z_offset(2);
    end
else
    xyz_affine_tf_mat = diag(ones(3,1));
end


end