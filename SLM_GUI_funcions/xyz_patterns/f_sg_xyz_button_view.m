function f_sg_xyz_button_view(app, view_source, view_out)

%% get coords
if strcmpi(view_source, 'custom')
    coord = f_sg_mpl_get_coords(app, view_source);
elseif strcmpi(view_source, 'table_selection')
    if size(app.UIImagePhaseTableSelection,1) > 0
        coord = f_sg_mpl_get_coords(app, view_source);
    else
        coord = [];
    end
elseif strcmpi(view_source, 'pattern')
    coord = f_sg_mpl_get_coords(app, view_source, app.PatternSpinner.Value);
end

%% gen image and view without saving to buffer
if ~isempty(coord)
    [m_idx, n_idx, reg1] = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
    
    holo_phase = f_sg_xyz_gen_holo(app, coord, reg1);
    
    if app.ApplyAOcorrectionButton.Value
        AO_phase = f_sg_AO_get_z_corrections(app, reg1, coord.xyzp(:,3));

        holo_phase_corr = holo_phase+AO_phase;
    else
        holo_phase_corr = holo_phase;
    end
    
    SLM_phase = app.SLM_phase;
    SLM_phase(reg1.m_idx, reg1.n_idx) = angle(sum(exp(1i*(holo_phase_corr)).*reshape(coord.weight,[1 1 numel(coord.weight)]),3));
    
    if strcmpi(view_out, 'phase')
        f_sg_view_hologram_phase(app, SLM_phase);
        title(sprintf('%s defocus %.1f um', view_source, app.ZOffsetumEditField.Value));
    elseif strcmpi(view_out, 'fft')
        f_sg_view_hologram_fft(app, SLM_phase(m_idx, n_idx), app.fftdefocusumEditField.Value);
        title(sprintf('%s PSF at %.1f um', view_source, app.fftdefocusumEditField.Value));
    end
end

end