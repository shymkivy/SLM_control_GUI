function f_sg_pp_update_axes(app)

current_z = app.ZdepthSpinner.Value;
z_all = [];
if isstruct(app.app_main.pattern_editor_data)
    if isfield(app.app_main.pattern_editor_data, 'xyz_all')
        z_all = app.app_main.pattern_editor_data.xyz_all(:,3);
    end
end
current_z_idx = (round(current_z) == z_all);

if sum(current_z_idx)
    xy_offset = app.app_main.pattern_editor_data.xyz_all(current_z_idx,1:2);
else
    xy_offset = [0 0];
end

FOV_size = app.app_main.FOVsizeumEditField.Value;
zoom = app.ZoomEditField.Value;

app.UIAxes.XLim = [-FOV_size/zoom/2 FOV_size/zoom/2] + xy_offset(1);
app.UIAxes.YLim = [-FOV_size/zoom/2 FOV_size/zoom/2] + xy_offset(2);
app.data.plot_im.XData = app.UIAxes.XLim;
app.data.plot_im.YData = app.UIAxes.YLim;

app.app_main.ZoomEditField.Value = zoom;


end