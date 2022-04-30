function f_sg_pw_correct_weights_across_pat(app)

% zero zero zero is a special location used for zero order block

tab_data = app.UIImagePhaseTable.Data;

% find zeros and remove
zero_idx = and(and(tab_data.X == 0, tab_data.Y == 0), tab_data.Z == 0);
tab_data(zero_idx,:) = [];
app.UIImagePhaseTable.Data = tab_data;

% recompute all power distributions
[tab_data, powers_all] = f_sg_update_table_power(app);

all_pat = unique(tab_data.Pattern);

for n_pat = 1:numel(all_pat)
    curr_pat = all_pat(n_pat);

    new_weights = 1./powers_all{n_pat};
    new_weights = new_weights/min(new_weights);

    new_weights2 = new_weights/sum(new_weights);
    power_corr = powers_all{n_pat}.*new_weights2;

    tab_data.Weight(tab_data.Pattern == curr_pat) = new_weights;
    tab_data.Power(tab_data.Pattern == curr_pat) = power_corr;
end

app.UIImagePhaseTable.Data = tab_data;

min_power = min(tab_data.Power);

new_row = f_sg_initialize_tabxyz(app, 1);
reg_params_idx = f_sg_get_reg_params_idx(app, app.CurrentregionDropDown.Value);
[~, ~, reg1] = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);

tab_new = f_sg_initialize_tabxyz(app, 0);

for n_pat = 1:numel(all_pat)
    curr_pat = all_pat(n_pat);
    tab_pat = tab_data(tab_data.Pattern == curr_pat,:);
    
    weight1 = tab_pat.Weight;
    weight1 = weight1/sum(weight1);
    
    weight2 = min_power./tab_pat.Power .* weight1;
    weight_zero = 1 - sum(weight2);
    
    weight_all = [weight2;weight_zero];
    
    weight_all = weight_all/min(weight2);
    
    new_row.Pattern = curr_pat;
    tab_data2 = [tab_data(tab_data.Pattern == curr_pat,:); new_row];
    tab_data2.Weight = weight_all;
    
    [tab_data3, ~] = f_sg_update_table_power_core(reg1, tab_data2);
    
    tab_new = [tab_new; tab_data3];
end

tab_new.Idx = (1:numel(tab_new.Idx))';

app.UIImagePhaseTable.Data = tab_new;



end