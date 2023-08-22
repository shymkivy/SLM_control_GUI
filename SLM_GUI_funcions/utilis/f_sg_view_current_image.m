function f_sg_view_current_image(app)

coord = app.current_SLM_coord;

if ~isempty(coord)
    reg1 = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
    
    %% generate holo (need to apply AO separately for each) 
    view_z = app.fftdefocusumEditField.Value;
    
    if app.ApplyAOcorrectionButton.Value
        AO_phase = f_sg_AO_get_z_corrections(app, reg1, view_z);
    else
        AO_phase = [];
    end
    
    % load and prepare current phase
    SLM_phase_full = app.SLM_phase;
    SLM_phase = SLM_phase_full(reg1.m_idx, reg1.n_idx);

    [im_amp, x_lab, y_lab] = f_sg_compute_holo_fft(reg1, SLM_phase, view_z, AO_phase, app.UsegaussianbeamampCheckBox.Value);
    
    title_tag = '';
    if app.fftampsquaredCheckBox.Value
        im_amp = im_amp.^2;
        title_tag = sprintf('%s; squared (2P)', title_tag);
    end

    f_sg_view_hologram_fft(app, im_amp, x_lab, y_lab);
    title(sprintf('Predicted image from current pattern at %.1f um%s;\n %s algorithm', view_z, title_tag, app.XYZpatalgotithmDropDown.Value), 'interpreter', 'none');

end


end