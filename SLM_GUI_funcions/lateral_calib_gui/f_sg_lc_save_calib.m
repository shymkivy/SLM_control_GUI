function f_sg_lc_save_calib(app)
%%

[d1, ~] = size(app.data.lat_calib_all(1).image);

pix_step_xy = app.FOVszieumEditField.Value/d1/app.ZoomEditField.Value;

%%
islateral = logical(app.UITable.Data(:,4).Variables);
isaxial = logical(app.UITable.Data(:,5).Variables);

zo_coords = app.data.zero_ord_coords;
fo_coords = app.data.first_ord_coords;
input_coords = app.data.input_coords;

xyz_affine_calib.zero_ord_coords = zo_coords;
xyz_affine_calib.first_ord_coords = fo_coords;
xyz_affine_calib.input_coords = input_coords;
xyz_affine_calib.pix_step_xy = pix_step_xy;
xyz_affine_calib.islateral = islateral;
xyz_affine_calib.isaxial = isaxial;

if isfield(app.data, 'y_flip_bug')
    xyz_affine_calib.y_flip_bug = app.data.y_flip_bug;
end

input_coords2 = input_coords;

if app.InvertcoordsforbeadsCheckBox.Value
    input_coords2(:,1:2) = -input_coords2(:,1:2);
end

if isfield(xyz_affine_calib, 'y_flip_bug')
    if xyz_affine_calib.y_flip_bug
        input_coords2(:,2) = -input_coords2(:,2);
    end
end

if app.correctcurrentcalibCheckBox.Value
    initial_tf_mat = app.data.current_calib;
else
    initial_tf_mat = eye(3);
end

calib_ops.invert_for_beads = app.InvertcoordsforbeadsCheckBox.Value;
calib_ops.fov_size = app.FOVszieumEditField.Value;
calib_ops.zoom = app.ZoomEditField.Value;
calib_ops.num_pix = d1;
calib_ops.initial_correction = initial_tf_mat;


displacement_mat = (fo_coords - zo_coords)*pix_step_xy;

%% correct xy lateral

disp_xy = displacement_mat(islateral,:);
input_xy = input_coords2(islateral,1:2);

% get transform % input * affine = slm actual
lateral_affine_tf = input_xy\disp_xy;
lateral_affine_tf_inv = inv(lateral_affine_tf);

%lat_cal.input_coords * lateral_affine_SLM_inv * lateral_affine_SLM

% convert affine mat to um
%lateral_affine_SLM_inv_um = diag(lat_cal.xy_pix_step)\lateral_affine_SLM_inv;

xyz_affine_tf_mat = zeros(3,3);

% add affine XY input to pixel transformation
xyz_affine_tf_mat(1:2,1:2) = lateral_affine_tf_inv;%lateral_affine_SLM_inv_um;
xyz_affine_tf_mat(3,3) = 1;

%% add axial calib if exists
if sum(isaxial)
    input_coords_z = input_coords2(isaxial,3);
    disp_axial_xy = displacement_mat(isaxial,:);

    pred_coord_x = input_coords_z\disp_axial_xy(:,1);
    pred_coord_y = input_coords_z\disp_axial_xy(:,2);

    xyz_affine_tf_mat(3,1:2) = [pred_coord_x pred_coord_y];
end
%%
xyz_affine_calib.xyz_affine_tf_mat = initial_tf_mat*xyz_affine_tf_mat;

xyz_affine_calib.calib_ops = calib_ops;

% check
%input_coords*xyz_affine_tf_mat;

save_path = app.imagedirEditField.Value;
save_fname = app.calibfilenameEditField.Value;

save([save_path '/' save_fname], 'xyz_affine_calib');
end