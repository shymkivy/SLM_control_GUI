function f_SLM_compute_xyz_affine_tf_mat(app)

if app.ApplyXYZcalibrationButton.Value
    for n_reg = 1:numel(app.region_list)
        if isempty(app.region_list(n_reg).lateral_affine_transform)
            lateral_affine_transform_mat = diag(ones(2,1));
        else
            idx_lat = strcmpi(app.region_list(n_reg).lateral_affine_transform, app.SLM_ops.lateral_calibration(:,1));
            lat_cal = app.SLM_ops.lateral_calibration{idx_lat,2};
            
            % convert affine mat to um
            lateral_affine_transform_mat = diag(lat_cal.xy_calib)\lat_cal.lateral_affine_transform_mat;
        end
        
        if isempty(app.region_list(n_reg).axial_calibration)
            axial_in_um_fraction = 1;
        else
            idx_ax = strcmpi(app.region_list(n_reg).axial_calibration, app.SLM_ops.axial_calibration(:,1));
            ax_cal = app.SLM_ops.axial_calibration{idx_ax,2};
            
            % regress  um\input distance
            axial_in_um_fraction = ax_cal(:,2)\ax_cal(:,1);
        end
        
        xyz_affine_tf_mat = zeros(3,3);
        
        % add affine XY input to pixel transformation
        xyz_affine_tf_mat(1:2,1:2) = lateral_affine_transform_mat;
        xyz_affine_tf_mat(3,3) = axial_in_um_fraction;
        app.region_list(n_reg).xyz_affine_tf_mat = xyz_affine_tf_mat;
        
%         figure; hold on;
%         plot(ax_cal(:,1), ax_cal(:,2), 'o')
%         plot(linspace(-50,50,100), linspace(-50,50,100)/axial_in_um_fraction)
    end
else
    for n_reg = 1:numel(app.region_list)
        app.region_list(n_reg).xyz_affine_tf_mat = diag(ones(3,1));
    end
end


end