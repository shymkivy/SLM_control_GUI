function [tab_data, powers_all] = f_sg_update_table_power(app, curr_pat_all)

tab_data = app.UIImagePhaseTable.Data;

if ~exist('curr_pat_all', 'var')
    curr_pat_all = unique(app.UIImagePhaseTable.Data.Pattern);
end

reg_params_idx = f_sg_get_reg_params_idx(app, app.CurrentregionDropDown.Value);
corr_data = app.region_obj_params(reg_params_idx).pw_corr_data;

powers_all = cell(numel(curr_pat_all),1);

for n_pat = 1:numel(curr_pat_all)
    curr_pat = curr_pat_all(n_pat);
    
    tab_data_pat = tab_data(tab_data.Pattern == curr_pat,:);
    [tab_data_pat, powers_all{n_pat}] = f_sg_update_table_power_core(corr_data, tab_data_pat);

    tab_data(tab_data.Pattern == curr_pat,:) = tab_data_pat;
end

app.UIImagePhaseTable.Data = tab_data;

end