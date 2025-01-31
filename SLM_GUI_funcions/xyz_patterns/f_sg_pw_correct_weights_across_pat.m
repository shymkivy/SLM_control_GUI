function f_sg_pw_correct_weights_across_pat(app)

% zero zero zero is a special location used for zero order block

bd_idx = 999;

tab_data_full = app.UIImagePhaseTable.Data;

f_sg_pw_correct_weights_within_pat(app, unique(tab_data_full.Pattern))

tab_data_full = app.UIImagePhaseTable.Data;

%current_idx = max(tab_data_full.Idx(tab_data_full.Idx ~= bd_idx))+1;

reg1 = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
% coord_zero.xyzp = [0 0 0];
% coord_zero.weight = 0;
% data_w_zero = f_sg_simulate_intensity(reg1, zeros(reg1.SLMm, reg1.SLMn), coord_zero, app.pointsizeumEditField.Value);

coord_bd.xyzp = [reg1.beam_dump_xy 0];
coord_bd.W_est = 0;
[holo_phase_bd, coord_bd_corr] = f_sg_xyz_gen_holo(coord_bd, reg1);

if reg1.zero_outside_phase_diameter
    holo_phase_bd(~reg1.holo_mask) = 0;
end

% find zeros and remove
beam_dump_idx = and(and(tab_data_full.X == reg1.beam_dump_xy(1), tab_data_full.Y == reg1.beam_dump_xy(2)), tab_data_full.Z == 0);
tab_data = tab_data_full(~beam_dump_idx,:);
tab_data_bd = tab_data_full(beam_dump_idx,:);

all_pat = unique(tab_data.Pattern);

I_norm = tab_data.I_est./tab_data.I_targ;

[~, min_pow_idx] = min(I_norm);

% need to adjust by targets and 

tab_data_target = tab_data;
I_targ_all = ones(numel(I_norm),1)*I_norm(min_pow_idx).*tab_data.I_targ;

power_corr = f_sg_apply_xy_power_corr(reg1.pw_corr_data, [tab_data.X, tab_data.Y]);
tab_data_target_pre_corr = tab_data_target;
%tab_data_target_pre_corr.I_targ = tab_data_target.I_targ./power_corr;
%tab_data_target_pre_corr.I_targ = I_targ_all./power_corr;
I_targ_corr = I_targ_all./power_corr;

new_row_bd = f_sg_initialize_tabxyz(app, 1);
new_row_bd.X = reg1.beam_dump_xy(1);
new_row_bd.Y = reg1.beam_dump_xy(2);

num_pat = numel(all_pat);

wb = f_waitbar_initialize(app, 'Correcting weights across pat...');
for n_pat = 1:num_pat
    curr_pat = all_pat(n_pat);
    idx1 = tab_data_target_pre_corr.Pattern == curr_pat;
    tab_pat = tab_data_target_pre_corr(idx1,:);
    %I_targ_corr

    coord.xyzp = [tab_pat.X tab_pat.Y tab_pat.Z];
    coord.W_est = tab_pat.W_est;

    [holo_phase, coord_corr] = f_sg_xyz_gen_holo(coord, reg1);
    
    if reg1.zero_outside_phase_diameter
        for n_ph = 1:numel(coord.W_est)
            holo1 = holo_phase(:,:,n_ph);
            holo1(~reg1.holo_mask) = 0;
            holo_phase(:,:,n_ph) = holo1;
        end
    end

    I_target = I_targ_corr(idx1);
    w_out = f_sg_optimize_phase_w_bd(app, holo_phase, holo_phase_bd, coord_corr, coord_bd_corr, I_target);
    
    tab_pat.W_est = w_out.w_final;
    tab_pat.I_est = w_out.I_final;
    
    pat_bd_idx = tab_data_bd.Pattern == curr_pat;
    if ~sum(pat_bd_idx)
        new_row_bd.Pattern = curr_pat;
        new_row_bd.Idx = bd_idx;
        %current_idx = current_idx + 1;
        tab_data_bd = [tab_data_bd; new_row_bd];
    end
    pat_bd_idx = tab_data_bd.Pattern == curr_pat;
    tab_data_bd(pat_bd_idx,:).W_est = w_out.wbd_final;
    tab_data_bd(pat_bd_idx,:).I_est = w_out.Ibd_final;

    tab_data(tab_data.Pattern == curr_pat,:) = tab_pat;
    f_waitbar_update(wb, n_pat/num_pat, 'Correcting weights across pat...');
end
f_waitbar_close(wb);

tab_data_full2 = [tab_data; tab_data_bd];

tab_data_full3 = sortrows(tab_data_full2,'Idx');

power_corr = f_sg_apply_xy_power_corr(reg1.pw_corr_data, [tab_data_full3.X, tab_data_full3.Y]);

tab_data_full4 = tab_data_full3;
tab_data_full4.I_est = tab_data_full3.I_est .* power_corr;

app.UIImagePhaseTable.Data = tab_data_full4;

end