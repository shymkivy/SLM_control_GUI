function f_sg_xyz_upload_coord(app, coord)

%% generate image
if ~isempty(coord)
    reg1 = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
    
    app.GUI_buffer.current_AO_phase = [];
    
    %% update slm im
    
    coord_corr = coord;
    coord_corr.xyzp = (coord.xyzp+reg1.xyz_offset)*reg1.xyz_affine_tf_mat;
    
    if strcmpi(app.GenXYZpatmethodDropDown.Value, 'synthesis')
        
        holo_phase = f_sg_PhaseHologram2(coord_corr, reg1);
   
        complex_exp = sum(exp(1i*(holo_phase)).*reshape(coord.weight,[1 1 numel(coord.weight)]),3);
        
        SLM_phase = angle(complex_exp);

        % add ao corrections
        if app.ApplyAOcorrectionButton.Value
            AO_phase = f_sg_AO_get_z_corrections(app, reg1, coord.xyzp(:,3));
            app.GUI_buffer.current_AO_phase = AO_phase;

            holo_phase_corr = holo_phase+AO_phase;
        else
            holo_phase_corr = holo_phase;
        end

        complex_exp_corr = sum(exp(1i*(holo_phase_corr)).*reshape(coord.weight,[1 1 numel(coord.weight)]),3);
        SLM_phase_corr = angle(complex_exp_corr);
        
    elseif strcmpi(app.GenXYZpatmethodDropDown.Value, 'GS meadowlark')
        SLM_phase = f_sg_xyz_gen_holo_MGS(app, coord_corr, reg1);

        holo_phase = [];
        holo_phase_corr = [];
        SLM_phase_corr = SLM_phase;
    end
    
    %% apply mask
    if reg1.zero_outside_phase_diameter
        SLM_phase(~reg1.holo_mask) = 0;
        SLM_phase_corr(~reg1.holo_mask) = 0;
    end
    
    %% apply lut correction
    SLM_phase_corr_lut = f_sg_lut_apply_reg_corr(SLM_phase_corr, reg1);
    
    %% save
    
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