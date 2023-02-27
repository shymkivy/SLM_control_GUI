function f_sg_pw_correct_weights_within_pat(app, all_pat)

tab_data =  app.UIImagePhaseTable.Data;

reg1 = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);

if ~exist('all_pat', 'var')
    if ~isempty(app.UIImagePhaseTableSelection)
        all_pat = unique(app.UIImagePhaseTable.Data.Pattern(app.UIImagePhaseTableSelection(:,1)));
    elseif ~isempty(tab_data)
        all_pat = unique(tab_data.Pattern);
    else
        all_pat = [];
    end
end

for n_pat = 1:numel(all_pat)
    curr_pat = all_pat(n_pat);
    tab_pat = tab_data(tab_data.Pattern == curr_pat,:);

    coord.xyzp = [tab_pat.X tab_pat.Y tab_pat.Z];
    coord.weight = tab_pat.W_set;

    beam_dump_idx = and(and(tab_pat.X == reg1.beam_dump_xy(1), tab_pat.Y == reg1.beam_dump_xy(2)), tab_pat.Z == 0);

    power_corr = f_sg_apply_xy_power_corr(reg1.pw_corr_data, coord.xyzp(:,1:2));

    [holo_phase, coord_corr] = f_sg_xyz_gen_holo(coord, reg1);

    I_target = coord.weight(~beam_dump_idx)./power_corr(~beam_dump_idx);
    w_out = f_sg_optimize_phase_w(app, holo_phase, coord_corr, I_target, beam_dump_idx);

    tab_pat.W_comp = w_out.w_final;
    tab_pat.Power = w_out.I_final.*power_corr;

    tab_data(tab_data.Pattern == all_pat(n_pat),:) = tab_pat;
end

for n_pat = 1:numel(all_pat)
    curr_pat = all_pat(n_pat);
    pat_idx = tab_data.Pattern == curr_pat;
    tab_data(pat_idx,:).W_comp = tab_data(pat_idx,:).W_comp./sum(tab_data(pat_idx,:).W_comp);
end
app.UIImagePhaseTable.Data = tab_data;

if isempty(all_pat)
    disp('Need to select a pattern');
else
    disp('Done');
end

end