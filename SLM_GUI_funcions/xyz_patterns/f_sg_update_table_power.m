function [tab_data, powers_all] = f_sg_update_table_power(app, curr_pat_all)

tab_data = app.UIImagePhaseTable.Data;

if ~exist('curr_pat_all', 'var')
    curr_pat_all = unique(app.UIImagePhaseTable.Data.Pattern);
end

reg1 = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
reg1 = f_sg_get_reg_extra_deets(reg1);

coord_zero.xyzp = [0 0 0];
coord_zero.weight = 0;
data_w_zero = f_sg_simulate_intensity(reg1, zeros(reg1.SLMm, reg1.SLMn), coord_zero, app.pointsizepixEditField.Value);

powers_all = cell(numel(curr_pat_all),1);

num_pat = numel(curr_pat_all);

wb = f_waitbar_initialize(app, 'Updating power...');
for n_pat = 1:num_pat
    curr_pat = curr_pat_all(n_pat);
    
    tab_data_pat = tab_data(tab_data.Pattern == curr_pat,:);
    tab_data_pat.W_comp = tab_data_pat.W_comp./sum(tab_data_pat.W_comp);
    
    coord.xyzp = [tab_data_pat.X, tab_data_pat.Y, tab_data_pat.Z];
    coord.weight = tab_data_pat.W_comp;
    coord.weight_set = tab_data_pat.W_comp;
    
    coord_corr = f_sg_coord_correct(reg1, coord);
    
    [SLM_phase, ~, ~, ~, ~] = f_sg_xyz_gen_SLM_phase(app, coord_corr, reg1, 0);
    
    data_w = f_sg_simulate_intensity(reg1, SLM_phase, coord_corr, app.pointsizepixEditField.Value);
    
    power_sim = data_w.pt_mags;%/data_w_zero.pt_mags;
    power_corr = f_sg_apply_xy_power_corr(reg1.pw_corr_data, coord.xyzp(:,1:2));
    
    tab_data_pat.Power = power_sim.*power_corr;
    
    powers_all{n_pat} = tab_data_pat.Power;
    tab_data(tab_data.Pattern == curr_pat,:) = tab_data_pat;
    f_waitbar_update(wb, n_pat/num_pat, 'Updating power...');
end
f_waitbar_close(wb);

app.UIImagePhaseTable.Data = tab_data;

end