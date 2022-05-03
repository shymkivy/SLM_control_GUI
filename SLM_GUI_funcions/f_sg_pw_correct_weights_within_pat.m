function f_sg_pw_correct_weights_within_pat(app)

if ~isempty(app.UIImagePhaseTableSelection)
    current_pat = app.UIImagePhaseTable.Data.Pattern(app.UIImagePhaseTableSelection(1));

    tab_data =  app.UIImagePhaseTable.Data;
    
    [~, ~, reg1] = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
    [tab_pat, powers_all] = f_sg_update_table_power_core(reg1.pw_corr_data, tab_data(tab_data.Pattern == current_pat,:));
    
    coord = f_sg_mpl_get_coords(app, 'pattern', current_pat);
    
    % get holo and compute w
    holo_phase = f_sg_PhaseHologram(coord.xyzp,...
                        sum(reg1.m_idx), sum(reg1.n_idx),...
                        coord.NA,...
                        app.ObjectiveRIEditField.Value,...
                        reg1.wavelength*1e-9,...
                        reg1.beam_diameter);
    
    for n_holo = 1:size(coord.xyzp,1)
        temp_holo = holo_phase(:,:,n_holo);
        temp_holo(~reg1.holo_mask) = 0;
        holo_phase(:,:,n_holo) = temp_holo;
    end

    holo_phase_corr = holo_phase;
    
    powers_all = powers_all.^2;
    
    I_target = ones(numel(coord.weight),1)./powers_all;
    w_out = f_sg_optimize_phase_w(app, holo_phase_corr, coord, I_target);
    
    
    %  zero offset power max = 1.2167
    I_out = w_out.I_final/1.2167;
    
    I_out2 = I_out.*powers_all;
    
    tab_pat.Weight = w_out.w_final;
    tab_pat.Power = I_out2;

    tab_data(tab_data.Pattern == current_pat,:) = tab_pat;

    app.UIImagePhaseTable.Data = tab_data;
else
    disp('Need to select a pattern')
end

end