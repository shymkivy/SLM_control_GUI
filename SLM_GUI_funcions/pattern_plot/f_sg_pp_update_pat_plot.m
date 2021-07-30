function f_sg_pp_update_pat_plot(app)

curr_pat = str2double(app.patternDropDown.Value);

% tab_data = app.app_main.UIImagePhaseTable.Data;
% tab_data.Properties.VariableNames = {'Idx', 'Pattern', 'Z', 'X', 'Y', 'NA', 'Weight'};
% pattern_data = table2struct(tab_data);

tab_data = app.app_main.UIImagePhaseTable.Data.Variables;

tab_data2 = tab_data(tab_data(:,2) == curr_pat,:);

tab_data3 = tab_data2(tab_data2(:,5) == app.ZdepthSpinner.Value,:);

app.data.plot_points.XData = tab_data3(:,3);
app.data.plot_points.YData = tab_data3(:,4);

patterns = string(unique(tab_data(:,2)));
app.patternDropDown.Items = patterns;

% pt_list{n_reg} = images.roi.Point(app.WF_axes_mapping, 'Color', app.map_pt_colors{n_reg}, 'Position',coords1);
% pt_list{n_reg}.Label = app.mapping_regions{n_reg};

end