function f_SLM_xyz_button_view_selected_fft(app)

if size(app.UIImagePhaseTableSelection,1) > 0
    coord = f_SLM_mpl_get_coords(app, 'table_selection');
    
    % get region
    [m_idx, n_idx] = f_SLM_get_reg_deets(app, app.CurrentregionDropDown.Value);

    holo_image = f_SLM_xyz_gen_holo(app, coord, app.CurrentregionDropDown.Value); 

    f_SLM_view_hologram_fft(app, holo_image(m_idx, n_idx), app.fftdefocusumEditField.Value*1e-6);
    title(sprintf('PSF at %.1f um', app.fftdefocusumEditField.Value));
end

end