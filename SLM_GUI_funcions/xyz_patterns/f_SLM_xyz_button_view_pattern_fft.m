function f_SLM_xyz_button_view_pattern_fft(app)

coord = f_SLM_mpl_get_coords(app, 'pattern', round(app.PatternSpinner.Value));

% get region
[m_idx, n_idx] = f_SLM_gh_get_regmn(app);
SLMm = sum(m_idx);
SLMn = sum(n_idx);

holo_image = app.SLM_blank_im;
if ~isempty(coord)
    holo_image(m_idx,n_idx) =  f_SLM_gen_holo_multiplane_image(app, coord, SLMm, SLMn);
    holo_image = f_SLM_AO_add_correction(app,holo_image);
else
    holo_image = holo_image(m_idx,n_idx);
end    

f_SLM_view_hologram_fft(app, holo_image, app.fftdefocusumEditField.Value*10e-6);
title(sprintf('PSF at %.1f um', app.fftdefocusumEditField.Value));

end