function f_sg_pw_correct_weights_within_pat(app)

current_pat = app.UIImagePhaseTable.Data.Pattern(app.UIImagePhaseTableSelection(1));
powers_all = f_sg_update_table_power(app, current_pat);

tab_data = app.UIImagePhaseTable.Data;

new_weights = 1./powers_all;
new_weights = new_weights/min(new_weights);

new_weights2 = new_weights/sum(new_weights);
power_corr = powers_all.*new_weights2;

tab_data.Weight(tab_data.Pattern == current_pat) = new_weights;
tab_data.Power(tab_data.Pattern == current_pat) = power_corr;

app.UIImagePhaseTable.Data = tab_data;

end