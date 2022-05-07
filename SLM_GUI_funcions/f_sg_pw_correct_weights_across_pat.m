function f_sg_pw_correct_weights_across_pat(app)

% zero zero zero is a special location used for zero order block

tab_data_full = app.UIImagePhaseTable.Data;

f_sg_pw_correct_weights_within_pat(app, unique(tab_data_full.Pattern))

tab_data_full = app.UIImagePhaseTable.Data;

current_idx = max(tab_data_full.Idx)+1;

reg1 = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
% coord_zero.xyzp = [0 0 0];
% coord_zero.weight = 0;
% coord_zero.NA = reg1.effective_NA;
% data_w_zero = f_sg_simulate_weights(reg1, zeros(reg1.SLMm, reg1.SLMn), coord_zero);

coord_bd.xyzp = [reg1.beam_dump_xy 0];
coord_bd.weight = 0;
coord_bd.NA = reg1.effective_NA;
[holo_phase_bd, coord_bd_corr] = f_sg_xyz_gen_holo(coord_bd, reg1);

% find zeros and remove
beam_dump_idx = and(and(tab_data_full.X == reg1.beam_dump_xy(1), tab_data_full.Y == reg1.beam_dump_xy(2)), tab_data_full.Z == 0);
tab_data = tab_data_full(~beam_dump_idx,:);
tab_data_bd = tab_data_full(beam_dump_idx,:);

all_pat = unique(tab_data.Pattern);

[~, min_pow_idx] = min(tab_data.Power);
tab_data_target = tab_data;
tab_data_target.Power = ones(numel(tab_data_target.Power),1)*tab_data.Power(min_pow_idx);

power_corr = f_sg_apply_xy_power_corr(reg1.pw_corr_data, [tab_data.X, tab_data.Y]);
tab_data_target_pre_corr = tab_data_target;
tab_data_target_pre_corr.Power = tab_data_target.Power./power_corr;

new_row_bd = f_sg_initialize_tabxyz(app, 1);
new_row_bd.X = reg1.beam_dump_xy(1);
new_row_bd.Y = reg1.beam_dump_xy(2);

num_pat = numel(all_pat);

wb = f_waitbar_initialize(app, 'Correcting weights across pat...');
for n_pat = 1:num_pat
    curr_pat = all_pat(n_pat);
    tab_pat = tab_data_target_pre_corr(tab_data_target_pre_corr.Pattern == curr_pat,:);
    
    coord.xyzp = [tab_pat.X tab_pat.Y tab_pat.Z];
    coord.weight = tab_pat.Weight;
    coord.NA = reg1.effective_NA;

    [holo_phase, coord_corr] = f_sg_xyz_gen_holo(coord, reg1);
    
    I_target = tab_pat.Power;
    w_out = f_sg_optimize_phase_w_bd(app, holo_phase, holo_phase_bd, coord_corr, coord_bd_corr, I_target);
    
    tab_pat.Weight = w_out.w_final;
    tab_pat.Power = w_out.I_final;
    
    pat_bd_idx = tab_data_bd.Pattern == curr_pat;
    if ~sum(pat_bd_idx)
        new_row_bd.Pattern = curr_pat;
        new_row_bd.Idx = current_idx;
        current_idx = current_idx + 1;
        tab_data_bd = [tab_data_bd; new_row_bd];
    end
    pat_bd_idx = tab_data_bd.Pattern == curr_pat;
    tab_data_bd(pat_bd_idx,:).Weight = w_out.wbd_final;
    tab_data_bd(pat_bd_idx,:).Power = w_out.Ibd_final;

    tab_data(tab_data.Pattern == curr_pat,:) = tab_pat;
    f_waitbar_update(wb, n_pat/num_pat, 'Correcting weights across pat...');
end
f_waitbar_close(wb)

tab_data_full2 = [tab_data; tab_data_bd];

tab_data_full3 = sortrows(tab_data_full2,'Idx');

power_corr = f_sg_apply_xy_power_corr(reg1.pw_corr_data, [tab_data_full3.X, tab_data_full3.Y]);

tab_data_full4 = tab_data_full3;
tab_data_full4.Power = tab_data_full3.Power .* power_corr;

app.UIImagePhaseTable.Data = tab_data_full4;

end