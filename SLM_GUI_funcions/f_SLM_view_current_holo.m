function f_SLM_view_current_holo(app)

holo_image = app.SLM_Image;
holo_image = f_SLM_AO_add_correction(app,holo_image, app.current_SLM_AO_Image);
f_SLM_view_hologram_phase(app, holo_image);
title('Current uploaded phase');

end