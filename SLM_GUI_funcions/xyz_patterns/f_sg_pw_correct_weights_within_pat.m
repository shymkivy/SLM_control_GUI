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
num_pat = numel(all_pat);

wb = f_waitbar_initialize(app, 'Correcting weights across pat...');
for n_pat = 1:num_pat
    curr_pat = all_pat(n_pat);
    tab_pat = tab_data(tab_data.Pattern == curr_pat,:);

    coord.idx = tab_pat.Idx;
    coord.xyzp = [tab_pat.X, tab_pat.Y, tab_pat.Z];
    coord.I_targ = tab_pat.I_targ;
    if app.I_targI22PCheckBox.Value
        coord.I_targ1P = sqrt(coord.I_targ);
    else
        coord.I_targ1P = coord.I_targ;
    end
    coord.W_est = tab_pat.W_est;
    
    beam_dump_idx = and(and(tab_pat.X == reg1.beam_dump_xy(1), tab_pat.Y == reg1.beam_dump_xy(2)), tab_pat.Z == 0);
    
    coord.I_targ(beam_dump_idx) = 0;
    coord.I_targ1P(beam_dump_idx) = 0;
    coord.W_est(beam_dump_idx) = 0;
    
    power_corr = f_sg_apply_xy_power_corr(reg1.pw_corr_data, coord.xyzp(:,1:2));
    
    coord_corr = f_sg_coord_correct(reg1, coord);
    
    [~, holo_phase, ~, ~, ~] = f_sg_xyz_gen_SLM_phase(app, coord, reg1, 0, 'Superposition');
    
    if reg1.zero_outside_phase_diameter
        for n_ph = 1:numel(coord.W_est)
            holo1 = holo_phase(:,:,n_ph);
            holo1(~reg1.holo_mask) = 0;
            holo_phase(:,:,n_ph) = holo1;
        end
    end

    %[holo_phase, coord_corr] = f_sg_xyz_gen_holo(coord, reg1);
    
    I_target = coord.I_targ./power_corr;
    w_out = f_sg_optimize_phase_w(app, reg1, holo_phase, coord_corr, I_target, app.PlotwoptimizationCheckBox.Value);
 
    %I_target = coord.weight_set(~beam_dump_idx)./power_corr(~beam_dump_idx);
    %w_out = f_sg_optimize_phase_w(app, holo_phase, coord_corr, I_target, beam_dump_idx);

    tab_pat.W_est = w_out.w_final;
    tab_pat.I_est = w_out.I_final.*power_corr;
    
    tab_data(tab_data.Pattern == all_pat(n_pat),:) = tab_pat;
    f_waitbar_update(wb, n_pat/num_pat, 'Correcting weights within pat...');
end
f_waitbar_close(wb);

% for n_pat = 1:numel(all_pat)
%     curr_pat = all_pat(n_pat);
%     pat_idx = tab_data.Pattern == curr_pat;
%     tab_data(pat_idx,:).W_est = tab_data(pat_idx,:).W_est./sum(tab_data(pat_idx,:).W_est);
% end
app.UIImagePhaseTable.Data = tab_data;

if isempty(all_pat)
    disp('Need to select a pattern');
else
    disp('Done');
end

end