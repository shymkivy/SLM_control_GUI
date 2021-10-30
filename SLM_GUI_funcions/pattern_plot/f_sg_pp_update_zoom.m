function f_sg_pp_update_zoom(app)

FOV_size = app.app_main.FOVsizeumEditField.Value;
zoom = app.ZoomEditField.Value;

app.UIAxes.XLim = [-FOV_size/zoom/2 FOV_size/zoom/2];
app.UIAxes.YLim = [-FOV_size/zoom/2 FOV_size/zoom/2];
app.data.plot_im.XData = app.UIAxes.XLim;
app.data.plot_im.YData = app.UIAxes.YLim;

app.app_main.ZoomEditField.Value = zoom;

end