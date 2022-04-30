function f_sg_pw_correct_weights_within_pat(app)

tab_data =  app.UIImagePhaseTable.Data;

if ~isempty(app.UIImagePhaseTableSelection)
    current_pat = app.UIImagePhaseTable.Data.Pattern(app.UIImagePhaseTableSelection(1));
elseif ~isempty(tab_data)
    current_pat = tab_data.Pattern(1);
else
    current_pat = 0;
end

if current_pat

    [~, ~, reg1] = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
    
    coord = f_sg_mpl_get_coords(app, 'pattern', current_pat);
    coord_zero = coord;
    coord_zero.xyzp = [0 0 0];
    
    power_corr = f_sg_apply_xy_power_corr(reg1.pw_corr_data, coord.xyzp(:,1:2));
    
    tab_pat = tab_data(tab_data.Pattern == current_pat,:);
    %[tab_pat, powers_all] = f_sg_update_table_power_core(reg1, tab_data(tab_data.Pattern == current_pat,:));
    
    
    [holo_phase, coord_corr] = f_sg_xyz_gen_holo(coord, reg1);
    
    I_target = ones(numel(coord.weight),1)./power_corr;
    w_out = f_sg_optimize_phase_w(app, holo_phase, coord_corr, I_target);
    
    data_w_zero = f_sg_simulate_weights(reg1, zeros(reg1.SLMm, reg1.SLMn), coord_zero);
    
    %  zero offset power max = 1.2167
    I_out = w_out.I_final/data_w_zero.pt_mags;
    
    I_out2 = I_out.*power_corr;
    
    tab_pat.Weight = w_out.w_final;
    tab_pat.Power = I_out2;

    tab_data(tab_data.Pattern == current_pat,:) = tab_pat;

    app.UIImagePhaseTable.Data = tab_data;
else
    disp('Need to select a pattern')
end

end