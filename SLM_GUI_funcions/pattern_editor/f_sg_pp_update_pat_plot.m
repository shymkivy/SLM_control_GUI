function f_sg_pp_update_pat_plot(app)

tab_data = app.app_main.UIImagePhaseTable.Data;

if ~isempty(tab_data.Idx)
    if app.PlotallpatternsCheckBox.Value
        tab_data2 = tab_data;
    else
        curr_pat = app.PatternSpinner.Value;
        tab_data2 = tab_data(tab_data.Pattern == curr_pat,:);
    end
    tab_data3 = tab_data2(tab_data2.Z == app.ZdepthSpinner.Value,:);
    app.data.plot_points.XData = tab_data3.X;
    app.data.plot_points.YData = tab_data3.Y;
    f_sg_pp_add_text(app, 'text_idx', tab_data3.X + 5, tab_data3.Y - 15, tab_data3.Idx, 'red', app.IndextagCheckBox);
    f_sg_pp_add_text(app, 'text_pat', tab_data3.X + 5, tab_data3.Y, tab_data3.Pattern, 'green', app.PatterntagCheckBox);
    if app.GrouptagCheckBox.Value
        
    end
    f_sg_pp_add_text(app, 'text_group', tab_data3.X + 5, tab_data3.Y + 15, tab_data3.Pattern, 'magenta', app.GrouptagCheckBox);
else
    app.data.plot_points.XData = [];
    app.data.plot_points.YData = [];
end

end