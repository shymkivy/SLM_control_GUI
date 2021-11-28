function f_sg_lc_initialize(app)

% temp orary settings
app.imagedirEditField.Value = 'C:\Users\ys2605\Desktop\stuff\SLM_GUI\SLM_outputs\XYZcalibration\XYZcalibration\11_25_20\zoom2\all_im';

time_stamp = clock;
name_tag = sprintf('%d_%d_%d_%dh_%dm',...
            time_stamp(2), time_stamp(3), time_stamp(1)-2000, time_stamp(4),...
            time_stamp(5));

app.calibfilenameEditField.Value = ['xyz_calib_' name_tag '.mat'];

app.FOVszieumEditField.Value = app.app_main.FOVsizeumEditField.Value;
app.ZoomEditField.Value = app.app_main.ZoomEditField.Value;

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