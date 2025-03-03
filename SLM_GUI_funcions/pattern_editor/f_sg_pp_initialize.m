function f_sg_pp_initialize(app)

tab_data = app.app_main.UIImagePhaseTable.Data;
pattern_data = table2struct(tab_data);
app.data.pattern_data = pattern_data;

if isempty([tab_data.Pattern])
    app.PatternSpinner.Value = 1;
else
    app.PatternSpinner.Value = min([tab_data.Pattern]);
end

app.imagedirEditField.Value = f_clean_path(app.app_main.SLM_ops.pattern_editor_dir);

%% load ops
var_list = {'imagedirEditField', 'image_dir';...
            'PatternSpinner', 'pattern';...
            'ZdepthSpinner', 'z_depth';...
            'ZoomEditField', 'zoom';...
            'IndextagCheckBox', 'index_tag_check';...
            'PatterntagCheckBox', 'pattern_tag_check';...
            'GrouptagCheckBox', 'group_tag_check';...
            'PlotallpatternsCheckBox', 'plot_all_pat_check';...
            'NewpatternCheckBox', 'new_pat_check';...
            'SamepatternCheckBox', 'same_pat_check';...
            'numXEditField', 'numX';...
            'numYEditField', 'numY';...
            'spacingXEditField', 'spacingX';...
            'spacingYEditField', 'spacingY';...
            'shiftXEditField', 'shiftX';...
            'shiftXEditField', 'shiftY';...
            'VMaxSlider', 'vmaxslider';...
            'VMaxLabel', 'vmaxlabel';...
            'zdepth_mutex', 'zmutex';...
            'current_colormap', 'cur_cmap';...
            };
        
for n_var = 1:size(var_list,1)
    if isfield(app.app_main.pp_ops, var_list{n_var,2})
        app.(var_list{n_var,1}).Value = app.app_main.pp_ops.(var_list{n_var,2});
    end
end

%% Initialize zoom
app.ZoomEditField.Value = app.app_main.SLM_ops.zoom;


%% initialize plot

app.data.plot_im = imagesc(app.UIAxes, []);
hold(app.UIAxes, 'on');
axis(app.UIAxes, 'tight');
axis(app.UIAxes, 'equal');
f_sg_pp_update_colormap(app);
f_sg_pp_update_axes(app);

app.data.plot_points = plot(app.UIAxes, 0, 0, '.r');
app.data.plot_points.MarkerSize = 15;
app.data.plot_points.XData = [];
app.data.plot_points.YData = [];

%app.UIFigure.ButtonDownFcn = @(source,event)f_sg_pp_button_down(app,event);
app.data.plot_points.ButtonDownFcn = @(source,event)f_sg_pp_button_down_line(app,event);
app.data.plot_im.ButtonDownFcn = @(source,event)f_sg_pp_button_down(app,event);

if ~isempty(app.app_main.UIImagePhaseTable.Data)
    tab_sel = app.app_main.UIImagePhaseTableSelection;
    if size(tab_sel,1) > 0
        if tab_sel(1) <= size(app.app_main.UIImagePhaseTable.Data.Z)
            app.ZdepthSpinner.Value = app.app_main.UIImagePhaseTable.Data.Z(tab_sel(1));
            app.PatternSpinner.Value = app.app_main.UIImagePhaseTable.Data.Pattern(tab_sel(1));
        end
    end
end
%%
f_sg_pp_init_z_depth_spinner(app);
f_sg_pp_update_pat_plot(app);
f_sg_pp_update_bkg_im(app);
f_sg_pp_update_group_text(app);

end