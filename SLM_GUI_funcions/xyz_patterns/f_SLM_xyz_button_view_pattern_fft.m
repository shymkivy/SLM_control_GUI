function f_SLM_xyz_button_view_pattern_fft(app)

coord = f_SLM_mpl_get_coords(app, 'pattern', round(app.PatternSpinner.Value));

[m_idx, n_idx] = f_SLM_get_reg_deets(app, app.GroupRegionDropDown.Value);

holo_image = f_SLM_xyz_gen_holo(app, coord, app.GroupRegionDropDown.Value); 

f_SLM_view_hologram_fft(app, holo_image(m_idx, n_idx), app.fftdefocusumEditField.Value*10e-6);
title(sprintf('PSF at %.1f um', app.fftdefocusumEditField.Value));

end