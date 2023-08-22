function f_sg_xyz_upload_coord(app, coord)

%% generate image
if ~isempty(coord)
    reg1 = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);

    %% update slm im
    [SLM_phase, holo_phase, SLM_phase_corr, holo_phase_corr, AO_phase] = f_sg_xyz_gen_SLM_phase(app, coord, reg1, app.ApplyAOcorrectionButton.Value, app.XYZpatalgotithmDropDown.Value);
    
    %% apply ZO suppression
    if app.ApplyZOsuppressionButton.Value
        SLM_phase_corr = f_sg_apply_ZO_corr(SLM_phase_corr, reg1);
        SLM_phase = f_sg_apply_ZO_corr(SLM_phase, reg1);
    end
    
    %% apply mask
    if reg1.zero_outside_phase_diameter
        SLM_phase(~reg1.holo_mask) = 0;
        SLM_phase_corr(~reg1.holo_mask) = 0;
    end
    
    %% apply lut correction
    SLM_phase_corr_lut = f_sg_lut_apply_reg_corr(SLM_phase_corr, reg1);
    
    %% save
    app.GUI_buffer.current_AO_phase = AO_phase;
    
    app.current_SLM_coord = coord;
    app.GUI_buffer.current_SLM_coord = coord;
    app.GUI_buffer.current_region = reg1;
    app.GUI_buffer.current_holo_phase = holo_phase;
    
    app.GUI_buffer.current_holo_phase_corr = holo_phase_corr;
    
    app.GUI_buffer.current_SLM_phase = SLM_phase;
    app.GUI_buffer.current_SLM_phase_corr = SLM_phase_corr;
    app.GUI_buffer.current_SLM_phase_corr_lut = SLM_phase_corr_lut;
    
    app.SLM_phase(reg1.m_idx, reg1.n_idx) = SLM_phase;
    app.SLM_phase_corr(reg1.m_idx, reg1.n_idx) = SLM_phase_corr;
    app.SLM_phase_corr_lut(reg1.m_idx, reg1.n_idx) = SLM_phase_corr_lut;
    
    %% upload local region to SLM
    f_sg_upload_image_to_SLM(app);
end

end