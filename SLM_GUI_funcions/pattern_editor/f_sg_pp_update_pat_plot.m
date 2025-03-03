function f_sg_pp_update_pat_plot(app)

tab_data = app.app_main.UIImagePhaseTable.Data;
app.PatterngroupEditField.Value = app.app_main.PatterngroupDropDown.Value;
f_sg_pp_update_group_text(app);


if app.PlotallpatternsCheckBox.Value
    tab_data2 = tab_data;
    if isfield(app.data, 'group_tags')
        gr_tags2 = app.data.group_tags;
    end
else
    curr_pat = app.PatternSpinner.Value;
    idx1 = tab_data.Pattern == curr_pat;
    tab_data2 = tab_data(idx1,:);
    if isfield(app.data, 'group_tags')
        gr_tags2 = app.data.group_tags(idx1);
    end
end
idx2 = tab_data2.Z == app.ZdepthSpinner.Value;
tab_data3 = tab_data2(idx2,:);
app.data.plot_points.XData = tab_data3.X;
app.data.plot_points.YData = tab_data3.Y;
f_sg_pp_add_text(app, 'text_idx', tab_data3.X + 5, tab_data3.Y - 15, tab_data3.Idx, 'red', app.IndextagCheckBox);
f_sg_pp_add_text(app, 'text_pat', tab_data3.X + 5, tab_data3.Y, tab_data3.Pattern, 'green', app.PatterntagCheckBox);
if isfield(app.data, 'group_tags')
    gr_tags3 = gr_tags2(idx2);
    f_sg_pp_add_text(app, 'text_group', tab_data3.X + 5, tab_data3.Y + 15, gr_tags3, 'magenta', app.GrouptagCheckBox);
end

f_sg_pp_update_group_text(app);

end