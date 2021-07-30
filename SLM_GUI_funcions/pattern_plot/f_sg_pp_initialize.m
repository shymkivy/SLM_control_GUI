function f_sg_pp_initialize(app)

FOV_size = app.app_main.FOVsizeumEditField.Value;
zoom = app.app_main.ZoomxEditField.Value;

tab_data = app.app_main.UIImagePhaseTable.Data;
tab_data.Properties.VariableNames = {'Idx', 'Pattern', 'Z', 'X', 'Y', 'Weight'};
pattern_data = table2struct(tab_data);
app.data.pattern_data = pattern_data;

patterns = string(unique([tab_data.Pattern]));

app.patternDropDown.Items = patterns;

%% initialize plot

app.data.plot_im = imagesc(app.UIAxes, []);
hold(app.UIAxes, 'on');
axis(app.UIAxes, 'tight');
axis(app.UIAxes, 'equal');
app.UIAxes.XLim = [-FOV_size/zoom/2 FOV_size/zoom/2];
app.UIAxes.YLim = [-FOV_size/zoom/2 FOV_size/zoom/2];

app.data.plot_points = plot(app.UIAxes, 0, 0, '.r');
app.data.plot_points.MarkerSize = 15;
app.data.plot_points.XData = [];
app.data.plot_points.YData = [];

%app.UIFigure.ButtonDownFcn = @(source,event)f_sg_pp_button_down(app,event);
app.data.plot_points.ButtonDownFcn = @(source,event)f_sg_pp_button_down_line(app,event);
%%
f_sg_pp_update_pat_plot(app);

end