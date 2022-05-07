function f_sg_pp_button_down(app, event)

if event.Button == 3
    if app.rightclickremoveButton.Value
        coords = event.IntersectionPoint(1:2);
        coords = round(coords*100)/100;

        tab_data = app.app_main.UIImagePhaseTable.Data;
        if ~isempty(tab_data.Idx)
            dist1 = sqrt(sum(([tab_data.X, tab_data.Y] - coords).^2,2));
            z_idx = tab_data.Z == app.ZdepthSpinner.Value;

            tab_data(logical(dist1 < 15 .* z_idx),:) = [];

            app.app_main.UIImagePhaseTable.Data = tab_data;
            f_sg_pp_update_group_text(app);
            f_sg_pp_update_pat_plot(app);
        end
    end
elseif event.Button == 1
    if app.leftclickaddButton.Value

        coords = event.IntersectionPoint(1:2);
        coords = round(coords,2);

        tab_data = app.app_main.UIImagePhaseTable.Data;
        
        if isempty(tab_data.Idx)
            idx_shift = 0;
        else
            idx_shift = max(tab_data.Idx);
        end
        
        if app.NewpatternCheckBox.Value
            if isempty(tab_data.Pattern)
                pat_num = 1;
            else
                pat_num = max(tab_data.Pattern) + 1;
            end
        else
            pat_num = app.PatternSpinner.Value;
        end
        new_row1 = f_sg_initialize_tabxyz(app.app_main, 1);
        new_row1.Idx = idx_shift + 1;
        new_row1.Pattern = pat_num;
        new_row1.X = coords(:,1);
        new_row1.Y = coords(:,2);
        new_row1.Z = app.ZdepthSpinner.Value;

        app.app_main.UIImagePhaseTable.Data = [tab_data;new_row1];
        
        f_sg_pp_update_group_text(app);
        f_sg_pp_update_pat_plot(app);
        
    end
end

end