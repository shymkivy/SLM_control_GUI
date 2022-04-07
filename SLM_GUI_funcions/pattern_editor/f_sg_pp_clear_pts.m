function f_sg_pp_clear_pts(app)

tab_data = app.app_main.UIImagePhaseTable.Data;
if ~isempty(tab_data)
    tab_data(:,:) = [];

    app.app_main.UIImagePhaseTable.Data = tab_data;
    f_sg_pp_update_pat_plot(app);
end

end