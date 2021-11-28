function f_sg_pp_button_down_line(app,event)

if event.Button == 3
    if app.rightclickremoveButton.Value
        coords = event.IntersectionPoint(1:2);
        coords = round(coords);

        tab_data = app.app_main.UIImagePhaseTable.Data;
        if ~isempty(tab_data)
            tab_var = tab_data.Variables;

            dist1 = sqrt(sum((tab_var(:,3:4) - coords).^2,2));
            z_idx = tab_var(:,5) == app.ZdepthSpinner.Value;

            tab_data(logical(dist1 < 15 .* z_idx),:) = [];

            app.app_main.UIImagePhaseTable.Data = tab_data;
            f_sg_pp_update_pat_plot(app);
        end
    end
end

end