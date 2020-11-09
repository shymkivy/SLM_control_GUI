function f_SLM_xyz_button_view_holo(app)

coord = f_SLM_mpl_get_coords(app, 'custom');

% get region
[m_idx, n_idx] = f_SLM_gh_get_regmn(app);
SLMm = sum(m_idx);
SLMn = sum(n_idx);

% make im;
holo_image = app.SLM_blank_im;
holo_image(m_idx,n_idx) =  f_SLM_gen_holo_multiplane_image(app, coord, SLMm, SLMn);
    
holo_image = f_SLM_AO_add_correction(app,holo_image);

f_SLM_view_hologram_phase(app, holo_image);
title(sprintf('Defocus %.1f um', app.ZOffsetumEditField.Value));

end