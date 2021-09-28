function f_sg_lc_load_calib(app)

fpath = app.calibfileEditField.Value;
load1 = load(fpath);

xyz_affine_calib = load1.xyz_affine_calib;

app.data.xyz_affine_calib = xyz_affine_calib;

app.data.zero_ord_coords = xyz_affine_calib.zero_ord_coords;
app.data.first_ord_coords = xyz_affine_calib.first_ord_coords;
app.data.input_coords = xyz_affine_calib.input_coords;

end