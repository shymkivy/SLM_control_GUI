function f_SLM_xyz_button_view_plane_phase(app)

coord = f_SLM_mpl_get_coords(app, 'plane', round(app.PlaneSpinner.Value));

% get roi
[m, n] = f_SLM_xyz_get_roimn(app);
SLMm = m(2) - m(1) + 1;
SLMn = n(2) - n(1) + 1;

holo_image = app.SLM_blank_im;
holo_image(m(1):m(2),n(1):n(2)) =  f_SLM_gen_holo_multiplane_image(app, coord, SLMm, SLMn);
                                  
holo_image = f_SLM_AO_add_correction(app,holo_image);

f_SLM_view_hologram_phase(app, holo_image);

end