function powers_all = f_sg_update_table_power(app, pat_num)

tab_data = app.UIImagePhaseTable.Data;

if ~exist('pat_num', 'var')
    pat_num = unique(tab_data.Pattern);
end

reg_params_idx = f_sg_get_reg_params_idx(app, app.CurrentregionDropDown.Value);
corr_data = app.region_obj_params(reg_params_idx).pw_corr_data;

for n_pat = 1:numel(pat_num)
    curr_pat = pat_num(n_pat);
    tab_data_pat = tab_data(tab_data.Pattern == curr_pat,:);

    num_pts = numel(tab_data_pat.X);
    
    powers_all = ones(num_pts,1);
    
    if ~isempty(corr_data)
        [~, x_idx] = min((tab_data_pat.X - corr_data.x_coord).^2,[],2);
        [~, y_idx] = min((tab_data_pat.Y - corr_data.y_coord).^2,[],2);
        for n_pt = 1:num_pts
            powers_all(n_pt) = corr_data.pw_map_2d(y_idx(n_pt), x_idx(n_pt));
        end
    end
    
    weights_all = tab_data_pat.Weight/sum(tab_data_pat.Weight);
    powers_corr = powers_all.*weights_all;
    tab_data(tab_data.Pattern == curr_pat,:).Power = powers_corr;
end
app.UIImagePhaseTable.Data = tab_data;

end