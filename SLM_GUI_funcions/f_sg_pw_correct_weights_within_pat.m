function f_sg_pw_correct_weights_within_pat(app)

if ~isempty(app.UIImagePhaseTableSelection)
    current_pat = app.UIImagePhaseTable.Data.Pattern(app.UIImagePhaseTableSelection(1));

    tab_data =  app.UIImagePhaseTable.Data;

    reg_params_idx = f_sg_get_reg_params_idx(app, app.CurrentregionDropDown.Value);
    corr_data = app.region_obj_params(reg_params_idx).pw_corr_data;

    [tab_pat, powers_all] = f_sg_update_table_power_core(corr_data, tab_data(tab_data.Pattern == current_pat,:));

    new_weights = 1./powers_all;
    new_weights = new_weights/min(new_weights);

    new_weights2 = new_weights/sum(new_weights);
    power_corr = powers_all.*new_weights2;

    tab_pat.Weight = new_weights;
    tab_pat.Power = power_corr;

    tab_data(tab_data.Pattern == current_pat,:) = tab_pat;

    app.UIImagePhaseTable.Data = tab_data;
else
    disp('Need to select a pattern')
end

end