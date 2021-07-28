function f_sg_lc_load_calib(app)

dir1 = 'C:\Users\ys2605\Desktop\stuff\SLM_GUI\SLM_control_GUI\SLM_calibration\xyz_calibration\';
load1 = load([dir1 'test_calib_7_28_21.mat']);

lateral_calibration = load1.lateral_calibration;

app.data.zero_ord_coords = lateral_calibration.zero_ord_coords;
app.data.first_ord_coords = lateral_calibration.first_ord_coords;
app.data.displacement_mat = lateral_calibration.first_ord_coords - app.data.zero_ord_coords;

end