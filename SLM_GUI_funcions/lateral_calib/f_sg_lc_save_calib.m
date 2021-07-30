function f_sg_lc_save_calib(app)

zo_coords = app.data.zero_ord_coords;
fo_coords = app.data.first_ord_coords;

xyz_affine_calib.zero_ord_coords = zo_coords;
xyz_affine_calib.first_ord_coords = fo_coords;
xyz_affine_calib.input_coords = app.data.input_coords;

if app.InvertcoordsforbeadsCheckBox.Value
    input_coords = -app.data.input_coords;
else
    input_coords = app.data.input_coords;
end

if app.correctcurrentcalibCheckBox.Value
    initial_tf_mat = app.data.current_calib;
else
    initial_tf_mat = eye(3);
end

displacement_mat = fo_coords - zo_coords;

% get transform % input * affine = slm actual
lateral_affine_SLM = input_coords(:,1:2)\displacement_mat;
lateral_affine_SLM_inv = inv(lateral_affine_SLM);

%lat_cal.input_coords * lateral_affine_SLM_inv * lateral_affine_SLM

% convert affine mat to um
%lateral_affine_SLM_inv_um = diag(lat_cal.xy_pix_step)\lateral_affine_SLM_inv;

xyz_affine_tf_mat = zeros(3,3);

% add affine XY input to pixel transformation
xyz_affine_tf_mat(1:2,1:2) = lateral_affine_SLM_inv;%lateral_affine_SLM_inv_um;
xyz_affine_tf_mat(3,3) = 1;

xyz_affine_calib.xyz_affine_tf_mat = initial_tf_mat*xyz_affine_tf_mat;

fpath = app.calibfileEditField.Value;
save(fpath, 'xyz_affine_calib');
end