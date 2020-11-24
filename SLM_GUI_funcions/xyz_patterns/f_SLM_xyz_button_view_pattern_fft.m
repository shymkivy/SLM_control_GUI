function f_SLM_xyz_button_view_pattern_fft(app)

coord = f_SLM_mpl_get_coords(app, 'pattern', round(app.PatternSpinner.Value));

% get region
[m, n] = f_SLM_xyz_get_regmn(app);
SLMm = m(2) - m(1) + 1;
SLMn = n(2) - n(1) + 1;

holo_image = f_SLM_gen_holo_multiplane_image(app, coord, SLMm, SLMn);
                         
f_SLM_view_hologram_fft(app, holo_image, app.fftdefocusumEditField.Value*10e-6);
title(sprintf('PSF at %.1f um', app.fftdefocusumEditField.Value));

end