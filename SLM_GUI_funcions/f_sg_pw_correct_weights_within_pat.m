function f_sg_pw_correct_weights_within_pat(app)

reg_params_idx = f_sg_get_reg_params_idx(app, app.CurrentregionDropDown.Value);
reg_params = app.region_obj_params(reg_params_idx);

plot_stuff = 0;
corr_out = f_sg_compute_pw_corr(app, reg_params, plot_stuff);

%idx_pat = strcmpi(app.PatterngroupDropDown.Value, {app.xyz_patterns.pat_name});

%[m_idx, n_idx, reg1] = f_sg_get_reg_deets(app, app.xyz_patterns(idx_pat).SLM_region);
    
tab_data = app.UIImagePhaseTable.Data;

selection1 = app.UIImagePhaseTableSelection;
current_pat = tab_data.Pattern(selection1(1));

tab_pat_data = tab_data(tab_data.Pattern == current_pat,:);

num_pts = numel(tab_pat_data.X);

powers_all = zeros(num_pts,1);

for n_pt = 1:num_pts
    [~, x_idx] = min((tab_pat_data.X(n_pt) - corr_out.x_coord).^2);
    [~, y_idx] = min((tab_pat_data.Y(n_pt) - corr_out.y_coord).^2);
    powers_all(n_pt) = corr_out.pw_map_2d(y_idx, x_idx);
end

new_weights = 1./powers_all;
new_weights = new_weights/min(new_weights);

tab_data.Weight(tab_data.Pattern == current_pat) = new_weights;

app.UIImagePhaseTable.Data = tab_data;

end