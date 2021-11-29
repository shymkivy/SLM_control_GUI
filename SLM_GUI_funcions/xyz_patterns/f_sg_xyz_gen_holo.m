function holo_complex = f_sg_xyz_gen_holo(app, coord, reg1)

%% xyz calibration
if app.ApplyXYZcalibrationButton.Value  
    xyz_offset = reg1.xyz_offset;
else
    xyz_offset = [0 0 0];
end

% calib
coord.xyzp = (coord.xyzp+xyz_offset)*reg1.xyz_affine_tf_mat;

%% expand weights
% num_points = size(coord.xyzp,1);
% weight = coord.weight;
% if num_points>1
%     if numel(weight) == 1
%         weight = ones(num_points,1)*weight;
%     end
% end

%% generate holo (need to apply AO separately for each)
holo_complex = f_sg_PhaseHologram(xyzp,...
                    sum(reg1.m_idx), sum(reg1.n_idx),...
                    coord.weight,...
                    coord.NA,...
                    app.ObjectiveRIEditField.Value,...
                    reg1.wavelength*1e-9,...
                    reg1.beam_diameter);
               
holo_complex(~reg1.holo_mask) = 1;

end