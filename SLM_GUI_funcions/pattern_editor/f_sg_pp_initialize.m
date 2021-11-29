function f_sg_pp_initialize(app)

tab_data = app.app_main.UIImagePhaseTable.Data;
tab_data.Properties.VariableNames = {'Idx', 'Pattern', 'Z', 'X', 'Y', 'Weight'};
pattern_data = table2struct(tab_data);
app.data.pattern_data = pattern_data;

if isempty([tab_data.Pattern])
    app.PatternSpinner.Value = 1;
else
    app.PatternSpinner.Value = min([tab_data.Pattern]);
end

app.imagedirEditField.Value = f_clean_path(app.app_main.SLM_ops.patter_editor_dir);

%% initialize plot

app.data.plot_im = imagesc(app.UIAxes, []);
hold(app.UIAxes, 'on');
axis(app.UIAxes, 'tight');
axis(app.UIAxes, 'equal');
f_sg_pp_update_axes(app);

app.data.plot_points = plot(app.UIAxes, 0, 0, '.r');
app.data.plot_points.MarkerSize = 15;
app.data.plot_points.XData = [];
app.data.plot_points.YData = [];

%app.UIFigure.ButtonDownFcn = @(source,event)f_sg_pp_button_down(app,event);
app.data.plot_points.ButtonDownFcn = @(source,event)f_sg_pp_button_down_line(app,event);
app.data.plot_im.ButtonDownFcn = @(source,event)f_sg_pp_button_down(app,event);
%%
f_sg_pp_update_pat_plot(app);
f_sg_pp_update_bkg_im(app);
end