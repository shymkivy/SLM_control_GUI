function f_SLM_xyz_button_view_pattern_phase(app)

coord = f_SLM_mpl_get_coords(app, 'pattern', round(app.PatternSpinner.Value));

% get roi
[m_idx, n_idx] = f_SLM_gh_get_roimn(app);
SLMm = sum(m_idx);
SLMn = sum(n_idx);

holo_image = app.SLM_blank_im;
holo_image(m_idx,n_idx) =  f_SLM_gen_holo_multiplane_image(app, coord, SLMm, SLMn);
                                  
holo_image = f_SLM_AO_add_correction(app,holo_image);

f_SLM_view_hologram_phase(app, holo_image);

end