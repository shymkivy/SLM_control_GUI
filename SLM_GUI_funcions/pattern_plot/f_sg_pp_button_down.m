function f_sg_pp_button_down(app, event)

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
elseif event.Button == 1
    if app.leftclickaddButton.Value

        coords = event.IntersectionPoint(1:2);
        coords = round(coords);

        tab_data = app.app_main.UIImagePhaseTable.Data;
        
        curr_pat = app.PatternSpinner.Value;
        
        new_row1 = [1,...
                    curr_pat,...
                    coords(1),...
                    coords(2),...
                    app.ZdepthSpinner.Value,...
                    1];
             
        new_row2 = array2table(new_row1);
        new_row2.Properties.VariableNames = tab_data.Properties.VariableNames;
        
        tab_data2 = [tab_data;new_row2];

        [~, idx1] = sort(tab_data2(:,2).Variables);

        tab_data3 = tab_data2(idx1,:);

        tab_data3(:,1).Variables = (1:numel(tab_data3(:,1).Variables))';

        app.app_main.UIImagePhaseTable.Data = tab_data3;
        
        f_sg_pp_update_pat_plot(app);
    end
end

end