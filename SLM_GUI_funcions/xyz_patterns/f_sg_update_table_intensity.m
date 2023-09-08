function [tab_data, int_all] = f_sg_update_table_intensity(app, curr_pat_all)

tab_data = app.UIImagePhaseTable.Data;

if ~exist('curr_pat_all', 'var')
    curr_pat_all = unique(app.UIImagePhaseTable.Data.Pattern);
end

reg1 = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
reg1 = f_sg_get_reg_extra_deets(reg1);

%coord_zero.xyzp = [0 0 0];
%coord_zero.weight = 0;
%data_w_zero = f_sg_simulate_intensity(reg1, zeros(reg1.SLMm, reg1.SLMn), coord_zero, app.pointsizeumEditField.Value);

int_all = cell(numel(curr_pat_all),1);

num_pat = numel(curr_pat_all);

wb = f_waitbar_initialize(app, 'Updating power...');
for n_pat = 1:num_pat
    curr_pat = curr_pat_all(n_pat);
    
    tab_data_pat = tab_data(tab_data.Pattern == curr_pat,:);
    % if sum(isnan(tab_data_pat.W_est))
    %     w_use = tab_data_pat.W_set;
    % else
    %     w_use = tab_data_pat.W_est;
    % end
    %w_use = tab_data_pat.W_est;
    %tab_data_pat.W_est = w_use./sum(w_use);
    
    coord.idx = tab_data_pat.Idx;
    coord.xyzp = [tab_data_pat.X, tab_data_pat.Y, tab_data_pat.Z];
    coord.I_targ = tab_data_pat.I_targ;
    if app.I_targI22PCheckBox.Value
        coord.I_targ1P = sqrt(coord.I_targ);
    else
        coord.I_targ1P = coord.I_targ;
    end
    coord.W_est = tab_data_pat.W_est;

    coord_corr = f_sg_coord_correct(reg1, coord);
    
    [SLM_phase, ~, ~, ~, ~] = f_sg_xyz_gen_SLM_phase(app, coord, reg1, 0, app.XYZpatalgotithmDropDown.Value);

    if reg1.zero_outside_phase_diameter
        SLM_phase(~reg1.holo_mask) = 0;
    end
    
    data_w = f_sg_simulate_intensity(reg1, SLM_phase, coord_corr, app.pointsizeumEditField.Value, app.UsegaussianbeamampCheckBox.Value, app.I_estI22PCheckBox.Value, app.PlotestimationCheckBox.Value);
    
    intens_sim = data_w.pt_mags;%/data_w_zero.pt_mags;
    intens_corr = f_sg_apply_xy_power_corr(reg1.pw_corr_data, coord.xyzp(:,1:2));
    
    tab_data_pat.I_est = intens_sim.*intens_corr;
    
    int_all{n_pat} = tab_data_pat.I_est;
    tab_data(tab_data.Pattern == curr_pat,:) = tab_data_pat;
    fprintf('pat %d; zero ord intens = %.3f\n', curr_pat, data_w.zero_ord_mag)
    f_waitbar_update(wb, n_pat/num_pat, 'Updating power...');
end
f_waitbar_close(wb);

app.UIImagePhaseTable.Data = tab_data;

end