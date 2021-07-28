function f_sg_lc_save_calib(app)

lateral_calibration.zero_ord_coords = app.data.zero_ord_coords;
lateral_calibration.first_ord_coords = app.data.first_ord_coords;
lateral_calibration.displacement_mat = app.data.first_ord_coords - app.data.zero_ord_coords;

dir1 = 'C:\Users\ys2605\Desktop\stuff\SLM_GUI\SLM_control_GUI\SLM_calibration\xyz_calibration\';
save([dir1 'test_calib_7_28_21.mat'], 'lateral_calibration');
end