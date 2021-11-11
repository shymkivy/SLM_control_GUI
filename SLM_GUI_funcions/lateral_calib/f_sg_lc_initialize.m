function f_sg_lc_initialize(app)

% temp orary settings
app.imagedirEditField.Value = 'C:\Users\ys2605\Desktop\stuff\SLM_GUI\SLM_outputs\XYZcalibration\XYZcalibration\11_25_20\zoom2\all_im';
app.calibfileEditField.Value = 'C:\Users\ys2605\Desktop\stuff\SLM_GUI\SLM_control_GUI\SLM_calibration\xyz_calibration\test_calib_7_28_21.mat';

%% initialize 
app.data.plot_im = imagesc(app.UIAxes, []);
hold(app.UIAxes, 'on');
axis(app.UIAxes, 'tight');
axis(app.UIAxes, 'equal');
app.data.plot_zo = plot(app.UIAxes, 0, 0, 'og');
app.data.plot_fo = plot(app.UIAxes, 0, 0, 'or');
app.data.plot_zo.XData = [];
app.data.plot_zo.YData = [];
app.data.plot_fo.XData = [];
app.data.plot_fo.YData = [];
app.data.plot_zo.MarkerSize = 10;
app.data.plot_zo.LineWidth = 1;
app.data.plot_fo.MarkerSize = 10;
app.data.plot_fo.LineWidth = 1;

%% load current tform

reg_idx = strcmpi(app.app_main.CurrentregionDropDown.Value, {app.app_main.region_list.reg_name});
app.data.current_calib = app.app_main.region_obj_params(reg_idx).xyz_affine_tf_mat;

end