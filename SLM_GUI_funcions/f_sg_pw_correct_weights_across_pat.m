function f_sg_pw_correct_weights_across_pat(app)

% zero zero zero is a special location used for zero order block

f_sg_pw_correct_weights_within_pat(app)

tab_data = app.UIImagePhaseTable.Data;

[~, ~, reg1] = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);

% find zeros and remove
beam_dump_idx = and(and(tab_data.X == reg1.beam_dump_xy(1), tab_data.Y == reg1.beam_dump_xy(2)), tab_data.Z == 0);
% tab_data(zero_idx,:) = [];
% app.UIImagePhaseTable.Data = tab_data;

% recompute all power distributions
%[tab_data, powers_all] = f_sg_update_table_power(app);

all_pat = unique(tab_data.Pattern);

power_corr = f_sg_apply_xy_power_corr(reg1.pw_corr_data, [tab_data.X, tab_data.Y]);
tab_data_pre_corr = tab_data;
tab_data_pre_corr.Power = tab_data.Power./power_corr;

[min_power, min_pow_idx] = min(tab_data_pre_corr.Power(~beam_dump_idx));

tab_data_pre_corr_target = tab_data;
tab_data_pre_corr_target.Power = tab_data.Power(min_pow_idx)./power_corr;

new_row = f_sg_initialize_tabxyz(app, 1);
tab_new = f_sg_initialize_tabxyz(app, 0);

for n_pat = 1:numel(all_pat)
    curr_pat = all_pat(n_pat);
    tab_pat = tab_data_pre_corr_target(tab_data_pre_corr_target.Pattern == curr_pat,:);
    
    weight1 = tab_pat.Weight;
    weight1 = weight1/sum(weight1);
    
    power_pre_corr = tab_pat.Power./power_corr;
    
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